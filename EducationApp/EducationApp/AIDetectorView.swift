import SwiftUI
import UniformTypeIdentifiers

struct AIDetectorView: View {
    @Environment(\.dismiss) var dismiss
    @State private var inputText = ""
    @State private var detectedResult: [String: Double]? = nil
    @State private var showFileImporter = false
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // 🔙 Kapat + Başlık Kutusu (MoodCheck tarzı)
                HStack {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .padding(.leading)

                    Spacer()
                }

                VStack(alignment: .center, spacing: 6) {
                    Text("AI Tespiti")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("Metni yapıştırın veya yükleyin, AI oranını öğrenin.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .cornerRadius(20)
                .padding(.horizontal)

                // 📝 Metin Girişi Kutusu
                VStack(alignment: .leading, spacing: 8) {
                    Text("Metni Yapıştırın")
                        .font(.headline)

                    TextEditor(text: $inputText)
                        .frame(height: 130)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    Text("Minimum 40 kelime giriniz.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray.opacity(0.2), radius: 3)
                .padding(.horizontal)

                // 📎 Butonlar
                HStack {
                    Button(action: {
                        showFileImporter = true
                    }) {
                        Label("Dosya Yükle", systemImage: "doc.fill")
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button(action: detectAI) {
                        Text("AI Tespiti Yap")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(inputText.split(separator: " ").count < 40)
                }
                .padding(.horizontal)

                // ⏳ Yükleniyor
                if isLoading {
                    ProgressView("AI analiz ediliyor...")
                        .padding()
                }

                // ✅ Sonuçlar
                if let result = detectedResult {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sonuçlar")
                            .font(.headline)

                        ForEach(result.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(key)
                                    .font(.subheadline)
                                ProgressView(value: value) {
                                    Text(String(format: "%.1f%%", value * 100))
                                }
                                .accentColor(.purple)
                            }
                        }

                        Text("⚠️ Bu oranlar tahmine dayalıdır.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray.opacity(0.2), radius: 3)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.plainText, .text, .rtf, .pdf, .item],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first,
                   let content = try? String(contentsOf: url) {
                    inputText = content
                }
            case .failure(let error):
                print("Dosya okunamadı: \(error.localizedDescription)")
            }
        }
    }

    func detectAI() {
        isLoading = true
        let prompt = """
        Aşağıdaki metni değerlendir ve sadece bu 4 etiketin oranlarını sırayla ver, her biri ayrı satırda olacak:
        AI-generated: %...
        AI-generated & AI-refined: %...
        Human-written & AI-refined: %...
        Human-written: %...

        Metin:
        \(inputText)
        """

        GeminiService.shared.generateText(from: prompt) { response in
            isLoading = false

            guard let response = response else { return }

            let lines = response.components(separatedBy: "\n")
            var result: [String: Double] = [
                "AI-generated": 0.0,
                "AI-generated & AI-refined": 0.0,
                "Human-written & AI-refined": 0.0,
                "Human-written": 0.0
            ]

            for line in lines {
                let parts = line.components(separatedBy: ":")
                if parts.count == 2 {
                    let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let valueStr = parts[1].replacingOccurrences(of: "%", with: "")
                        .trimmingCharacters(in: .whitespaces)
                    if let value = Double(valueStr), result.keys.contains(key) {
                        result[key] = value / 100.0
                    }
                }
            }

            self.detectedResult = result
        }
    }
}
