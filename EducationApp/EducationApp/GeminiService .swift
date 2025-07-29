import Foundation

class GeminiService {
    // ✅ Kendi API anahtarını buraya koy
    private let apiKey = ""

    // Ortak AI fonksiyonu
    func generateText(from prompt: String, completion: @escaping (String?) -> Void) {
        // ✅ Yeni model ve versiyon
        guard let url = URL(string:
            "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=\(apiKey)")
        else {
            print("Hata: Geçersiz URL oluşturuldu.")
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
            print("Hata: JSON formatına dönüştürülemedi.")
            completion(nil)
            return
        }

        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            // Hata kontrolü
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

            // HTTP yanıtı ve durum kodu
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Durum Kodu: \(httpResponse.statusCode)")
            }

            // Yanıtı yazdır
            if let responseString = String(data: data, encoding: .utf8) {
                print("Yanıt:\n\(responseString)")
            }

            // JSON ayrıştırma
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let candidates = json["candidates"] as? [[String: Any]],
                  let content = candidates.first?["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let text = parts.first?["text"] as? String
            else {
                print("Hata: JSON beklenen formatta değil.")
                completion(nil)
                return
            }

            DispatchQueue.main.async {
                completion(text)
            }
        }.resume()
    }
}
