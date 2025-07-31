import SwiftUI
import FirebaseAuth

struct RootView: View {
    @StateObject var authViewModel = AuthViewModel()
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainTabView(selectedTab: $selectedTab)
                    .environmentObject(authViewModel)
            } else {
                AuthView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
