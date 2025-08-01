import SwiftUI
import Firebase
import UserNotifications  // bildirim için

@main
struct EducationAppApp: App {
    // 1️⃣ Zaman takibi için tracker’ı başlatıyoruz
    @StateObject var usageTracker = AppUsageTracker()
    // 3️⃣ Koyu mod ayarını tüm uygulamaya uygula
       @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false
    
    init() {
        // 2️⃣ Firebase’i başlat
        FirebaseApp.configure()
        
        // 3️⃣ Bildirim iznini iste
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { granted, error in
                if let err = error {
                    print("Bildirim izni alınırken hata: \(err)")
                }
            }
    }

    var body: some Scene {
        WindowGroup {
            RootView()   // veya senin ana görünümün neyse
                .environmentObject(usageTracker)  // 4️⃣ tüm alt görünümlere inject et
                .preferredColorScheme(darkModeEnabled ? .dark : .light)
        }
    }
}
