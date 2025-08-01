import SwiftUI

struct MenuView: View {
    @Binding var selectedTab: Int
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        List {
            // 1. Profilim
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

            // 2. Arkadaşlık İstekleri
            NavigationLink {
                FriendsView()
                    .navigationTitle("Arkadaşlık İstekleri")
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Arkadaşlık İstekleri")
                        Text("Yeni gelen istekleri gör")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 6)
            }

            // 3. Bildirimler
            NavigationLink {
                NotificationsView()
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "bell")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Bildirimler")
                        Text("Tüm uyarılarını yönet")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 6)
            }

            // 4. Zaman Yönetimi
            NavigationLink {
                Text("Zaman Yönetimi Ekranı")
                    .navigationTitle("Zaman Yönetimi")
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "clock")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Zaman Yönetimi")
                        Text("Uygulama kullanım süreni gör")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 6)
            }

            // 5. Ayarlar
            NavigationLink {
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
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Ayarlar ve Hareketler")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text("Geri")
                    }
                }
            }
        }
    }
}
