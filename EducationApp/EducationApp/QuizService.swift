import Foundation

// 🔹 Soru türleri
enum QuizType: String, Codable {
    case multipleChoice
    case fillInTheBlank
    case openEnded
}

// 🔹 Model
struct QuizQuestion: Identifiable, Codable {
    let id = UUID()
    let type: QuizType
    let question: String
    let options: [String]?
    let correctAnswer: String
    let explanation: String
    let referenceText: String
}

class QuizService {
    private let gemini = GeminiService()

    // 🔧 Şıkları normalize eden fonksiyon
    private func normalize(_ text: String) -> String {
        return text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: #"^[a-d][\)\.\:\s]*"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"^(d\s*=\s*|cevap\s*:\s*|doğru\s*cevap\s*:\s*)"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: " ", with: "")
    }

    // 🔹 Metni parçalara böl
    private func splitText(_ text: String, maxChunkSize: Int = 1000) -> [String] {
        var chunks: [String] = []
        var startIndex = text.startIndex

        while startIndex < text.endIndex {
            let endIndex = text.index(startIndex, offsetBy: maxChunkSize, limitedBy: text.endIndex) ?? text.endIndex
            let chunk = String(text[startIndex..<endIndex])
            chunks.append(chunk)
            startIndex = endIndex
        }

        return chunks
    }

    // 🔹 Quiz üretici fonksiyon
    func generateQuiz(from text: String, type: String, count: Int, completion: @escaping ([QuizQuestion]) -> Void) {
        let chunks = splitText(text)
        var allQuestions: [QuizQuestion] = []
        let questionsPerChunk = max(1, count / chunks.count)
        let group = DispatchGroup()

        for chunk in chunks {
            group.enter()

            let prompt: String
            let quizType: QuizType

            switch type {
            case "Çoktan Seçmeli":
                quizType = .multipleChoice
                prompt = """
                Aşağıdaki metne göre \(questionsPerChunk) adet çoktan seçmeli quiz sorusu hazırla.
                Her soru için:
                - Soru metni
                - 4 seçenek (a-d)
                - Doğru cevabı (tam metin olmalı)
                - Açıklama
                - Metin referansı

                JSON çıktısı:
                [
                  {
                    "type": "multipleChoice",
                    "question": "...",
                    "options": ["...","...","...","..."],
                    "correctAnswer": "...",
                    "explanation": "...",
                    "referenceText": "..."
                  }
                ]

                Sadece JSON ver. Metin:
                \(chunk)
                """

            case "Boşluk Doldurma":
                quizType = .fillInTheBlank
                prompt = """
                Aşağıdaki metne göre \(questionsPerChunk) adet boşluk doldurma sorusu oluştur.
                - Cümlede boşluk bırak
                - 4 şık ver (1 doğru 3 yanlış)
                - Açıklama ve referans ekle

                JSON çıktısı:
                [
                  {
                    "type": "fillInTheBlank",
                    "question": "Türkiye'nin başkenti _______",
                    "options": ["Ankara", "İstanbul", "İzmir", "Bursa"],
                    "correctAnswer": "Ankara",
                    "explanation": "...",
                    "referenceText": "..."
                  }
                ]

                Sadece JSON ver. Metin:
                \(chunk)
                """

            case "Klasik":
                quizType = .openEnded
                prompt = """
                Aşağıdaki metne göre \(questionsPerChunk) adet açık uçlu (klasik) soru oluştur.
                - Soru metni
                - Örnek doğru cevap
                - Açıklama ve referans

                JSON çıktısı:
                [
                  {
                    "type": "openEnded",
                    "question": "Neden ... olur?",
                    "options": null,
                    "correctAnswer": "Çünkü ...",
                    "explanation": "...",
                    "referenceText": "..."
                  }
                ]

                Sadece JSON ver. Metin:
                \(chunk)
                """

            default:
                quizType = .multipleChoice
                prompt = ""
            }

            gemini.generateText(from: prompt) { result in
                defer { group.leave() }

                guard let raw = result else {
                    print("Gemini yanıtı boş")
                    return
                }

                let cleaned = raw
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```", with: "")

                guard let data = cleaned.data(using: .utf8) else {
                    print("UTF-8 dönüşüm hatası")
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode([QuizQuestion].self, from: data)

                    let normalized = decoded.map { q in
                        QuizQuestion(
                            type: quizType,
                            question: q.question,
                            options: q.options?.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? [],
                            correctAnswer: self.normalize(q.correctAnswer),
                            explanation: q.explanation,
                            referenceText: q.referenceText
                        )
                    }

                    allQuestions.append(contentsOf: normalized)
                } catch {
                    print("Decode hatası: \(error)")
                    print("Yanıt: \(cleaned)")
                }
            }
        }

        group.notify(queue: .main) {
            completion(Array(allQuestions.prefix(count)))
        }
    }
}
