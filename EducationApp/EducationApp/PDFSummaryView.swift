import SwiftUI
import PDFKit
import UniformTypeIdentifiers
import AVFoundation

struct PDFSummaryView: View {

    @State private var selectedDocumentURL: URL?
    @State private var showPicker = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var summary: String?
    @State private var isLoading = false
    @State private var isSpeaking = false
    @State private var showQuizSetup = false
    @State private var selectedQuizType = "Çoktan Seçmeli"
    @State private var selectedQuizCount = 5

    @Environment(\.presentationMode) private var presentationMode
    @Binding var selectedTab: Int

    let geminiService = GeminiService()
    private let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    Color.blue.ignoresSafeArea(edges: .top)

                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("PDF Özet")
                            .font(.title2).bold()
                            .foregroundColor(.white)
                    }

                    HStack(spacing: 16) {
                        if summary != nil {
                            Button {
                                if isSpeaking {
                                    synthesizer.stopSpeaking(at: .immediate)
                                    isSpeaking = false
                                } else {
                                    let utterance = AVSpeechUtterance(string: summary!)
                                    utterance.voice = AVSpeechSynthesisVoice(language: "tr-TR")
                                    synthesizer.speak(utterance)
                                    isSpeaking = true
                                }
                            } label: {
                                Image(systemName: isSpeaking ? "stop.fill" : "play.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            Button {
                                selectedDocumentURL = nil
                                summary = nil
                                isLoading = false
                                showError = false
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        Spacer()
                    }
                    .padding(.leading)
                }
                .frame(height: 56)

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let url = selectedDocumentURL {
                            Text("Seçili Dosya:")
                                .font(.subheadline).bold()
                            Text(url.lastPathComponent)
                                .foregroundColor(.gray)

                            if isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView("PDF özetleniyor...")
                                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                        .padding()
                                    Spacer()
                                }
                            } else if let özet = summary {
                                Text("Özet")
                                    .font(.subheadline).bold()
                                    .padding(.top, 8)
                                Text(özet)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            } else {
                                Text("Özet almak için “Özet Çıkar” butonuna basın.")
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 70)
                                    .foregroundColor(.gray)
                                Text("PDF seçilmedi")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        }
                    }
                    .padding()
                }

                Divider()

                HStack(spacing: 16) {
                    Button("Özet Çıkar") {
                        guard let url = selectedDocumentURL else { return }
                        isLoading = true
                        let chunks = extractChunks(from: url, chunkSize: 5)
                        summarizeChunks(chunks) { fullSummary in
                            self.summary = fullSummary
                            self.isLoading = false
                        }
                    }
                    .disabled(selectedDocumentURL == nil || isLoading || summary != nil)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((selectedDocumentURL != nil && !isLoading && summary == nil) ? Color.blue : Color.gray.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    Button {
                        showPicker = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(isLoading)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showPicker) {
                DocumentPicker { url in
                    if let url = url {
                        self.selectedDocumentURL = url
                        self.summary = nil
                    }
                }
            }
            .alert("Hata", isPresented: $showError) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .onDisappear {
            if isSpeaking {
                synthesizer.stopSpeaking(at: .immediate)
            }
        }
    }

    private func extractChunks(from url: URL, chunkSize: Int = 5) -> [String] {
        guard let doc = PDFDocument(url: url) else { return [] }
        var chunks: [String] = []
        let totalPages = doc.pageCount
        var index = 0
        while index < totalPages {
            let end = min(index + chunkSize, totalPages)
            let chunk = (index..<end)
                .compactMap { doc.page(at: $0)?.string }
                .joined(separator: "\n")
            chunks.append(chunk)
            index += chunkSize
        }
        return chunks
    }

    private func summarizeChunks(_ chunks: [String], completion: @escaping (String) -> Void) {
        var fullSummary = ""
        let group = DispatchGroup()

        for chunk in chunks {
            group.enter()
            let prompt = """
            Aşağıdaki PDF bölümünü öğrencinin anlayacağı şekilde kısa ve öğretici şekilde özetle.
            Formül, tanım ve önemli bilgileri açıkla. Gereksiz detay verme:

            \(chunk)
            """
            geminiService.generateText(from: prompt) { result in
                if let partial = result {
                    fullSummary += "\n\n\(partial)"
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(fullSummary.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}
