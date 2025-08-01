import SwiftUI

// Model for a friend request
struct FriendRequest: Identifiable {
    let id = UUID()
    let name: String
    let mutualFriends: Int
    let avatarURL: URL?  // Eğer sunucudan yüklenecekse
}

struct FriendsView: View {
    @State private var requests: [FriendRequest] = [
        .init(name: "Ahmet Yılmaz", mutualFriends: 12, avatarURL: nil),
        .init(name: "Ayşe Demir", mutualFriends: 5, avatarURL: nil),
        .init(name: "Mehmet Can", mutualFriends: 8, avatarURL: nil)
    ]

    var body: some View {
        List {
            ForEach(requests) { request in
                HStack(spacing: 12) {
                    // Avatar
                    if let url = request.avatarURL {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(.gray.opacity(0.6))
                        }
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.gray.opacity(0.6))
                    }

                    // İsim ve mutual friends
                    VStack(alignment: .leading, spacing: 4) {
                        Text(request.name)
                            .font(.body.bold())
                        Text("\(request.mutualFriends) ortak arkadaş")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Spacer()

                    // Kabul / Reddet butonları
                    HStack(spacing: 8) {
                        Button("Kabul Et") {
                            // accept logic
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)

                        Button("Reddet") {
                            // decline logic
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Arkadaşlık İstekleri")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FriendsView()
        }
    }
}
