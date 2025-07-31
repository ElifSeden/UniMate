import SwiftUI

struct MainTabView: View {
    @Binding var selectedTab: Int

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

            PDFSummaryView()
                .tabItem {
                    Label("PDF", systemImage: "doc.text.magnifyingglass")
                }
                .tag(1)
            
            QuizMainView()
                .tabItem {
                    Label("Quiz", systemImage: "checklist")
                }
                .tag(4)


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
