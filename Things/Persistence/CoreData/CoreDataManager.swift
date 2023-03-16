//
//  CoreDataManager.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 13/03/2023.
//

import CoreData

struct CoreDataManager: PersistenceManager {
    
    let context: NSManagedObjectContext
    
    // MARK: - Create
    func create(_ task: Task) async throws {
        try await context.perform {
            let _ = task.toTaskCD(with: context)
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
    
    /// Creates item only if associated tasks exists
    /// Appends the item to the associated CoreData Task entity
    func create(_ item: CheckItem) async throws {
        let t: TaskCD? = try await context.get(id: item.task)
        guard let t = t else { return }
        try await context.perform {
            let entity = CheckItemCD(context: context)
            entity.id = item.id
            entity.title = item.title
            entity.creationDate = item.creationDate
            entity.modificationDate = item.modificationDate
            entity.index = Int16(item.index)
            entity.checked = item.checked
            entity.task = item.task
            
        
            t.checkList = (t.checkList ?? []).add(item.id)
        
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
            try save()
        }
    }
    
    // MARK: - Update
    func update(_ task: Task, _ cmd: Task.Change) async throws {
        let entity: TaskCD? = try await context.get(id: task.id)
        try await context.perform {
            guard let entity = entity else {
                throw CoreDataError.entityNotFound
            }
            
            let items = task.checkList
            let oldType = task.type
            let task = task.alter(cmd)

            entity.title = task.title
            entity.notes = task.notes
            entity.date = task.date
            entity.dueDate = task.dueDate
            entity.index = Int16(task.index)
            entity.modificationDate = task.modificationDate
            entity.status = Int16(task.status.rawValue)
            entity.todayIndex = Int16(task.todayIndex)
            entity.trashed = task.trashed
            entity.type = Int16(task.type.rawValue)
            entity.area = task.area
            entity.project = task.project
            entity.tags = task.tags
            entity.checkList = task.checkList
            entity.actionGroup = task.actionGroup
            
            // If we're converting to a project
            if cmd == .type(.project) {
                
                // If we're converting a task to a project
                // Create new tasks for each associated item (if uncompleted)
                // Remove items from table
                if oldType == .task {
                    let _ = try items
                        .compactMap { item in
                            let r = CheckItemCD.fetchRequest()
                            r.predicate = NSPredicate(
                                format: "id == %@",
                                item as CVarArg
                            )
                            
                            return try context.fetch(r).first
                        }
                        .map { (c: CheckItemCD) -> (TaskCD) in
                            let safe = try c.safeObject()
                            context.delete(c)
                            return safe
                                .toTask()
                                .toTaskCD(with: context)
                        }
                }
                
                // If we're converting a heading (oldTask) to a project
                // Remove associated tasks actionGroup property
                // Asign  associated tasks project property to oldTask.id
                if oldType == .heading {
                    let r = TaskCD.fetchRequest()
                    r.predicate = NSPredicate(
                        format: "actionGroup == %@",
                        task.id as CVarArg
                    )
                    
                    let subtasks = try context.fetch(r)
                    
                    subtasks.forEach {
                        $0.actionGroup = nil
                        $0.project = task.id
                    }
                }
            }
            
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
            entity.tags = area.tags
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
    
    func update(_ item: CheckItem, _ cmd: CheckItem.Change) async throws {
        let entity: CheckItemCD? = try await context.get(id: item.id)
        try await context.perform {
            guard let entity = entity else {
                throw CoreDataError.entityNotFound
            }
            
            let item = item.alter(cmd)
            entity.modificationDate = item.modificationDate
            entity.checked = item.checked
            entity.title = item.title
            entity.index = Int16(item.index)
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
    
    
    // MARK: - Complex deletion
    /// @todo: I made the full implementation on the body because
    /// I was getting a Thread BAD ACCESS Error when composing methods
    /// @todo: Find a better way of fetching ONLY tasks and areas that contains the tag
    func delete(tag: UUID) async throws {
        try await context.perform { [weak context] in
            guard let context = context else { return }
            
            let r1 = TagCD.fetchRequest()
            r1.fetchLimit = 1
            r1.predicate = NSPredicate(
                format: "id == %@",
                tag as CVarArg
            )
            
            guard let tagCD = try context.fetch(r1).first else {
                throw CoreDataError.entityNotFound
            }
            
//            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag.uuidString)
            
            let r2 = TaskCD.fetchRequest()
//            r2.predicate = tagPredicate
            
            let r3 = AreaCD.fetchRequest()
//            r2.predicate =  tagPredicate
            
            let taggedTasks = try context.fetch(r2).filter {
                ($0.tags ?? []).contains(tag)
            }
            
            let taggedAreas = try context.fetch(r3).filter {
                ($0.tags ?? []).contains(tag)
            }
            
            taggedTasks.forEach { task in
                task.tags = task.tags?.filter { $0 != tag }
            }
            
            taggedAreas.forEach { area in
                area.tags = area.tags?.filter { $0 != tag }
            }
            
            try context.save()
            context.delete(tagCD)
        }
    }
    
    
    func delete(checkItem: UUID) async throws {
        try await context.perform {
            
            let r1 = CheckItemCD.fetchRequest()
            r1.fetchLimit = 1
            r1.predicate = NSPredicate(
                format: "id == %@",
                checkItem as CVarArg
            )
            
            guard
                let checkItemCD = try context.fetch(r1).first,
                let taskId = checkItemCD.task
            else {
                throw CoreDataError.entityNotFound
            }
            
            let r2 = TaskCD.fetchRequest()
            r2.fetchLimit = 1
            r2.predicate = NSPredicate(
                format: "id == %@",
                taskId as CVarArg
            )
            
            guard let taskCD = try context.fetch(r2).first else {
                throw CoreDataError.entityNotFound
            }
            
            let task = try taskCD.safeObject().alter(.remove(.checkItem(checkItem)))
            
            taskCD.checkList = task.checkList
            try context.save()
            context.delete(checkItemCD)
        }
    }
    
    @discardableResult
    private func delete<T: NSManagedObject>(_ entityName: String, id: UUID) async throws -> T? {
        try await context.delete(entityName, id: id)
    }
    
    
    private func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    func destroy() {}
}
