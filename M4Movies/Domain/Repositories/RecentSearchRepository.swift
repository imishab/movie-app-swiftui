import Foundation

@MainActor
protocol RecentSearchRepository {

    func recent(limit: Int) throws -> [RecentSearch]
    func save(keyword: String) throws
    func delete(keyword: String) throws
    func clearAll() throws
}
