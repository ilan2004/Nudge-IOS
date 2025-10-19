import Foundation
import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init() {
        // Minimal in-memory Core Data stack using an empty model so the app can compile/run without a .xcdatamodeld
        let model = NSManagedObjectModel()
        container = NSPersistentContainer(name: "Nudge", managedObjectModel: model)

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, _ in }
    }
}

