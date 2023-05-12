//
//  Persistence.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//

import CoreData

final class PersistenceController {
    
    static let shared = PersistenceController()
    static var preview: PersistenceController = {.init(inMemory: true)}()
    
    static func get(inMemory: Bool) -> PersistenceController {
        if inMemory { return preview }
        else { return shared }
    }
    
    func context() -> NSManagedObjectContext {container.viewContext}
    var container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
         
        container = NSPersistentCloudKitContainer(name: "Things", managedObjectModel: managedObjectModel)
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func destroy() {
        
        // Delete each existing persistent store
        let storeContainer = container.persistentStoreCoordinator
        for store in storeContainer.persistentStores {
            try? storeContainer.destroyPersistentStore(
                at: store.url!,
                ofType: store.type,
                options: nil
            )
        }
        
        // Re-create the persistent container
        container = NSPersistentCloudKitContainer(name: "Things")
        
        // Calling loadPersistentStores will re-create the
        container.loadPersistentStores {(_, _) in}
    }
}

fileprivate var managedObjectModel: NSManagedObjectModel = {
    let frameworkBundleIdentifier = "lat.cristian.ThingsCore"
    let customKitBundle = Bundle(identifier: frameworkBundleIdentifier)!
    let modelURL = customKitBundle.url(forResource: "Things", withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
}()
