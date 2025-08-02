import SwiftUI

struct SettingsView: View {
    // 1️⃣ Ayarları kalıcı saklamak için AppStorage kullanıyoruz
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage: String = Locale.current.languageCode ?? "tr"
    
    // 2️⃣ Desteklediğimiz diller
    private let languages = [
        "tr": "Türkçe",
        "en": "English"
    ]
    
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
        .onChange(of: selectedLanguage) { newLang in
            // TODO: Lokalizasyon kaynaklarını yeniden yükle, view’ları güncelle
            print("Yeni dil: \(newLang)")
        }
    }
}

