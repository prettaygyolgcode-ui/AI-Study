import SwiftUI

struct AppView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: AppTab = .friends
    @State private var hasFinishedSplash = false
    @State private var didScheduleSplashTransition = false

    var body: some View {
        Group {
            switch LaunchFlow.route(
                hasFinishedSplash: hasFinishedSplash,
                isLoggedIn: appState.isLoggedIn
            ) {
            case .splash:
                SplashView()
                    .onAppear(perform: scheduleSplashTransition)
            case .login:
                LoginView(appState: appState)
                    .accessibilityIdentifier("loginRoot")
            case .home:
                homeView
                    .accessibilityIdentifier("mainRoot")
            }
        }
    }

    private var homeView: some View {
        TabView(selection: $selectedTab) {
            FriendsListView()
            .tabItem {
                Label(AppTab.friends.title, systemImage: AppTab.friends.systemImage)
            }
            .tag(AppTab.friends)

            CreateHubView()
            .tabItem {
                Label(AppTab.create.title, systemImage: AppTab.create.systemImage)
            }
            .tag(AppTab.create)

            PlazaView()
            .tabItem {
                Label(AppTab.plaza.title, systemImage: AppTab.plaza.systemImage)
            }
            .tag(AppTab.plaza)

            ProfileView()
            .tabItem {
                Label(AppTab.profile.title, systemImage: AppTab.profile.systemImage)
            }
            .tag(AppTab.profile)
        }
    }

    private func scheduleSplashTransition() {
        guard !didScheduleSplashTransition else { return }
        didScheduleSplashTransition = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.3)) {
                hasFinishedSplash = true
            }
        }
    }
}
