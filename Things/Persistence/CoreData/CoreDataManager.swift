//
//  CoreDataManager.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 13/03/2023.
//

import CoreData

struct CoreDataManager {
    
    let context: NSManagedObjectContext
    
    // MARK: - Create
    func create(_ task: ToDo) async throws {
        try await context.perform {
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
            
            try context.save()
        }
    }
    
    func create(_ area: Area) async throws {
        try await context.perform {
            let entity = AreaCD(context: context)
            entity.id = area.id
            entity.title = area.title
            entity.visible = area.visible
            entity.index = Int16(area.index)
            
            try context.save()
        }
    }
    
    func create(_ checkList: CheckItem) async throws {
        try await context.perform {
            let entity = CheckItemCD(context: context)
            entity.id = checkList.id
            entity.title = checkList.title
            entity.creationDate = checkList.creationDate
            entity.modificationDate = checkList.modificationDate
            entity.index = Int16(checkList.index)
            entity.checked = checkList.checked
            
            try context.save()
        }
    }
    
    // MARK: - Update
    
    // MARK: - Read
    func readTasks() async throws -> [ToDo] {
        try await context.get(request: TaskCD.fetchRequest())
    }
    
    func readAreas() async throws -> [Area] {
        try await context.get(request: AreaCD.fetchRequest())
    }
    
    func readCheckItems() async throws -> [CheckItem] {
        try await context.get(request: CheckItemCD.fetchRequest())
    }
  
    // MARK: - Delete
    func delete(task: UUID) async throws {
        try await delete(TaskCD.className, id: task)
    }
    
    func delete(area: UUID) async throws {
        try await delete(AreaCD.className, id: area)
    }
    
    func delete(checkItem: UUID) async throws {
        try await delete(CheckItemCD.className, id: checkItem)
    }
    
    @discardableResult
    private func delete<T: NSManagedObject>(_ entityName: String, id: UUID) async throws -> T? {
        try await context.delete(entityName, id: id)
    }
}



// @todo: move to their own file
extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}

extension Sequence {
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}
