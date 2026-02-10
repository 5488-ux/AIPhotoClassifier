import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showFloatingChat = false
    @State private var floatingButtonPosition = CGPoint(x: UIScreen.main.bounds.width - 80, y: UIScreen.main.bounds.height - 150)

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("主页", systemImage: "house.fill")
                    }
                    .tag(0)

                ProfileView()
                    .tabItem {
                        Label("我的", systemImage: "person.fill")
                    }
                    .tag(1)
            }

            // Floating AI Button
            FloatingAIButton(
                position: $floatingButtonPosition,
                showChat: $showFloatingChat
            )
        }
        .sheet(isPresented: $showFloatingChat) {
            AIChatView()
        }
    }
}
