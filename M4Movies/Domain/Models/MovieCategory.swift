import Foundation

enum MovieCategory: String, CaseIterable, Identifiable, Hashable {

    case popular
    case nowPlaying
    case topRated
    case upcoming

    var id: String { rawValue }

    var title: String {
        switch self {
        case .popular:    "Popular"
        case .nowPlaying: "Now Playing"
        case .topRated:   "Top Rated"
        case .upcoming:   "Upcoming"
        }
    }

    var path: String {
        switch self {
        case .popular:    "popular"
        case .nowPlaying: "now_playing"
        case .topRated:   "top_rated"
        case .upcoming:   "upcoming"
        }
    }
}
