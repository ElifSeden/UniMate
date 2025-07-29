import SwiftUI
import FirebaseAuth

struct RootView: View {
    @State private var isLoggedIn = Auth.auth().currentUser != nil

    var body: some View {
        Group {
            if isLoggedIn {
                ProfileView() // Giriş yaptıysa profil sayfası
            } else {
                AuthView() // Giriş yapmadıysa giriş/kayıt ekranı
            }
        }
        .onAppear {
            Auth.auth().addStateDidChangeListener { _, user in
                self.isLoggedIn = user != nil
            }
        }
    }
}
