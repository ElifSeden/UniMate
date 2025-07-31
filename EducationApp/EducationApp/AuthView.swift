import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true

    var body: some View {
        VStack(spacing: 24) {
            Text(isLoginMode ? "Giriş Yap" : "Üye Ol")
                .font(.largeTitle.bold())
                .padding(.top, 40)

            VStack(alignment: .leading, spacing: 12) {
                Text("E-posta")
                    .font(.subheadline)
                TextField("ornek@unimate.com", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)

                Text("Şifre")
                    .font(.subheadline)
                SecureField("••••••••", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)

            if let error = authViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: {
                if isLoginMode {
                    authViewModel.signIn(email: email, password: password)
                } else {
                    authViewModel.signUp(email: email, password: password)
                }
            }) {
                Text(isLoginMode ? "Giriş Yap" : "Üye Ol")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Button(action: {
                isLoginMode.toggle()
            }) {
                Text(isLoginMode ? "Hesabın yok mu? Üye Ol" : "Zaten hesabın var mı? Giriş Yap")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }

            Spacer()
        }
        .padding()
    }
}
