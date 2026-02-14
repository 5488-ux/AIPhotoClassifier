import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showFloatingChat = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("主页", systemImage: "photo.on.rectangle.angled")
                    }
                    .tag(0)

                ProfileView()
                    .tabItem {
                        Label("我的", systemImage: "person.crop.circle")
                    }
                    .tag(1)
            }
            .tint(.appPrimary)

            // Floating AI Button
            Button {
                showFloatingChat = true
            } label: {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        LinearGradient(
                            colors: [.appPrimary, .appSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: .appPrimary.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 80)
        }
        .sheet(isPresented: $showFloatingChat) {
            AIChatView()
        }
    }
}
