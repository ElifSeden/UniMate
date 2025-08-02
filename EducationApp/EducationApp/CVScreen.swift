import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct CVScreen: View {
    @State private var showPicker = false
    @State private var cvText: String = ""
    @State private var feedback: String = ""
    @State private var isLoading = false
    @State private var selectedURL: URL?

    @State private var showShareSheet = false
    @State private var pdfURL: URL?

    var body: some View {
        NavigationStack {

            VStack(spacing: 20) {
                Button("Upload CV (PDF)") {
                    showPicker = true
                }
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(12)

                if isLoading {
                    ProgressView("Generating feedback...")
                }

                if !feedback.isEmpty {
                    ScrollView {
                        Text(feedback)
                            .padding()
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("CV Mentor")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let url = selectedURL,
                           let data = try? Data(contentsOf: url),
                           let savedURL = savePDFLocally(data: data) {
                            self.pdfURL = savedURL
                            self.showShareSheet = true
                        }
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .imageScale(.large)
                            .foregroundColor(.blue)
                    }
                    .disabled(selectedURL == nil)
                }
            }
            .sheet(isPresented: $showPicker) {
                DocumentPicker { url in
                    if let url = url {
                        selectedURL = url
                        extractText(from: url)
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = pdfURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }

    func extractText(from url: URL) {
        guard let pdf = PDFDocument(url: url) else { return }
        var fullText = ""
        for pageIndex in 0..<pdf.pageCount {
            if let page = pdf.page(at: pageIndex),
               let pageText = page.string {
                fullText += pageText + "\n"
            }
        }
        self.cvText = fullText
        // Burada AI ile analiz yapılabilir
    }

    func savePDFLocally(data: Data) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("UploadedCV.pdf")
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("PDF kaydedilemedi: \(error)")
            return nil
        }
    }
}
