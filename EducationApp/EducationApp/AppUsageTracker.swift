import Foundation
import UserNotifications

/// Uygulama kullanımını takip eder ve günlük limit aşıldığında bildirim gönderir.
class AppUsageTracker: ObservableObject {
    /// Şu ana kadar bugüne kadar toplanan toplam saniye
    @Published var totalSecondsToday: TimeInterval = 0 {
        didSet { checkLimit() }
    }
    
    /// Kullanıcının ayarladığı günlük süre limiti (saniye cinsinden)
    @Published var dailyLimitSeconds: TimeInterval {
        didSet {
            saveLimit()
            checkLimit()
        }
    }
    
    /// Aynı gün içinde bir kez bildirim atmak için flag
    private var hasSentNotification = false
    
    init() {
        // Daha önce kaydettiysek yükle, yoksa 0 (yani bildirim kapalı)
        dailyLimitSeconds = UserDefaults.standard.double(forKey: "dailyLimitSeconds")
        
        // Bildirim yetkisini iste
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let err = error {
                print("Bildirim yetkisi alınırken hata: \(err)")
            }
        }
        
        // … burada totalSecondsToday’ı yükleme veya gerçek zamanlı güncelleme mantığını da ekleyebilirsin.
    }
    
    private func saveLimit() {
        UserDefaults.standard.set(dailyLimitSeconds, forKey: "dailyLimitSeconds")
    }
    
    /// Her `totalSecondsToday` değiştiğinde burası tetiklenir
    private func checkLimit() {
        guard dailyLimitSeconds > 0,
              totalSecondsToday >= dailyLimitSeconds,
              !hasSentNotification else { return }
        
        scheduleLimitReachedNotification()
        hasSentNotification = true
    }
    
    private func scheduleLimitReachedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Kullanım Süreniz Doldu"
        content.body = "Bugünkü kullanım süreniz \(formatTime(dailyLimitSeconds)) olarak ayarlanmıştı."
        
        // Anında gönder
        let request = UNNotificationRequest(
            identifier: "dailyLimitReached",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let err = error {
                print("Bildirim gönderilemedi: \(err)")
            }
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let hours = minutes / 60
        let rem = minutes % 60
        return "\(hours) saat \(rem) dakika"
    }
}
