import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// Basit notification modeli
struct AppNotification: Identifiable {
    let id: String
    let title: String
    let body: String
    let date: Date
}

struct NotificationsView: View {
    @State private var notifications: [AppNotification] = []
    @State private var isNotificationsEnabled: Bool = UserDefaults.standard.bool(forKey: "isNotificationsEnabled")
    @State private var isEditing = false
    @State private var selectedNotifications = Set<String>()
    @State private var editMode: EditMode = .inactive  // ← Düzenleme modu için state
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Toggle + Seç / İptal butonu
            VStack(spacing: 0) {
                HStack {
                    Text("Bildirimleri Aç/Kapat")
                        .font(.subheadline)
                    Spacer()
                    Toggle("", isOn: $isNotificationsEnabled)
                        .labelsHidden()
                        .onChange(of: isNotificationsEnabled) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "isNotificationsEnabled")
                            // UNUserNotificationCenter güncellemesi ekleyebilirsin
                        }
                }
                .padding()
                .background(Color(.systemGray6))
                
                HStack {
                    Spacer()
                    Button(isEditing ? "İptal" : "Seç") {
                        withAnimation {
                            isEditing.toggle()
                            editMode = isEditing ? .active : .inactive
                            if !isEditing {
                                selectedNotifications.removeAll()
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    Spacer()
                }
                .background(Color(.systemGray6))
            }

            // Bildirim listesi veya boş mesaj
            if notifications.isEmpty {
                Spacer()
                Text("Geçmiş bildiriminiz bulunmamaktadır")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List(selection: $selectedNotifications) {
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
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }

            // Alt butonlar: Tümünü sil / Seçilenleri sil
            if !notifications.isEmpty {
                HStack {
                    Button("Tüm bildirimleri sil") {
                        deleteAll()
                    }
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    if isEditing {
                        Button("Seçilenleri Sil (\(selectedNotifications.count))") {
                            deleteSelected()
                        }
                        .foregroundColor(.red)
                        .disabled(selectedNotifications.isEmpty)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
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
        // İşte buraya:
        .environment(\.editMode, $editMode)
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
            notifications = snapshot?.documents.compactMap { doc in
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
            } ?? []
        }
    }

    private func deleteAll() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let batch = db.batch()
        let col = db.collection("users").document(uid).collection("notifications")
        notifications.forEach { notif in
            batch.deleteDocument(col.document(notif.id))
        }
        batch.commit { error in
            if let error = error {
                print("❌ Tümünü silme hatası: \(error)")
            } else {
                notifications.removeAll()
                selectedNotifications.removeAll()
                isEditing = false
                editMode = .inactive
            }
        }
    }

    private func deleteSelected() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let col = db.collection("users").document(uid).collection("notifications")
        selectedNotifications.forEach { id in
            col.document(id).delete { error in
                if let error = error {
                    print("❌ Silme hatası (\(id)): \(error)")
                }
            }
        }
        notifications.removeAll { selectedNotifications.contains($0.id) }
        selectedNotifications.removeAll()
        isEditing = false
        editMode = .inactive
    }
}
