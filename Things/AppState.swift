//
//  AppState.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 09/03/2023.
//

import Foundation

// MARK: - App State
struct AppState: Codable {
    let tasks     : [Task]
    let areas     : [Area]
    let tags      : [Tag]
}

extension AppState {
    init(
        _ tasks     : [Task] = [],
        _ areas     : [Area] = [],
        _ tags      : [Tag]  = []
    ) {
        self.tasks = tasks
        self.areas = areas
        self.tags = tags
    }
}

// MARK: - DSL APi
extension AppState {
   
    enum Change {
        case create(Create)
        case update(Update)
        case delete(Delete)
        
        enum Create {
            case task(Task)
            case area(Area)
            case tag(Tag)
            case checkItem(CheckItem, on: Task)
        }
        
        enum Update {
            case task(Task, with: Task.Change)
            case area(Area, with: Area.Change)
            case tag(Tag, with: Tag.Change)
        }
        
        enum Delete {
            case task(Task)
            case area(Area)
            case tag(Tag)
        }
    }
}

extension AppState {
    func alter(_ change: Change) -> Self {
        switch change {
        case .create(let command): return handle(command)
        case .update(let command): return handle(command)
        case .delete(let command): return handle(command)
        }
    }
    
    private func handle(_ createCommand: Change.Create) -> Self {
        switch createCommand {
        case .task(let task):
            return .init(tasks + [task], areas, tags)
        case .area(let area):
            return .init(tasks, areas + [area], tags)
        case .tag(let tag):
            return .init(tasks, areas, tags + [tag])
        default: return self
        }
    }
    
    private func handle(_ updateCommand: Change.Update) -> Self {
        switch updateCommand {
        case .task(let task, let command):
            let task = task.alter(command)
            let tasks = tasks.filter { $0.id != task.id } + [task]
            return .init(tasks, areas, tags)
        case .area(let area, let command):
            let area = area.alter(command)
            let areas = areas.filter { $0.id != area.id } + [area]
            return .init(tasks, areas, tags)
        default: return self
        }
    }
    
    private func handle(_ deleteCommand: Change.Delete) -> Self {
        switch deleteCommand {
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
            return .init(
                tasks,
                areas,
                tags.filter { $0.id != tag.id }
            )
        default: return self
        }
    }
}
