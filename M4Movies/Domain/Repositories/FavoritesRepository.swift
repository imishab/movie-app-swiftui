import Foundation

@MainActor
protocol FavoritesRepository {

    func all() throws -> [Movie]
    func add(_ movie: Movie) throws
    func remove(id: Int) throws
}
