import Foundation

@MainActor
@Observable
final class FavoritesStore {

    private(set) var favorites: [Movie] = []
    private var favoriteIDs: Set<Int> = []

    private let repository: FavoritesRepository

    init(repository: FavoritesRepository? = nil) {
        self.repository = repository ?? FavoritesRepositoryImpl()
        reload()
    }

    func isFavorite(_ id: Int) -> Bool {
        favoriteIDs.contains(id)
    }

    func toggle(_ movie: Movie) {
        if favoriteIDs.contains(movie.id) {
            remove(id: movie.id)
        } else {
            add(movie)
        }
    }

    private func add(_ movie: Movie) {
        try? repository.add(movie)
        favorites.removeAll { $0.id == movie.id }
        favorites.insert(movie, at: 0)
        favoriteIDs.insert(movie.id)
    }

    private func remove(id: Int) {
        try? repository.remove(id: id)
        favorites.removeAll { $0.id == id }
        favoriteIDs.remove(id)
    }

    private func reload() {
        let loaded = (try? repository.all()) ?? []
        favorites = loaded
        favoriteIDs = Set(loaded.map(\.id))
    }
}
