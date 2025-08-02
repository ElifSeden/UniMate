import SwiftUI

struct ParaphraseView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var originalText: String = ""
    @State private var paraphrasedText: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                // 🔶 Başlık kutusu (ortalanmış)
                VStack(alignment: .center, spacing: 4) {
                    Text("Paraphrase")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Metni öğrenci gibi yeniden yazdır.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .cornerRadius(20)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Metni buraya yapıştır:")
                        .font(.headline)

                    TextEditor(text: $originalText)
                        .frame(height: 150)
                        .padding(4)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.4)))

                    Button(action: {
                        paraphraseText()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("Paraphrase Et")
                                    .bold()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    if !paraphrasedText.isEmpty {
                        Text("Öğrenci gibi yeniden yazıldı:")
                            .font(.headline)

                        ScrollView {
                            Text(paraphrasedText)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }

    func paraphraseText() {
        isLoading = true
        paraphrasedText = ""

        Task {
            do {
                let prompt = """
                Rephrase the following text as if it were written by a student. Make it natural, simple, clear, and free from AI-like patterns. Keep the same language as the original input.

                Text:
                \(originalText)
                """

                let response = try await GeminiService.shared.sendPrompt(prompt)
                DispatchQueue.main.async {
                    self.paraphrasedText = response.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.paraphrasedText = "Bir hata oluştu: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
