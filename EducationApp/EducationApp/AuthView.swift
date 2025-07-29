import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text(isLogin ? "Giriş Yap" : "Üye Ol")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Şifre", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                if isLogin {
                    login()
                } else {
                    register()
                }
            }) {
                Text(isLogin ? "Giriş Yap" : "Üye Ol")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: {
                isLogin.toggle()
            }) {
                Text(isLogin ? "Hesabın yok mu? Üye Ol" : "Zaten hesabın var mı? Giriş Yap")
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }

    // MARK: - Giriş Fonksiyonu
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = "Giriş başarısız: \(error.localizedDescription)"
            } else {
                self.errorMessage = ""
            }
        }
    }

    // MARK: - Kayıt Fonksiyonu
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = "Kayıt başarısız: \(error.localizedDescription)"
            } else {
                self.errorMessage = ""
            }
        }
    }
}
