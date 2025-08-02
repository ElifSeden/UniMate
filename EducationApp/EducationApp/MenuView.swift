import SwiftUI
import FirebaseAuth

struct MenuView: View {
    @Binding var selectedTab: Int
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel  // ✅ Eklendi

    var body: some View {
        List {
            // ✅ 1. Profilim
            NavigationLink {
                ProfileView(selectedTab: $selectedTab)
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Profilim")
                        Text("Profil bilgilerini düzenle")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 6)
            }

            // ✅ 2. Ayarlar
            NavigationLink {
                SettingsView()
                Text("Ayarlar Ekranı")
                    .navigationTitle("Ayarlar")
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "gear")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ayarlar")
                        Text("Uygulama ayarlarını düzenle")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 6)
            }

            // ✅ 3. Çıkış Yap
            Section {
                Button(role: .destructive) {
                    authViewModel.signOut()                  // ✅ Firebase çıkışı
                    selectedTab = 0                          // ✅ Ana sayfaya dön
                    presentationMode.wrappedValue.dismiss() // ✅ Menüden çık
                } label: {
                    HStack {
                        Image(systemName: "arrow.backward.circle.fill")
                            .foregroundColor(.red)
                        Text("Çıkış Yap")
                            .foregroundColor(.red)
                            .textCase(nil)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }
}
