import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            PDFSummaryView() // PDF özetleme ekranı
                .tabItem {
                    Label("PDF", systemImage: "doc.text.magnifyingglass")
                }

            GeminiScreen() // Gemini AI ekranı
                .tabItem {
                    Label("Gemini", systemImage: "sparkles")
                }

            CVScreen() // CV rehberi ekranı
                .tabItem {
                    Label("CV", systemImage: "person.crop.rectangle")
                }
        }
        .accentColor(.blue) // Alt çubuğun seçili rengi
    }
}

