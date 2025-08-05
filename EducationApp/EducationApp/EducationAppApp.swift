import SwiftUI
import Firebase
import UserNotifications  

@main
struct EducationAppApp: App {
    @StateObject var usageTracker = AppUsageTracker()
       @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false
    
    init() {
        
        FirebaseApp.configure()
      
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { granted, error in
                if let err = error {
                    print("Bildirim izni alınırken hata: \(err)")
                }
            }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(usageTracker)
                .preferredColorScheme(darkModeEnabled ? .dark : .light)
        }
    }
}
