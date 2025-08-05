import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        MainTabView(selectedTab: $selectedTab)  
    }
}

#Preview {
    ContentView()
}
