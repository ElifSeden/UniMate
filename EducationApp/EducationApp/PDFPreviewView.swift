import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    let pdfData: Data

    var body: some View {
        PDFKitRepresentedView(data: pdfData)
            .edgesIgnoringSafeArea(.all)
    }
}

struct PDFKitRepresentedView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
