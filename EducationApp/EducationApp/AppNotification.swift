import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// Basit bildirim modeli
struct AppNotification: Identifiable {
    let id: String
    let title: String
    let body: String
    let date: Date
}

struct NotificationsView: View {
    @State private var notifications: [AppNotification] = [
        .init(id: "spam1",
              title: "SPAM: Hemen tıklayın!",
              body: "Ücretsiz hediye kazandınız! Acele edin.",
              date: Date()),
        .init(id: "spam2",
              title: "SPAM: Hesabınız güncellendi!",
              body: "Şifrenizi sıfırlamak için buraya tıklayın.",
              date: Date().addingTimeInterval(-3600))
    ]
    @State private var isNotificationsEnabled: Bool = UserDefaults.standard.bool(forKey: "isNotificationsEnabled")
    @State private var selectedNotifications = Set<String>()
    @State private var showDeleteBar = false
    @State private var showDeleteAlert = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                Text("Bildirimleri Aç/Kapat")
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: $isNotificationsEnabled)
                    .labelsHidden()
                    .onChange(of: isNotificationsEnabled) { newValue in
                        UserDefaults.standard.set(newValue, forKey: "isNotificationsEnabled")
                       
                    }
            }
            .padding()
            .background(Color(.systemGray6))

           
            if showDeleteBar {
                HStack {
                    Spacer()
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.red)
                    }
                    Spacer()
                }
                .padding(.bottom)
                .background(Color(.systemGray6))
            }

            if notifications.isEmpty {
                Spacer()
                Text("Geçmiş bildiriminiz bulunmamaktadır")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(notifications) { notif in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(notif.title)
                                .font(.body.bold())
                            Text(notif.body)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(notif.date, style: .time)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 6)
                        .background(
                            selectedNotifications.contains(notif.id)
                                ? Color.red.opacity(0.1)
                                : Color.clear
                        )
                        .cornerRadius(8)
                        .onLongPressGesture {
                            if selectedNotifications.contains(notif.id) {
                                selectedNotifications.remove(notif.id)
                            } else {
                                selectedNotifications.insert(notif.id)
                            }
                            showDeleteBar = !selectedNotifications.isEmpty
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }

            Spacer()
        }
        .navigationTitle("Bildirimler")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
        
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text("Geri")
                    }
                }
            }
           
            ToolbarItem(placement: .navigationBarTrailing) {
                Text(isNotificationsEnabled ? "Bildirim var" : "Bildirim yok")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
        }
     
        .alert(
            "\(selectedNotifications.count) bildirim silmek istediğinize emin misiniz?",
            isPresented: $showDeleteAlert
        ) {
            Button("Evet", role: .destructive) { deleteSelected() }
            Button("İptal", role: .cancel) {
                selectedNotifications.removeAll()
                showDeleteBar = false
            }
        }
        .onAppear(perform: fetchNotifications)
    }

    private func fetchNotifications() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users")
          .document(uid)
          .collection("notifications")
          .order(by: "timestamp", descending: true)
          .getDocuments { snapshot, error in
            if let error = error {
                print("📭 Bildirimler alınamadı: \(error)")
                return
            }

 
            let docs = snapshot?.documents ?? []

            
            let fetched: [AppNotification] = docs.compactMap { doc in
                let data = doc.data()
                let title = data["title"] as? String ?? ""
                let body  = data["body"]  as? String ?? ""
                let ts    = data["timestamp"] as? Timestamp
                return AppNotification(
                    id: doc.documentID,
                    title: title,
                    body: body,
                    date: ts?.dateValue() ?? Date()
                )
            }

            if !fetched.isEmpty {
                notifications = fetched
            }
        }
    }

    private func deleteSelected() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let batch = db.batch()
        let col = db.collection("users").document(uid).collection("notifications")

        selectedNotifications.forEach { id in
            batch.deleteDocument(col.document(id))
        }

        batch.commit { _ in
            notifications.removeAll { selectedNotifications.contains($0.id) }
            selectedNotifications.removeAll()
            showDeleteBar = false
        }
    }
}
