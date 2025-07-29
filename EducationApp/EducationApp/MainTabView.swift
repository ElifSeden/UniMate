import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

            PDFSummaryView()
                .tabItem {
                    Label("PDF", systemImage: "doc.text.magnifyingglass")
                }
                .tag(1)

            GeminiScreen()
                .tabItem {
                    Label("UniMate AI", systemImage: "sparkles")
                }
                .tag(2)

            CVInputView()
                .tabItem {
                    Label("CV", systemImage: "person.crop.rectangle")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}
