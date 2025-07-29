import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct CVScreen: View {
    @State private var showPicker = false
    @State private var cvText: String = ""
    @State private var feedback: String = ""
    @State private var isLoading = false
    @State private var selectedURL: URL?

    var body: some View {
        NavigationView {
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
            .sheet(isPresented: $showPicker) {
                DocumentPicker { url in
                    if let url = url {
                        selectedURL = url
                        extractText(from: url)
                    }
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
        // istersen burada AI yorum fonksiyonu çağrısı yapabilirsin
    }
}
