import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PDFSummaryView: View {
    @State private var selectedDocumentURL: URL?
    @State private var extractedText: String = ""
    @State private var showPicker = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var summary: String?
    @State private var isLoading = false // ✅ Yükleniyor durumu

    let geminiService = GeminiService()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ——— SABİT BAŞLIK ———
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

                // ——— KAYDIRILABİLİR İÇERİK ———
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let url = selectedDocumentURL {
                            Text("Seçili Dosya:")
                                .font(.subheadline).bold()
                            Text(url.lastPathComponent)
                                .font(.body)
                                .foregroundColor(.gray)

                            if isLoading {
                                // ✅ Spinner göster
                                HStack {
                                    Spacer()
                                    ProgressView("Özet çıkarılıyor...")
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
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 8)
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

                // ——— SABİT ALT BUTONLAR ———
                HStack(spacing: 16) {
                    Button("Özet Çıkar") {
                        guard let url = selectedDocumentURL else { return }
                        extractedText = extractText(from: url)
                        if !extractedText.isEmpty {
                            isLoading = true // ✅ İşlem başladı
                            geminiService.generateText(
                                from: "Lütfen bu PDF'i özetle:\n\n\(extractedText)"
                            ) { result in
                                DispatchQueue.main.async {
                                    self.summary = result ?? "Özet alınamadı."
                                    self.isLoading = false // ✅ İşlem bitti
                                }
                            }
                        } else {
                            errorMessage = "PDF'ten metin alınamadı."
                            showError = true
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
                    .disabled(isLoading) // ✅ Özetlenirken engelle
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

    private func extractText(from url: URL) -> String {
        guard let doc = PDFDocument(url: url) else { return "" }
        return (0..<doc.pageCount)
            .compactMap { doc.page(at: $0)?.string }
            .joined(separator: "\n")
    }
}
