//
//  Stores.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 09/03/2023.
//

import Foundation


// MARK: - Ram Store
func createRamStore() -> StateStore {
    var state = AppState() {didSet{c.call()}}
    var c = [()->()]()
    
    return (
        state   : { state                   },
        change  : { state = state.alter($0) },
        callback: { c = c + [$0]            },
        reset   : { state = AppState()      },
        destroy : { state = AppState()      }
    )
}

// MARK: - Disk Store
func createDiskStore(path: String = "state.json") -> StateStore {
    
    let fm = FileManager.default
    
    var state = readAppState(path, with: fm) {didSet {c.call()}}
    var c = [()->()]()
    
    let persist = {write(state, to: path, with: fm)}
    
    return (
        state   : { state                              },
        change  : { state = state.alter($0) ; persist()},
        callback: { c = c + [$0]                       },
        reset   : { state = AppState();persist()       },
        destroy : { try! destroy(path, with: fm)       }
    )
}


func createCoreDataStore(inMemory: Bool = false) -> StateStore {
    let persistence = PersistenceController.get(inMemory: inMemory)
    let manager = CoreDataManager(context: persistence.context())
    
    var state = AppState(){didSet{c.call()}}
    var c = [()->()]()
    
    let fetch = {state = try await readAppState(manager: manager)}
    Task {try? await fetch()}
    
    return (
        state   : { state },
        change  : { write(&state, change: $0, with: manager) },
        callback: { c = c + [$0] },
        reset   : { },
        destroy : { }
    )
}

fileprivate func write(_ toSync: inout AppState, change: AppState.Change, with manager: CoreDataManager) {
    
//    let handleCreate: (AppState.Change.Create) -> () = { cmd in
//        switch cmd {
//        case .task(let task): manager.create(task)
//        default: return
//        }
//    }
    
    switch change {
    case .create(let cmd): return
    default: return
    }

}

fileprivate func readAppState(manager m: CoreDataManager) async throws -> AppState {
    let tasks = try await m.readTasks()
    return AppState(tasks, [], [])
}

func createSplittedDiskStore() -> StateStore {
    
    let fm = FileManager.default
    
    let readState = {
        let tasks: [ToDo     ] = read("tasks.json"    , with: fm) ?? []
        let areas: [Area     ] = read("areas.json"    , with: fm) ?? []
        let tags : [Tag      ] = read("tags.json"     , with: fm) ?? []
        return AppState(tasks, areas, tags)
    }
    
    var state = readState() {didSet {c.call()}}
    var c = [()->()]()
    
    return (
        state   : { state },
        change  : { _ in },
        callback: { c = c + [$0] },
        reset   : { state = AppState(); },
        destroy : { }
    )
    
}


private func write(_ state: AppState, to path: String, with fm: FileManager) {
    
    do {
        #if DEBUG
        jsonEncoder.outputFormatting = .prettyPrinted
        #endif
        
        let data = try jsonEncoder.encode(state)
        try data.write(to: fileURL(path: path, fm: fm))
    } catch {
        print(error)
    }
}

private func read<C: Codable>(_ path: String, with fm: FileManager) -> C? {
    do {
        return try jsonDecoder
            .decode(C.self, from: try Data(contentsOf: fileURL(path: path, fm: fm)))
    } catch {
        print("Failure when trying to read state:")
        print(error)
        return nil
    }
}

private func destroy(_ path: String, with fm: FileManager) throws {
    try fm.removeItem(atPath: fileURL(path: path, fm: fm).path)
}

private func readAppState(_ path: String, with fm: FileManager) -> AppState {
    do {
        return try jsonDecoder
            .decode(AppState.self, from: try Data(contentsOf: fileURL(path: path, fm: fm)))
    } catch {
        print("Failure when trying to read state:")
        print(error)
    }
    
    return AppState()
}


private func fileURL(path: String, fm: FileManager) throws -> URL {
    try fm
        .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent(path)
}

fileprivate let jsonDecoder: JSONDecoder = {JSONDecoder()}()
fileprivate let jsonEncoder: JSONEncoder = {JSONEncoder()}()
