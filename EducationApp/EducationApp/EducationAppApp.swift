import SwiftUI
import Firebase

@main
struct EducationAppApp: App {
    @StateObject var usageTracker = AppUsageTracker() // ✅ Zaman takibi başlatıldı

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(usageTracker) // ✅ Tüm uygulamaya dağıt
        }
    }
}
