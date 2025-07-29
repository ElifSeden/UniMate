import SwiftUI
import VisionKit
import PDFKit

struct CameraScannerView: UIViewControllerRepresentable {
    var onScanCompleted: (URL?) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(onScanCompleted: onScanCompleted)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerVC = VNDocumentCameraViewController()
        scannerVC.delegate = context.coordinator
        return scannerVC
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var onScanCompleted: (URL?) -> Void

        init(onScanCompleted: @escaping (URL?) -> Void) {
            self.onScanCompleted = onScanCompleted
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let pdfDocument = PDFDocument()
            for i in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: i)
                if let page = PDFPage(image: image) {
                    pdfDocument.insert(page, at: i)
                }
            }

            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("scan.pdf")
            if pdfDocument.write(to: tempURL) {
                onScanCompleted(tempURL)
            } else {
                onScanCompleted(nil)
            }

            controller.dismiss(animated: true)
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            onScanCompleted(nil)
            controller.dismiss(animated: true)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Scan failed: \(error.localizedDescription)")
            onScanCompleted(nil)
            controller.dismiss(animated: true)
        }
    }
}
