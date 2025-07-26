import SwiftUI
import UniformTypeIdentifiers
import PDFKit


struct CVScreen: View {
    @State private var cvText: String = ""
    @State private var feedback: String = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button("Upload CV (PDF)") {
                    showDocumentPicker()
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
        }
    }

    func showDocumentPicker() {
        let supportedTypes: [UTType] = [UTType.pdf]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        picker.delegate = DocumentPicker.shared
        picker.allowsMultipleSelection = false

        DocumentPicker.shared.completion = { url in
            if let url = url {
                extractText(from: url)
            }
        }

        UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
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
       
    }
}

