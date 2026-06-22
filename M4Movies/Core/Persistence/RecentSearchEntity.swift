import CoreData

@objc(RecentSearchEntity)
final class RecentSearchEntity: NSManagedObject {

    @NSManaged var keyword: String
    @NSManaged var searchedAt: Date

    static func fetchRequest() -> NSFetchRequest<RecentSearchEntity> {
        NSFetchRequest<RecentSearchEntity>(entityName: "RecentSearchEntity")
    }

    static func makeEntityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "RecentSearchEntity"
        entity.managedObjectClassName = NSStringFromClass(RecentSearchEntity.self)

        let keyword = NSAttributeDescription()
        keyword.name = "keyword"
        keyword.attributeType = .stringAttributeType
        keyword.isOptional = false

        let searchedAt = NSAttributeDescription()
        searchedAt.name = "searchedAt"
        searchedAt.attributeType = .dateAttributeType
        searchedAt.isOptional = false

        entity.properties = [keyword, searchedAt]
        return entity
    }
}
