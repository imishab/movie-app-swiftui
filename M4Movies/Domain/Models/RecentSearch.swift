import Foundation

struct RecentSearch: Identifiable, Hashable {

    let keyword: String
    let searchedAt: Date

    var id: String { keyword.lowercased() }
}
