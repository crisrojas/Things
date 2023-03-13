//
//  Stores.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 09/03/2023.
//

import Foundation

// MARK: - Disk Store
func createCoreDataStore(controller p: PersistenceController) -> StateStore {
    let manager = CoreDataManager(context: p.context())
    
    var state = AppState(){didSet{c.call()}}
    var c = [()->()]()
    
    let fetch = {state = try await readAppState(manager: manager)}
    Task {try? await fetch()}
    
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

fileprivate func readAppState(manager m: CoreDataManager) async throws -> AppState {
    let tasks = try await m.readTasks()
    let areas = try await m.readAreas()
//    let tags  = try await m.readTags()
    let lists = try await m.readCheckItems()
    return AppState(tasks, areas, [], lists)
}


// MARK: - AppState DSL hndling
fileprivate func write(_ change: AppState.Change, with manager: CoreDataManager) async throws {
    switch change {
    case .create(let cmd): try await handle(cmd, with: manager)
    default: return
    }
}

fileprivate func handle(_ cmd: AppState.Change.Create, with manager: CoreDataManager) async throws {
    switch cmd {
    case .task(let task): try await manager.create(task)
    default: return
    }
}
