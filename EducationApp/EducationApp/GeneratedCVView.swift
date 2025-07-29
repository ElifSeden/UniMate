import SwiftUI

struct GeneratedCVView: View {
    let cvText: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("📄 CV’niz Hazır")
                    .font(.title)
                    .bold()

                Text(cvText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("CV Önizleme")
    }
}
