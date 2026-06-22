import CoreData
import Foundation

@MainActor
final class RecentSearchRepositoryImpl: RecentSearchRepository {

    private let context: NSManagedObjectContext
    private let maxItems = 10

    init(controller: PersistenceController = .shared) {
        self.context = controller.container.viewContext
    }

    func recent(limit: Int) throws -> [RecentSearch] {
        let request = RecentSearchEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "searchedAt", ascending: false)]
        request.fetchLimit = limit
        return try context.fetch(request).map {
            RecentSearch(keyword: $0.keyword, searchedAt: $0.searchedAt)
        }
    }

    func save(keyword: String) throws {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        try deleteMatches(keyword: trimmed)

        let entity = RecentSearchEntity(context: context)
        entity.keyword = trimmed
        entity.searchedAt = Date()

        try enforceCap()
        try saveIfNeeded()
    }

    func delete(keyword: String) throws {
        try deleteMatches(keyword: keyword)
        try saveIfNeeded()
    }

    func clearAll() throws {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "RecentSearchEntity")
        let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
        batchDelete.resultType = .resultTypeObjectIDs

        let result = try context.execute(batchDelete) as? NSBatchDeleteResult
        if let objectIDs = result?.result as? [NSManagedObjectID] {
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                into: [context]
            )
        }
    }

    private func deleteMatches(keyword: String) throws {
        let request = RecentSearchEntity.fetchRequest()
        request.predicate = NSPredicate(format: "keyword ==[c] %@", keyword)
        for entity in try context.fetch(request) {
            context.delete(entity)
        }
    }

    private func enforceCap() throws {
        let request = RecentSearchEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "searchedAt", ascending: false)]
        let all = try context.fetch(request)
        guard all.count > maxItems else { return }
        for excess in all.dropFirst(maxItems) {
            context.delete(excess)
        }
    }

    private func saveIfNeeded() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}
