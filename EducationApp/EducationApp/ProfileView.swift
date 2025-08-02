import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @Binding var selectedTab: Int

    @State private var name = ""
    @State private var surname = ""
    @State private var phone = ""
    @State private var universityName = ""
    @State private var department = ""
    @State private var selectedCountry = ""
    @State private var birthday = Date()
    @State private var showValidationAlert = false
    @State private var showSavedAlert = false

    @Environment(\.dismiss) private var dismiss

    private let countries: [String] = [
        "Almanya","Andorra","Arnavutluk","Avusturya","Belçika","Beyaz Rusya",
        "Bosna-Hersek","Bulgaristan","Çekya","Danimarka","Estonya","Finlandiya",
        "Fransa","Hırvatistan","İrlanda","İngiltere","İspanya","İsveç","İsviçre",
        "İtalya","Kosova","Letonya","Liechtenstein","Litvanya","Lüksemburg",
        "Macaristan","Makedonya","Malta","Moldova","Monako","Karadağ","Hollanda",
        "Norveç","Polonya","Portekiz","Romanya","Rusya","San Marino","Sırbistan",
        "Slovakya","Slovenya","Ukrayna","Vatikan","Türkiye","Diğer"
    ]

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !surname.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty &&
        !universityName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !department.trimmingCharacters(in: .whitespaces).isEmpty &&
        !selectedCountry.isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Hesap Bilgileri")) {
                    TextField("Adınız", text: $name)
                    TextField("Soyadınız", text: $surname)
                    TextField("Telefon Numarası", text: $phone)
                        .keyboardType(.phonePad)
                }

                Section(header: Text("Eğitim Bilgileri")) {
                    TextField("Üniversite", text: $universityName)
                    TextField("Bölüm", text: $department)
                }

                Section(header: Text("Kişisel Bilgiler")) {
                    Picker("Ülke", selection: $selectedCountry) {
                        Text("Ülke seçin").tag("")
                        ForEach(countries, id: \.self) { country in
                            Text(country).tag(country)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    DatePicker("Doğum Tarihi", selection: $birthday, displayedComponents: .date)
                }

                Section {
                    Button("Kaydet") {
                        if isFormValid {
                            saveProfile()
                        } else {
                            showValidationAlert = true
                        }
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Profilim")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Lütfen tüm alanları eksiksiz doldurun.", isPresented: $showValidationAlert) {
                Button("Tamam", role: .cancel) { }
            }
            .alert(
                "Bilgiler başarıyla kaydedildi",
                isPresented: $showSavedAlert,
                actions: {
                    Button("Tamam") {
                        selectedTab = 0
                        dismiss()
                    }
                },
                message: { Text("Profil bilgileriniz güncellendi.") }
            )
            .onAppear {
                loadProfile() // ✅ Kayıtlı bilgileri geri yükle
            }
        }
    }

    private func saveProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let data: [String: Any] = [
            "name": name,
            "surname": surname,
            "phone": phone,
            "universityName": universityName,
            "department": department,
            "country": selectedCountry,
            "birthday": Timestamp(date: birthday),
            "email": Auth.auth().currentUser?.email ?? ""
        ]

        Firestore.firestore().collection("users").document(uid).setData(data) { error in
            if let error = error {
                print("❌ Kaydetme hatası: \(error.localizedDescription)")
            } else {
                showSavedAlert = true
            }
        }
    }

    private func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.name = data["name"] as? String ?? ""
                self.surname = data["surname"] as? String ?? ""
                self.phone = data["phone"] as? String ?? ""
                self.universityName = data["universityName"] as? String ?? ""
                self.department = data["department"] as? String ?? ""
                self.selectedCountry = data["country"] as? String ?? ""
                if let timestamp = data["birthday"] as? Timestamp {
                    self.birthday = timestamp.dateValue()
                }
            }
        }
    }
}
