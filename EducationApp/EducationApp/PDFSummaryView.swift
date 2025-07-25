import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct PDFSummaryView: View {
    @State private var selectedURL: URL?
    @State private var summary: String = ""
    @State private var questions: [String] = []
    @State private var showPicker = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button("Select PDF") {
                    showPicker = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                if !summary.isEmpty {
                    Text("Summary:")
                        .font(.headline)
                    ScrollView {
                        Text(summary)
                            .padding()
                    }
                }

                if !questions.isEmpty {
                    Text("Questions:")
                        .font(.headline)
                    ForEach(questions, id: \.self) { question in
                        Text("• \(question)")
                    }
                }
            }
            .padding()
            .navigationTitle("PDF Analyzer")
            .sheet(isPresented: $showPicker) {
                DocumentPicker(selectedURL: $selectedURL, onPicked: analyzePDF)
            }
        }
    }

    func analyzePDF() {
        guard let url = selectedURL else { return }
        if let pdfDoc = PDFDocument(url: url) {
            var fullText = ""
            for pageIndex in 0..<pdfDoc.pageCount {
                if let page = pdfDoc.page(at: pageIndex) {
                    fullText += page.string ?? ""
                }
            }

            let gemini = GeminiService()
            gemini.fetchSummaryAndQuestions(from: fullText) { resultSummary, resultQuestions in
                self.summary = resultSummary
                self.questions = resultQuestions
            }
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    var onPicked: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.selectedURL = url
            parent.onPicked()
        }
    }
}
