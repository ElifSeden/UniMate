import SwiftUI
import FirebaseAuth
import FirebaseFirestore


    struct ProfileView: View {
        @Binding var selectedTab: Int // ✅ TabView’dan geliyor

    @State private var name = ""
    @State private var surname = ""
    @State private var country = ""
    @State private var department = ""
    @State private var universityName = ""
    @State private var birthday = Date()
    @State private var email = Auth.auth().currentUser?.email ?? ""
    @State private var phone = ""
    @State private var showSavedMessage = false

    @Environment(\.dismiss) var dismiss  // ✅ Eklendi

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("ACCOUNT")) {
                    TextField("Name", text: $name)
                    TextField("Surname", text: $surname)
                    TextField("Email", text: $email).disabled(true)
                    TextField("Phone", text: $phone).keyboardType(.phonePad)
                }

                Section(header: Text("EDUCATION")) {
                    TextField("University", text: $universityName)
                    TextField("Department", text: $department)
                }

                Section(header: Text("PERSONAL")) {
                    TextField("Country", text: $country)
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                }

                Section {
                    Button(action: {
                        saveProfile()
                    }) {
                        Text("Kaydet")
                            .foregroundColor(.blue)
                    }

                    if showSavedMessage {
                        Text("✅ Bilgiler başarıyla kaydedildi.")
                            .foregroundColor(.green)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("My Profile")
        }
    }

    func saveProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "name": name,
            "surname": surname,
            "email": email,
            "phone": phone,
            "country": country,
            "department": department,
            "universityName": universityName,
            "birthday": Timestamp(date: birthday)
        ]) { error in
            if let error = error {
                print("❌ Kaydetme hatası: \(error.localizedDescription)")
            } else {
                print("✅ Kaydedildi")
                showSavedMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    selectedTab = 0  // ✅ HomeView sekmesine geç
  // ✅ Profil ekranını kapat ve HomeView’a dön
                }
            }
        }
    }
}
