//
//  Stores.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 09/03/2023.
//

import Foundation

typealias ConcurrentTask = _Concurrency.Task

func createCoreDataStore(controller p: PersistenceController) -> StateStore {
    
    let m = CoreDataManager(context: p.context())
    
    var s = AppState(){didSet{c.call()}}
    var c = [()->()]()
    
    let reset = {s = AppState() }
    let fetch = {s = try await readState(manager: m)}
    
    ConcurrentTask {try? await fetch()}
    
    let change = { (c: AppState.Change) in
        try await write(c, with: m)
        try await fetch()
    }
    
    return (
        state   : { s },
        change  : { try await change($0)  },
        onChange: { c = c + [$0]          },
        destroy : { p.destroy() ; reset() }
    )
}

// MARK: - AppState DSL handling
fileprivate func write(_ change: AppState.Change, with manager: CoreDataManager) async throws {
    switch change {
    case .create(let cmd): try await handle(cmd, with: manager)
    case .delete(let cmd): try await handle(cmd, with: manager)
    case .update(let cmd): try await handle(cmd, with: manager)
    }
}


// MARK: - C
fileprivate func handle(_ cmd: AppState.Change.Create, with manager: CoreDataManager) async throws {
    switch cmd {
    case .task(let task): try await manager.create(task)
    case .area(let area): try await manager.create(area)
    case .checkItem(let item): try await manager.create(item)
    case .tag(let tag): try await manager.create(tag)
    }
}

// MARK: - R
fileprivate func readState(manager m: CoreDataManager) async throws -> AppState {
    let tasks = try await m.readTasks()
    let areas = try await m.readAreas()
    let tags  = try await m.readTags()
    let lists = try await m.readCheckItems()
    return AppState(tasks, areas, tags, lists)
}

// MARK: - U
fileprivate func handle(_ cmd: AppState.Change.Update, with manager: CoreDataManager) async throws {
    switch cmd {
    case .task(let task, let cmd): try await manager.update(task, cmd)
    case .area(let area, let cmd): try await manager.update(area, cmd)
    case .tag(let tag, let cmd): try await manager.update(tag, cmd)
    case .item(let item, let cmd): try await manager.update(item, cmd)
    }
}

// MARK: - D
fileprivate func handle(_ cmd: AppState.Change.Delete, with manager: CoreDataManager) async throws {
    switch cmd {
    case .task(let task): try await manager.delete(task: task.id)
    case .area(let area): try await manager.delete(area: area.id)
    case  .tag(let tag ): try await manager.delete(tag: tag)
    case .checkItem(let item): try await manager.delete(checkItem: item.id)
    }
}


