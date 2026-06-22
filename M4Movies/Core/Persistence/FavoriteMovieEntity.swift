import CoreData

@objc(FavoriteMovieEntity)
final class FavoriteMovieEntity: NSManagedObject {

    @NSManaged var id: Int64
    @NSManaged var title: String
    @NSManaged var overview: String
    @NSManaged var posterPath: String?
    @NSManaged var releaseDate: String
    @NSManaged var voteAverage: Double
    @NSManaged var favoritedAt: Date

    static func fetchRequest() -> NSFetchRequest<FavoriteMovieEntity> {
        NSFetchRequest<FavoriteMovieEntity>(entityName: "FavoriteMovieEntity")
    }

    static func makeEntityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "FavoriteMovieEntity"
        entity.managedObjectClassName = NSStringFromClass(FavoriteMovieEntity.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .integer64AttributeType
        id.isOptional = false

        let title = NSAttributeDescription()
        title.name = "title"
        title.attributeType = .stringAttributeType
        title.isOptional = false

        let overview = NSAttributeDescription()
        overview.name = "overview"
        overview.attributeType = .stringAttributeType
        overview.isOptional = false

        let posterPath = NSAttributeDescription()
        posterPath.name = "posterPath"
        posterPath.attributeType = .stringAttributeType
        posterPath.isOptional = true

        let releaseDate = NSAttributeDescription()
        releaseDate.name = "releaseDate"
        releaseDate.attributeType = .stringAttributeType
        releaseDate.isOptional = false

        let voteAverage = NSAttributeDescription()
        voteAverage.name = "voteAverage"
        voteAverage.attributeType = .doubleAttributeType
        voteAverage.isOptional = false

        let favoritedAt = NSAttributeDescription()
        favoritedAt.name = "favoritedAt"
        favoritedAt.attributeType = .dateAttributeType
        favoritedAt.isOptional = false

        entity.properties = [id, title, overview, posterPath, releaseDate, voteAverage, favoritedAt]
        entity.uniquenessConstraints = [["id"]]
        return entity
    }
}

extension FavoriteMovieEntity {

    func toDomain() -> Movie {
        Movie(
            id: Int(id),
            title: title,
            overview: overview,
            posterPath: posterPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage
        )
    }
}
