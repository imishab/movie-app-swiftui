import CoreData
import Foundation

@MainActor
final class FavoritesRepositoryImpl: FavoritesRepository {

    private let context: NSManagedObjectContext

    init(controller: PersistenceController = .shared) {
        self.context = controller.container.viewContext
    }

    func all() throws -> [Movie] {
        let request = FavoriteMovieEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "favoritedAt", ascending: false)]
        return try context.fetch(request).map { $0.toDomain() }
    }

    func add(_ movie: Movie) throws {
        let request = FavoriteMovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", movie.id)
        request.fetchLimit = 1

        let entity = try context.fetch(request).first ?? FavoriteMovieEntity(context: context)
        entity.id = Int64(movie.id)
        entity.title = movie.title
        entity.overview = movie.overview
        entity.posterPath = movie.posterPath
        entity.releaseDate = movie.releaseDate
        entity.voteAverage = movie.voteAverage
        entity.favoritedAt = Date()

        try saveIfNeeded()
    }

    func remove(id: Int) throws {
        let request = FavoriteMovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        for entity in try context.fetch(request) {
            context.delete(entity)
        }
        try saveIfNeeded()
    }

    private func saveIfNeeded() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}
