import SwiftUI

struct AuthenticationView: View {
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text(isLoginMode ? "Giriş Yap" : "Üye Ol")
                    .font(.largeTitle)
                    .bold()

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                SecureField("Şifre", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                Button(action: {
                    if isLoginMode {
                        // Giriş fonksiyonu eklenecek
                    } else {
                        // Kayıt fonksiyonu eklenecek
                    }
                }) {
                    Text(isLoginMode ? "Giriş Yap" : "Üye Ol")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                Button(action: {
                    isLoginMode.toggle()
                }) {
                    Text(isLoginMode ? "Hesabınız yok mu? Üye Olun" : "Zaten hesabınız var mı? Giriş Yapın")
                        .font(.footnote)
                }
            }
            .padding()
        }
    }
}
