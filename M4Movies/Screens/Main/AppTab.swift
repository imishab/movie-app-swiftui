import Foundation

enum AppTab: Int, Hashable, Identifiable, CaseIterable {

    case home
    case search
    case favorites
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home:      "Home"
        case .search:    "Search"
        case .favorites: "Favorites"
        case .settings:  "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home:      "house"
        case .search:    "magnifyingglass"
        case .favorites: "heart"
        case .settings:  "gearshape"
        }
    }
}
