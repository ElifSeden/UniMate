import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var name = ""
    @State private var email = Auth.auth().currentUser?.email ?? ""
    @State private var phone = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .disabled(true)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }

                Section {
                    Button("Logout") {
                        do {
                            try Auth.auth().signOut()
                        } catch {
                            print("Logout failed: \(error.localizedDescription)")
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("My Profile")
        }
    }
}
