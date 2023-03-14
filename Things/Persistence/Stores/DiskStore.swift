//
//  DiskStore.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 13/03/2023.
//

import Foundation

/// Creates a store that serializes AppState to a state.json file on disk
func createDiskStore(path: String = "state.json") -> StateStore {
    
    let fm = FileManager.default
    
    var s = readState(path, with: fm) {didSet {c.call()}}
    var c = [()->()]()
    
    let persist = {write(s, to: path, with: fm)}
     
    return (
        state   : { s                            },
        change  : { s = s.alter($0) ; persist()  },
        callback: { c = c + [$0]    ; persist()  },
        reset   : { s = AppState()  ; persist()  },
        destroy : { try destroy(path, with: fm)  }
    )
}

/// Creates a store that serializes each model of the domain to its own file on disk:
func createSplittedDiskStore(
    tasks: String = "tasks.json",
    areas: String = "areas.json",
    tags : String = "tags.json",
    lists: String = "check.json"
) -> StateStore {
    
    let fm = FileManager.default
    
    let access = {
        let tasks: [Task     ] = read(tasks, with: fm) ?? []
        let areas: [Area     ] = read(areas, with: fm) ?? []
        let tags : [Tag      ] = read(tags , with: fm) ?? []
        let lists: [CheckItem] = read(lists, with: fm) ?? []
        return AppState(tasks, areas, tags, lists)
    }
    
    let delete = {
        try destroy(tasks, with: fm)
        try destroy(areas, with: fm)
        try destroy(tags , with: fm)
        try destroy(lists, with: fm)
    }
    
    let persist = { (s: AppState) in
        write(s.tasks, to: tasks, with: fm)
        write(s.areas, to: areas, with: fm)
        write(s.tags,  to: tags,  with: fm)
        write(s.checkItems, to: tags, with: fm)
    }
    
    var s = access() {didSet {c.call()}}
    var c = [()->()]()
    
    return (
        state   : { s                          },
        change  : { s = s.alter($0) ; persist(s) },
        callback: { c = c + [$0]    ; persist(s) },
        reset   : { s = AppState()  ; persist(s) },
        destroy : { try delete()               }
    )
}


// MARK: - FileManager
func write<C: Codable>(_ codable: C, to path: String, with fm: FileManager) {
    do {
        #if DEBUG
        jsonEncoder.outputFormatting = .prettyPrinted
        #endif
        
        let data = try jsonEncoder.encode(codable)
        try data.write(to: fileURL(path: path, fm: fm))
    } catch {
        print(error)
    }
}

func readState(_ path: String, with fm: FileManager) -> AppState {
    let s: AppState? = read(path, with: fm)
    return s ?? AppState()
}

func read<C: Codable>(_ path: String, with fm: FileManager) -> C? {
    do {
        return try jsonDecoder
            .decode(C.self, from: try Data(contentsOf: fileURL(path: path, fm: fm)))
    } catch {
        print("Failure when trying to read state:")
        print(error)
        return nil
    }
}

func destroy(_ path: String, with fm: FileManager) throws {
    try fm.removeItem(atPath: fileURL(path: path, fm: fm).path)
}


private func fileURL(path: String, fm: FileManager) throws -> URL {
    try fm
        .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent(path)
}

fileprivate let jsonDecoder: JSONDecoder = {JSONDecoder()}()
fileprivate let jsonEncoder: JSONEncoder = {JSONEncoder()}()

