import SwiftUI

struct RootView: View {
    @State private var selectedTab = 0  // 🔁 Sekme kontrolü için gerekli

    var body: some View {
        MainTabView(selectedTab: $selectedTab)  // ✅ Parametre verildi
    }
}
