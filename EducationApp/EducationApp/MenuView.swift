import SwiftUI
import FirebaseAuth

struct MenuView: View {
    @Binding var selectedTab: Int
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        List {
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

            NavigationLink {
                SettingsView()
                    .navigationTitle("Ayarlar")
                    .navigationBarTitleDisplayMode(.inline)
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

            Section {
                Button(role: .destructive) {
                    authViewModel.signOut()
                    selectedTab = 0
                    dismiss()
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
        .listStyle(.insetGrouped)
        .navigationTitle("Menü")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Geri")
                    }
                }
            }
        }
    }
}

#if DEBUG
struct MenuView_Previews: PreviewProvider {
    @State static var tab = 0
    static var previews: some View {
        NavigationStack {
            MenuView(selectedTab: $tab)
                .environmentObject(AuthViewModel())
        }
    }
}
#endif
