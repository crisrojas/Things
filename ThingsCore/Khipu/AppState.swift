//
//  AppState.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 09/03/2023.
//

import Foundation

// MARK: - App State
public struct AppState: Codable {
    public let tasks : [Task]
    public let areas : [Area]
    public let  tags : [Tag]
    public let items : [Item]
}

extension AppState: Equatable {}

public extension AppState {
    init(
        _ tasks : [Task] = [],
        _ areas : [Area] = [],
        _ tags  : [Tag ] = [],
        _ items : [Item] = []
    ) {
        self.tasks = tasks
        self.areas = areas
        self.tags  = tags
        self.items = items
    }
}

// MARK: - DSL APi
public extension AppState {
   
    enum Change {
        case create(Create)
        case update(Update)
        case delete(Delete)
        
        public enum Create {
            case task(Task)
            case area(Area)
            case  tag(Tag )
            case item(Item)
        }
        
        public enum Update {
            case task(Task, with: Task.Change)
            case area(Area, with: Area.Change)
            case  tag( Tag, with:  Tag.Change)
            case item(Item, with: Item.Change)
        }
        
        public enum Delete {
            case task(Task)
            case area(Area)
            case  tag(UUID)
            case item(Item)
        }
    }
}

extension AppState {
    func alter(_ c: [Change]) -> Self {c.reduce(self){$0.alter($1)}}
    func alter(_ c: Change...) -> Self {alter(c)}
    func alter(_ change: Change) -> Self {
        switch change {
        case .create(let command): return handle(command)
        case .update(let command): return handle(command)
        case .delete(let command): return handle(command)
        }
    }
    
    private func handle(_ cmd: Change.Create) -> Self {
        switch cmd {
        case .task(let task):
            return .init(tasks + [task], areas, tags, items)
        case .area(let area):
            return .init(tasks, areas + [area], tags, items)
        case .tag(let tag):
            return .init(tasks, areas, tags + [tag], items)
        case .item(let item):
            if let task = tasks.filter({$0.id == item.task}).first {
                let task = task.alter(.add(.checkItem(item.id)))
                let tasks = tasks.filter {$0.id != task.id} + [task]
                let checkItems = items + [item]
                return .init(tasks, areas, tags, checkItems)
            }
            return self
        }
    }
    
    private func handle(_ cmd: Change.Update) -> Self {
        switch cmd {
        case .task(let task, let command):
            
            if command == .type(.project) {
                return handleConvertToProject(task: task)
            } else {
                
                let task = task.alter(command)
                let tasks = tasks.filter { $0.id != task.id } + [task]
                return .init(tasks, areas, tags, items)
            }
            
        case .area(let area, let command):
            let area = area.alter(command)
            let areas = areas.filter { $0.id != area.id } + [area]
            return .init(tasks, areas, tags, items)
        case .tag(let tag, let command):
            let tag = tag.alter(command)
            let tags = tags.filter { $0.id != tag.id } + [tag]
            return .init(tasks, areas, tags, items)
        case .item(let item, let command):
            let item = item.alter(command)
            let items = items.filter { $0.id != item.id } + [item]
            return .init(tasks, areas, tags, items)
        }
    }
    
    private func handle(_ cmd: Change.Delete) -> Self {
        switch cmd {
        case .task(let task):
            return .init(
                tasks.filter { $0.id != task.id},
                areas,
                tags
            )
        case .area(let area):
            return .init(
                tasks,
                areas.filter { $0.id != area.id},
                tags
            )
        case .tag(let tag):
            
            let previouslyTaggedTasks = tasks
                .filter {$0.tags.contains(tag)}
                .map { $0.alter(.remove(.tag(tag))) }
            
            let tasks = tasks.filter { !$0.tags.contains(tag) }
            + previouslyTaggedTasks
            
            let previouslyTaggedAreas = areas
                .filter {$0.tags.contains(tag)}
                .map { $0.alter(.removeTag(tag)) }
            
            let areas = areas.filter { !$0.tags.contains(tag) }
            + previouslyTaggedAreas
            
            
            return .init(
                tasks,
                areas,
                tags.filter { $0.id != tag }
            )
        case .item(let item):
           
            var tasks = tasks
            if let task = tasks.filter({ $0.id == item.task }).first {
                let task = task.alter(.remove(.checkItem(item.id)))
                tasks = tasks.filter { $0.id != item.task } + [task]
            }
            
            return .init(
                tasks,
                areas,
                tags,
                items.filter { $0.id != item.id }
            )
        }
    }
    
    private func handleConvertToProject(task: Task) -> AppState {
        switch task.type {
        case .task:
            
            let subtasks = items
                .filter { $0.task == task.id }
                .map {$0.toTask()}
            
            let project = task.alter(
                .type(.project),
                .remove(.checkList)
            )
            let tasks = tasks.filter { $0.id != task.id }
            + [project]
            + subtasks

            return .init(tasks, areas, tags)
            
        case .heading:
            let subtasks = tasks
                .filter { $0.actionGroup == task.id }
                .map { $0.alter(.remove(.actionGroup)) }
            
            let project = task.alter(.type(.project))
            
            let tasks = subtasks
                .reduce(tasks) {$0.remove($1)} // Remove old subtasks
                .filter { $0.id != task.id }   // Remove old task
            + [project]
            + subtasks
            
            return .init(tasks, areas, tags)
           
        case .project: return self
        }
    }
}
