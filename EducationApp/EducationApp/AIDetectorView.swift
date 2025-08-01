import SwiftUI
import UniformTypeIdentifiers

struct AIDetectorView: View {
    @State private var showAIDetector = false
    @State private var inputText = ""
    @State private var detectedResult: [String: Double]? = nil
    @State private var showFileImporter = false
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 0) {
            // Üst Başlık Kutusu
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Detector")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("Metni yapıştır, AI oranını öğren")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                Button(action: {
                    withAnimation {
                        showAIDetector.toggle()
                    }
                }) {
                    Image(systemName: showAIDetector ? "chevron.down.circle.fill" : "chevron.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                LinearGradient(colors: [.orange, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(20)
            .padding(.horizontal, 4)

            if showAIDetector {
                VStack(spacing: 16) {
                    Text("To analyze text, add at least 40 words.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TextEditor(text: $inputText)
                        .frame(height: 140)
                        .padding(6)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    HStack {
                        Button(action: {
                            showFileImporter = true
                        }) {
                            Label("Upload doc", systemImage: "doc.fill")
                        }
                        .buttonStyle(.bordered)

                        Spacer()

                        Button(action: {
                            detectAI()
                        }) {
                            Text("Detect AI")
                                .font(.headline)
                                .padding(.horizontal, 20)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(inputText.split(separator: " ").count < 40)
                    }

                    if isLoading {
                        ProgressView("AI analiz ediliyor...")
                            .padding()
                    }

                    if let result = detectedResult {
                        VStack(spacing: 8) {
                            ForEach(result.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                HStack {
                                    Text(key)
                                    Spacer()
                                    Text(String(format: "%.1f%%", value * 100))
                                }
                                .font(.subheadline)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 4)
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .padding(.top)
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [
                UTType.plainText,
                UTType.text,
                UTType.rtf,
                UTType.pdf,
                UTType.item
            ],
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
        isLoading = true  // Yükleme başlat

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
            isLoading = false  // Yükleme bitti

            guard let response = response else {
                print("Yanıt alınamadı.")
                return
            }

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
