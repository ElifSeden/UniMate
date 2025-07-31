import SwiftUI

struct PDFQuizSetupView: View {
    var onSubmit: (_ type: String, _ count: Int) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var selectedType = "Çoktan Seçmeli"
    @State private var selectedCount = 5

    // ✅ Klasik tipi eklendi
    let types = ["Çoktan Seçmeli", "Boşluk Doldurma", "Klasik"]
    let counts = [5, 10, 15, 20]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Soru Tipi")) {
                    Picker("Tip", selection: $selectedType) {
                        ForEach(types, id: \.self) { Text($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Soru Sayısı")) {
                    Picker("Sayı", selection: $selectedCount) {
                        ForEach(counts, id: \.self) { Text("\($0)") }
                    }
                }

                Button("Quiz Oluştur") {
                    onSubmit(selectedType, selectedCount)
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("Quiz Ayarları")
        }
    }
}
