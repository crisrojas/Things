//
//  AppState.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 09/03/2023.
//

import Foundation

// MARK: - App State
struct AppState: Codable {
    let tasks     : [ToDo]
    let areas     : [Area]
    let tags      : [Tag]
}

extension AppState {
    init(
        _ tasks     : [ToDo] = [],
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
            case task(ToDo)
            case area(Area)
            case tag(Tag)
        }
        
        enum Update {
            case task(ToDo, with: ToDo.Change)
            case area(Area, with: Area.Change)
            case tag(Tag, with: Tag.Change)
        }
        
        enum Delete {
            case task(ToDo)
            case area(Area)
            case tag(Tag)
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
    
    private func handle(_ createCommand: Change.Create) -> Self {
        switch createCommand {
        case .task(let task):
            return .init(tasks + [task], areas, tags)
        case .area(let area):
            return .init(tasks, areas + [area], tags)
        case .tag(let tag):
            return .init(tasks, areas, tags + [tag])
        }
    }
    
    private func handle(_ updateCommand: Change.Update) -> Self {
        switch updateCommand {
        case .task(let task, let command):
           
            if command == .type(.project) {
              return handleConvertToProject(task: task)
            } else {
                
                let task = task.alter(command)
                let tasks = tasks.filter { $0.id != task.id } + [task]
                return .init(tasks, areas, tags)
            }

        case .area(let area, let command):
            let area = area.alter(command)
            let areas = areas.filter { $0.id != area.id } + [area]
            return .init(tasks, areas, tags)
        case .tag(let tag, let command):
            let tag = tag.alter(command)
            let tags = tags.filter { $0.id != tag.id } + [tag]
            return .init(tasks, areas, tags)
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
        }
    }
    
    private func handleConvertToProject(task: ToDo) -> AppState {
        switch task.type {
        case .task:
            let subtasks = task.checkList.map {
                $0.toTask(project: task.id)
            }
            
            let project = task.alter(.type(.project))
            let tasks = tasks.filter { $0.id != task.id }
            + [project]
            + subtasks
            
            return .init(tasks, areas, tags)
            
        case .heading:
            let subtasks = tasks
                .filter { $0.actionGroup == task.id }
                .map { $0.alter(.remove(.actionGroup))}
            
            let project = task.alter(.type(.project))
            
            let tasks = subtasks
                .reduce(tasks) {$0.remove($1)}
                .filter { $0.id != task.id }
            + [project]
            + subtasks
            
            return .init(tasks, areas, tags)
           
        case .project: return self
        }
    }
}

extension [ToDo] {
    func remove(_ task: ToDo) -> Self {
        self.filter { $0.id != task.id }
    }
}
