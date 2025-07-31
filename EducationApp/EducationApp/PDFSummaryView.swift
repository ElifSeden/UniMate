import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PDFSummaryView: View {
    @State private var selectedDocumentURL: URL?
    @State private var showPicker = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var summary: String?
    @State private var isLoading = false
    @State private var showQuizSetup = false
    @State private var selectedQuizType = "Çoktan Seçmeli"
    @State private var selectedQuizCount = 5


    let geminiService = GeminiService()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Başlık
                HStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("PDF Özet")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)

                Divider()

                // İçerik
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

                // Butonlar
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
                    .disabled(selectedDocumentURL == nil || isLoading)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((selectedDocumentURL != nil && !isLoading) ? Color.blue : Color.gray)
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
            .alert("Hata", isPresented: $showError, actions: {
                Button("Tamam", role: .cancel) { }
            }, message: {
                Text(errorMessage)
            })
        }
    }

    // MARK: - Parça Parça Metin Çıkar
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

    // MARK: - Gemini ile Parça Parça Özetle
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
