import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct DownloadablePDFView: View {
    let pdfData: Data
    @State private var pdfURL: URL?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if let url = pdfURL {
                    // iOS 16+ için ShareLink
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.title2)
                            .padding(8)
                    }
                }
            }
            .padding(.horizontal)
            .background(Color(.systemGray6))
            
            // PDF gösteren eski UIViewRepresentable
            PDFKitRepresentedView(data: pdfData)
                .edgesIgnoringSafeArea(.all)
        }
        .onAppear(perform: saveToTemp)
    }
    
    private func saveToTemp() {
        let filename = "Unimate_CV_\(Int(Date().timeIntervalSince1970)).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try pdfData.write(to: tempURL)
            pdfURL = tempURL
        } catch {
            print("PDF kaydedilemedi: \(error)")
        }
    }
}
