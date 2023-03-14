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
    func create(_ task: Task) async throws {
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
    
    func create(_ item: CheckItem) async throws {
        let t: TaskCD? = try await context.get(id: item.task)
        guard let _ = t else { return }
        try await context.perform {
            let entity = CheckItemCD(context: context)
            entity.id = item.id
            entity.title = item.title
            entity.creationDate = item.creationDate
            entity.modificationDate = item.modificationDate
            entity.index = Int16(item.index)
            entity.checked = item.checked
            
            try context.save()
        }
    }
    
    func create(_ tag: Tag) async throws {
        try await context.perform {
            let entity = TagCD(context: context)
            entity.id = tag.id
            entity.name = tag.name
            entity.parent = tag.parent
            entity.index = Int16(tag.index)
            try context.save()
        }
    }
    
    // MARK: - Update
    func update(_ task: Task, _ cmd: Task.Change) async throws {
        let entity: TaskCD? = try await context.get(id: task.id)
        try await context.perform {
            guard let entity = entity else {
                throw CoreDataError.entityNotFound
            }
            let task = task.alter(cmd)
            entity.title = task.title
            entity.notes = task.notes
            entity.creationDate = task.creationDate
            entity.date = task.date
            entity.dueDate = task.dueDate
            entity.index = Int16(task.index)
            entity.modificationDate = task.modificationDate
            entity.status = Int16(task.status.rawValue)
            entity.todayIndex = Int16(task.todayIndex)
            entity.trashed = task.trashed
            entity.type = Int16(task.type.rawValue)
            
            try context.save()
        }
    }
    
    func update(_ area: Area, _ cmd: Area.Change) async throws {
        let entity: AreaCD? = try await context.get(id: area.id)
        try await context.perform {
            guard let entity = entity else {
                throw CoreDataError.entityNotFound
            }
            
            let area = area.alter(cmd)
            entity.title = area.title
            entity.index = Int16(area.index)
            entity.visible = area.visible
            
            try context.save()
        }
    }
    
    func update(_ tag: Tag, _ cmd: Tag.Change) async throws {
        let entity: TagCD? = try await context.get(id: tag.id)
        try await context.perform {
            guard let entity = entity else {
                throw CoreDataError.entityNotFound
            }
            
            let tag = tag.alter(cmd)
            entity.name = tag.name
            entity.parent = tag.parent
            entity.index = Int16(tag.index)
            
            try context.save()
        }
    }
    
    // MARK: - Read
    func readTasks() async throws -> [Task] {
        try await context.get(request: TaskCD.fetchRequest())
    }
    
    func readAreas() async throws -> [Area] {
        try await context.get(request: AreaCD.fetchRequest())
    }
    
    func readTags() async throws -> [Tag] {
        try await context.get(request: TagCD.fetchRequest())
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
    
    func delete(tag: UUID) async throws {
        try await delete(TagCD.className, id: tag)
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
        String(describing: type(of: self))
    }
    
    class var className: String {
        String(describing: self)
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
