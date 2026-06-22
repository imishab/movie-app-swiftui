import SwiftUI

struct MainTabView: View {

    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.home.title,
                systemImage: AppTab.home.systemImage,
                value: .home) {
                HomeView()
            }

            Tab(AppTab.search.title,
                systemImage: AppTab.search.systemImage,
                value: .search) {
                SearchView()
            }

            Tab(AppTab.favorites.title,
                systemImage: AppTab.favorites.systemImage,
                value: .favorites) {
                FavoritesView()
            }

            Tab(AppTab.settings.title,
                systemImage: AppTab.settings.systemImage,
                value: .settings) {
                SettingsView()
            }
        }
    }
}

#Preview {
    MainTabView()
}
