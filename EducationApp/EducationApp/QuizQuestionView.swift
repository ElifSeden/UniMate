
import SwiftUI

struct QuizQuestionView: View {
    let questions: [QuizQuestion]
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex = 0
    @State private var selectedAnswer: String? = nil
    @State private var showExplanation = false

    @State private var correctCount = 0
    @State private var wrongCount = 0
    @State private var showQuizResult = false

    @State private var userAnswer: String = ""
    @State private var aiFeedback: String = ""
    @State private var showingFeedback: Bool = false
    @State private var isEvaluating: Bool = false

    @State private var showExitConfirmation = false

    func normalize(_ text: String) -> String {
        return text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: #"^[a-d][\)\.\:\s]*"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: "", options: .regularExpression)
    }

    var body: some View {
        VStack(spacing: 0) {
            
            ZStack {
                Color.blue
                    .ignoresSafeArea(edges: .top)
                HStack {
                    Button(action: { showExitConfirmation = true }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "checklist")
                            .font(.title2)
                        Text("Quiz")
                            .font(.title2.bold())
                    }
                    .foregroundColor(.white)
                    Spacer()
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal)
            }
            .frame(height: 56)
            Divider()

            ScrollView {
                VStack(spacing: 20) {
                    if questions.isEmpty {
                        ProgressView("Sorular hazırlanıyor...")
                            .padding()
                        Text("Lütfen bekleyin, AI soruları oluşturuyor.")
                            .foregroundColor(.gray)
                    } else {
                        let question = questions[currentIndex]

                        Text("Soru \(currentIndex + 1)/\(questions.count)")
                            .font(.headline)

                        Text(question.question)
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if question.type == .openEnded {
                            Text("Cevabınızı Yazın:")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            TextEditor(text: $userAnswer)
                                .frame(height: 150)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4)))

                            Button("Cevabı Değerlendir") {
                                evaluateOpenEndedAnswer(question: question.question, userAnswer: userAnswer)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(10)

                            if isEvaluating {
                                ProgressView("AI cevabınızı değerlendiriyor...")
                                    .padding()
                            } else if showingFeedback {
                                DisclosureGroup("AI Geri Bildirimi") {
                                    Text(aiFeedback)
                                        .padding(.top, 4)
                                }
                                .padding()
                                .background(Color.yellow.opacity(0.2))
                                .cornerRadius(8)
                            }
                        } else if let options = question.options {
                            ForEach(options, id: \.self) { option in
                                let isSelected = selectedAnswer == option
                                let isCorrect = normalize(option) == normalize(question.correctAnswer)
                                Button {
                                    if selectedAnswer == nil {
                                        if isCorrect {
                                            correctCount += 1
                                        } else {
                                            wrongCount += 1
                                        }
                                    }
                                    selectedAnswer = option
                                    showExplanation = true
                                } label: {
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
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(isCorrect ? "✅ Doğru!" : "❌ Yanlış")
                                        .font(.headline)
                                        .foregroundColor(isCorrect ? .green : .red)
                                    Text("Açıklama: \(question.explanation)")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                    Text("📌 Kaynak: \(question.referenceText)")
                                        .font(.footnote)
                                        .foregroundColor(.blue)
                                }
                            }
                        }

                        HStack(spacing: 16) {
                            Button {
                                prevQuestion()
                            } label: {
                                Label("Önceki Soru", systemImage: "arrow.left.circle.fill")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(currentIndex == 0 ? Color.gray.opacity(0.2) : Color.orange.opacity(0.2))
                                    .foregroundColor(currentIndex == 0 ? .gray : .orange)
                                    .cornerRadius(10)
                            }
                            .disabled(currentIndex == 0)

                            if currentIndex + 1 < questions.count {
                                Button {
                                    nextQuestion()
                                } label: {
                                    Label("Sonraki Soru", systemImage: "arrow.right.circle.fill")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(currentIndex + 1 == questions.count ? Color.gray.opacity(0.2) : Color.orange.opacity(0.2))
                                        .foregroundColor(currentIndex + 1 == questions.count ? .gray : .orange)
                                        .cornerRadius(10)
                                }
                                .disabled(currentIndex + 1 == questions.count)
                            } else {
                                Button("Sınavı Bitir") {
                                    showQuizResult = true
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .alert("Quiz Sonuçları", isPresented: $showQuizResult) {
            Button("Tamam", role: .destructive) { dismiss() }
        } message: {
            Text("✅ Doğru: \(correctCount)\n❌ Yanlış: \(wrongCount)")
        }
        .alert("Çıkmak istediğinize emin misiniz?", isPresented: $showExitConfirmation) {
            Button("Evet", role: .destructive) { dismiss() }
            Button("İptal", role: .cancel) { }
        }
    }

  

    func nextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            resetState()
        }
    }

    func prevQuestion() {
        if currentIndex > 0 {
            currentIndex -= 1
            resetState()
        }
    }

    private func resetState() {
        selectedAnswer = nil
        showExplanation = false
        userAnswer = ""
        showingFeedback = false
        aiFeedback = ""
        isEvaluating = false
    }

    func evaluateOpenEndedAnswer(question: String, userAnswer: String) {
        let prompt = """
        Aşağıda bir öğrencinin klasik sınavda yazdığı cevap yer alıyor. Lütfen bu cevabı değerlendir:

        🧠 Soru: \(question)
        ✍️ Öğrencinin Cevabı: \(userAnswer)

        Lütfen başlıklarla cevap ver:
        – Doğruluk: Cevap doğru mu?
        – Geliştirme Önerisi: Daha iyi nasıl yazılabilir?
        – Genel Değerlendirme: Cevap yeterli mi, güçlü yönleri neler?

        Türkçe ve yapıcı bir dille açıkla.
        """
        isEvaluating = true
        GeminiService.shared.generateText(from: prompt) { response in
            DispatchQueue.main.async {
                self.aiFeedback = response ?? "AI'dan cevap alınamadı."
                self.showingFeedback = true
                self.isEvaluating = false
            }
        }
    }
}
