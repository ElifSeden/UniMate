import Foundation

class GeminiService {
    // ✅ Ortak erişim noktası (singleton)
    static let shared = GeminiService()

    // ✅ API anahtarı
    private let apiKey = "***REMOVED***"

    // ✅ AI metin üretimi
    func generateText(from prompt: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string:
            "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=\(apiKey)")
        else {
            print("Hata: Geçersiz URL.")
            completion(nil)
            return
        }

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("Hata: JSON dönüşümü başarısız.")
            completion(nil)
            return
        }

        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ağ Hatası: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("Hata: Veri gelmedi.")
                completion(nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Durum: \(httpResponse.statusCode)")
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("Yanıt:\n\(responseString)")
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let candidates = json["candidates"] as? [[String: Any]],
                  let content = candidates.first?["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let text = parts.first?["text"] as? String
            else {
                print("Hata: Yanıt beklenen formatta değil.")
                completion(nil)
                return
            }

            DispatchQueue.main.async {
                completion(text)
            }
        }.resume()
    }
}
