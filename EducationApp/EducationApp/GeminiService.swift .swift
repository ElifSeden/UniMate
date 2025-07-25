import Foundation

struct GeminiService {
    let apiKey = "REMOVED"

    func fetchSummaryAndQuestions(from text: String, completion: @escaping (String, [String]) -> Void) {
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=\(apiKey)")!

        let prompt = """
        Summarize the following text and generate 3 helpful quiz questions based on the content. Only respond in this format:

        Summary:
        [summary here]

        Questions:
        1. [question 1]
        2. [question 2]
        3. [question 3]

        TEXT:
        \(text.prefix(3000))
        """

        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("JSON error:", error)
            completion("Error building request.", [])
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("No data:", error ?? "Unknown error")
                completion("Error: No data", [])
                return
            }

            do {
                let responseData = try JSONDecoder().decode(GeminiResponse.self, from: data)
                if let textResponse = responseData.candidates.first?.content.parts.first?.text {
                    let lines = textResponse.components(separatedBy: "\n")
                    var summary = ""
                    var questions: [String] = []
                    var isQuestionSection = false
                    for line in lines {
                        if line.lowercased().contains("summary") {
                            continue
                        } else if line.lowercased().contains("questions") {
                            isQuestionSection = true
                            continue
                        } else if isQuestionSection {
                            if let q = line.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: true).last {
                                questions.append(String(q).trimmingCharacters(in: .whitespaces))
                            }
                        } else {
                            summary += line + " "
                        }
                    }
                    DispatchQueue.main.async {
                        completion(summary.trimmingCharacters(in: .whitespacesAndNewlines), questions)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion("No response from Gemini", [])
                    }
                }
            } catch {
                print("Decoding error:", error)
                completion("Error decoding Gemini response", [])
            }
        }.resume()
    }
}

// MARK: - Response Model
struct GeminiResponse: Codable {
    let candidates: [Candidate]
}

struct Candidate: Codable {
    let content: Content
}

struct Content: Codable {
    let parts: [Part]
}

struct Part: Codable {
    let text: String
}
