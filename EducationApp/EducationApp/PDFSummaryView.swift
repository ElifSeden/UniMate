import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PDFSummaryView: View {
    @State private var selectedDocumentURL: URL? = nil
    @State private var extractedText: String = ""
    @State private var showPicker = false
    @State private var showCamera = false
    @State private var showError = false
    @State private var showSourceMenu = false
    @State private var errorMessage = ""
    @State private var summary: String? = nil

    let geminiService = GeminiService()

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    Text("PDF Summary")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)

                    if let selectedURL = selectedDocumentURL {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Selected File: \(selectedURL.lastPathComponent)")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            if let summary = summary {
                                ScrollView {
                                    Text(summary)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 70)
                                .foregroundColor(.gray)

                            Text("No PDF selected")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                        Spacer()
                    }

                    HStack {
                        Button("Analiz Et") {
                            if let url = selectedDocumentURL {
                                extractedText = extractText(from: url)
                                if !extractedText.isEmpty {
                                    geminiService.generateText(from: "Lütfen bu PDF'yi özetle:\n\n\(extractedText)") { result in
                                        DispatchQueue.main.async {
                                            self.summary = result ?? "Özet alınamadı."
                                        }
                                    }
                                } else {
                                    errorMessage = "PDF'den metin alınamadı."
                                    showError = true
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedDocumentURL != nil ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(selectedDocumentURL == nil)

                        Button(action: {
                            withAnimation {
                                showSourceMenu.toggle()
                            }
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }

                if showSourceMenu {
                    VStack(spacing: 12) {
                        Button(action: {
                            showSourceMenu = false
                            showCamera = true
                        }) {
                            Label("Kamerayla Tara", systemImage: "camera")
                                .padding()
                                .frame(width: 200)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                        }

                        Button(action: {
                            showSourceMenu = false
                            showPicker = true
                        }) {
                            Label("Dosyadan Seç", systemImage: "doc")
                                .padding()
                                .frame(width: 200)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 120)
                }
            }
            .sheet(isPresented: $showPicker) {
                DocumentPicker { url in
                    if let url = url {
                        selectedDocumentURL = url
                        summary = nil
                    }
                }
            }

            .sheet(isPresented: $showCamera) {
                CameraScannerView { scannedURL in
                    if let url = scannedURL {
                        selectedDocumentURL = url
                        summary = nil
                    }
                }
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("Hata"), message: Text(errorMessage), dismissButton: .default(Text("Tamam")))
            }
        }
    }

    func extractText(from url: URL) -> String {
        guard let pdf = PDFDocument(url: url) else { return "" }
        var text = ""
        for i in 0..<pdf.pageCount {
            if let page = pdf.page(at: i), let pageText = page.string {
                text += pageText + "\n"
            }
        }
        return text
    }
}
