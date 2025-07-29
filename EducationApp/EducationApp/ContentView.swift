import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0  // ✅ Sekme kontrolü için gerekli

    var body: some View {
        MainTabView(selectedTab: $selectedTab)  // ✅ Gerekli parametre verildi
    }
}

#Preview {
    ContentView()
}
