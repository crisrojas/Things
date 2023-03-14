//
//  Stores.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 09/03/2023.
//

import Foundation

typealias ConcurrentTask = _Concurrency.Task

// MARK: - Disk Store
func createCoreDataStore(controller p: PersistenceController) -> StateStore {
    let manager = CoreDataManager(context: p.context())
    
    var state = AppState(){didSet{c.call()}}
    var c = [()->()]()
    
    let fetch = {state = try await readState(manager: manager)}
    ConcurrentTask {try? await fetch()}
    
    return (
        state   : { state },
        change  : { c in
            try await write(c, with: manager)
            try await fetch()
        },
        callback: { c = c + [$0] },
        reset   : { },
        destroy : { print("@todo") }
    )
}

fileprivate func readState(manager m: CoreDataManager) async throws -> AppState {
    let tasks = try await m.readTasks()
    let areas = try await m.readAreas()
    let tags  = try await m.readTags()
    let lists = try await m.readCheckItems()
    return AppState(tasks, areas, tags, lists)
}

// MARK: - AppState DSL hndling
fileprivate func write(_ change: AppState.Change, with manager: CoreDataManager) async throws {
    switch change {
    case .create(let cmd): try await handle(cmd, with: manager)
    case .delete(let cmd): try await handle(cmd, with: manager)
    case .update(let cmd): try await handle(cmd, with: manager)
    }
}

fileprivate func handle(_ cmd: AppState.Change.Create, with manager: CoreDataManager) async throws {
    switch cmd {
    case .task(let task): try await manager.create(task)
    case .area(let area): try await manager.create(area)
    case .checkItem(let item): try await manager.create(item)
    case .tag(let tag): try await manager.create(tag)
    }
}

fileprivate func handle(_ cmd: AppState.Change.Delete, with manager: CoreDataManager) async throws {
    switch cmd {
    case .task(let task): try await manager.delete(task: task.id)
    case .area(let area): try await manager.delete(area: area.id)
    case  .tag(let tag ): try await manager.delete(tag: tag)
    case .checkItem(let item): try await manager.delete(checkItem: item.id)
    }
}

fileprivate func handle(_ cmd: AppState.Change.Update, with manager: CoreDataManager) async throws {
    switch cmd {
    case .task(let task, let cmd): try await manager.update(task, cmd)
    case .area(let area, let cmd): try await manager.update(area, cmd)
    case .tag(let tag, let cmd): try await manager.update(tag, cmd)
    default: return
    }
}
