import SwiftUI

struct QuizQuestionView: View {
    let questions: [QuizQuestion]
    @State private var currentIndex = 0
    @State private var selectedAnswer: String? = nil
    @State private var showExplanation = false

    // Klasik soru için
    @State private var userAnswer: String = ""
    @State private var aiFeedback: String = ""
    @State private var showingFeedback: Bool = false
    @State private var isEvaluating: Bool = false // ✅ Yükleniyor göstergesi

    func normalize(_ text: String) -> String {
        return text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: #"^[a-d][\)\.\:\s]*"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: "", options: .regularExpression)
    }

    var body: some View {
        VStack(spacing: 20) {
            if questions.isEmpty {
                ProgressView("Sorular hazırlanıyor...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                Text("Lütfen bekleyin, AI soruları oluşturuyor.")
                    .foregroundColor(.gray)
            } else {
                let question = questions[currentIndex]

                // 🔹 Soru numarası
                Text("Soru \(currentIndex + 1)/\(questions.count)")
                    .font(.headline)

                // 🔹 Soru metni
                Text(question.question)
                    .font(.title3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                if question.type == .openEnded {
                    // Açık uçlu soru UI
                    Text("Cevabınızı Yazın:")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TextEditor(text: $userAnswer)
                        .frame(height: 150)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4)))

                    Button(action: {
                        evaluateOpenEndedAnswer(question: question.question, userAnswer: userAnswer)
                    }) {
                        Text("Cevabı Değerlendir")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }

                    if isEvaluating {
                        ProgressView("AI cevabınızı değerlendiriyor...")
                            .padding()
                    } else if showingFeedback {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AI Geri Bildirimi")
                                .font(.headline)

                            DisclosureGroup("Detaylı Geri Bildirim") {
                                Text(aiFeedback)
                                    .foregroundColor(.gray)
                                    .padding(.top, 4)
                            }
                            .padding()
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(8)

                            Button("Sonraki Soru") {
                                nextQuestion()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.orange)
                        }
                    }


                } else if let options = question.options {
                    // Seçmeli soru UI
                    ForEach(options, id: \.self) { option in

                        let isSelected = selectedAnswer == option
                        let isCorrect = normalize(option) == normalize(question.correctAnswer)

                        Button(action: {
                            selectedAnswer = option
                            showExplanation = true
                        }) {
                            HStack {
                                Text(option)
                                    .foregroundColor(.blue)
                                Spacer()
                                if isSelected {
                                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(isCorrect ? .green : .red)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .disabled(showExplanation)
                    }

                    if showExplanation {
                        let isCorrect = normalize(selectedAnswer ?? "") == normalize(question.correctAnswer)

                        VStack(alignment: .leading, spacing: 12) {
                            Text(isCorrect ? "✅ Doğru!" : "❌ Yanlış")
                                .font(.headline)
                                .foregroundColor(isCorrect ? .green : .red)

                            Text("Açıklama: \(question.explanation)")
                                .foregroundColor(.gray)

                            Text("📌 Kaynak: \(question.referenceText)")
                                .font(.footnote)
                                .foregroundColor(.blue)

                            Text("📄 Bu soru PDF içeriğinden AI tarafından hazırlanmıştır.")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Button(action: {
                                nextQuestion()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                    Text("Sonraki Soru")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.top)
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Quiz")
    }

    // ✅ Sonraki soru geçişi
    func nextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedAnswer = nil
            showExplanation = false
            userAnswer = ""
            showingFeedback = false
            aiFeedback = ""
            isEvaluating = false
        }
    }

    // ✅ AI açık uçlu cevap değerlendirmesi
    func evaluateOpenEndedAnswer(question: String, userAnswer: String) {
        let prompt = """
        Aşağıda bir öğrencinin klasik sınavda yazdığı cevap yer alıyor. Lütfen bu cevabı değerlendir:

        🧠 Soru: \(question)
        ✍️ Öğrencinin Cevabı: \(userAnswer)

        Lütfen şu başlıklarla cevap ver:
        – Doğruluk: Cevap doğru mu?
        – Geliştirme Önerisi: Daha iyi nasıl yazılabilir?
        – Genel Değerlendirme: Cevap yeterli mi, güçlü yönleri neler?

        Türkçe ve yapıcı bir dille açıkla.
        """

        isEvaluating = true // Spinner başlasın

        GeminiService.shared.generateText(from: prompt) { response in
            DispatchQueue.main.async {
                self.aiFeedback = response ?? "AI'dan cevap alınamadı."
                self.showingFeedback = true
                self.isEvaluating = false // Spinner dursun
            }
        }
    }

}
