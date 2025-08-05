import SwiftUI

struct SettingsView: View {
    
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section(header: Text("Ses")) {
                Toggle("Ses Efektleri", isOn: $soundEnabled)
            }

            Section(header: Text("Görünüm")) {
                Toggle("Koyu Mod", isOn: $darkModeEnabled)
            }
        }
        .navigationTitle("Ayarlar")
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
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
#endif
