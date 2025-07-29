import SwiftUI
import Firebase

@main
struct EducationAppApp: App {

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView() // Burada artık kullanıcı giriş yaptı mı kontrol ediyoruz
        }
    }
}
