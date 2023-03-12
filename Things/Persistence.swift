//
//  Persistence.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//

import CoreData

struct PersistenceController {
    
    static let shared = PersistenceController()
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    static func get(inMemory: Bool) -> Self {
        if inMemory { return preview }
        else { return shared }
    }
    
    func context() -> NSManagedObjectContext {container.viewContext}

    let container: NSPersistentCloudKitContainer

    private init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Things")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

struct CoreDataManager {
    
    let context: NSManagedObjectContext
    
    func create(_ task: ToDo) {
        context.perform {
            let entity = TaskCD(context: context)
            entity.id = task.id
            entity.creationDate = task.creationDate
            entity.modificationDate = task.modificationDate
            entity.dueDate = task.dueDate
            entity.title = task.title
            entity.notes = task.notes
            entity.type = Int16(task.type.rawValue)
            entity.status = Int16(task.status.rawValue)
            entity.index = Int16(task.index)
            entity.todayIndex = Int16(task.todayIndex)
            entity.trashed = task.trashed
            
            try? context.save()
        }
    }
    
    func readTasks() async throws -> [ToDo] {
        try await withCheckedThrowingContinuation { c in
            readTasks { r in
                switch r {
                case .success(let tasks): c.resume(with: .success(tasks))
                case .failure(let error): c.resume(with: .failure(error))
                }
            }
        }
    }
    
    func readTasks(completion: @escaping (Result<[ToDo], Error>) -> ()) {
        do {
            let request: NSFetchRequest<TaskCD> = TaskCD.fetchRequest()
            let result: [TaskCD] = try context.fetch(request)
            let items = try result.map { try $0.safeObject() }
            completion(.success(items))
        } catch {
            completion(.failure(error))
        }
        
    }

}


@available(iOS 15.0.0, *)
extension NSManagedObjectContext {
    func get<E, R>(request: NSFetchRequest<E>) async throws -> [R] where E: NSManagedObject, E: ToSafeObject, R == E.SafeType {
        try await self.perform { [weak self] in
            try self?.fetch(request).compactMap { try $0.safeObject() } ?? []
        }
    }
}

enum CoreDataError: Error {
    case invalidMapping
}

protocol ToSafeObject {
    associatedtype SafeType
    func safeObject() throws -> SafeType
}

extension TaskCD: ToSafeObject {
    
    typealias SafeType = ToDo
    
    func safeObject() throws -> ToDo {
        guard
            let id = id,
            let creationDate = creationDate,
            let title = title,
            let notes = notes,
            let type = ToDo.ListType(rawValue: Int(type)),
            let status = ToDo.Status(rawValue: Int(status))
        else { throw CoreDataError.invalidMapping }
        
        return .init(
            id,
            creationDate,
            modificationDate,
            date,
            dueDate,
            nil,
            nil,
            nil,
            title,
            notes,
            [],
            [],
            type,
            status,
            Int(index),
            Int(todayIndex),
            trashed,
            nil // @todo
        )
    }
}
