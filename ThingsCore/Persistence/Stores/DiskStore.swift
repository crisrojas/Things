//
//  DiskStore.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 13/03/2023.
//

import Foundation

/// Creates a store that serializes AppState to a state.json file on disk
public func createDiskStore(path: String = "state.json") -> StateStore {
    
    let fm = FileManager.default
    
    var s = readState(path, with: fm) {didSet {c.call()}}
    var c = [()->()]()
    
    let persist = { try write(s, to: path, with: fm) }
    let reset   = { s = AppState()               }
    let delete  = { try destroy(path, with: fm)  }
    let trash   = [delete] + [reset] + [persist]
    
    return (
        state   : { s },
        change  : { s = s.alter($0) ; try  persist() },
        onChange: { c = c + [$0]    ; try? persist() },
        destroy : { try trash.call() }
    )
}


// MARK: - FileManager
func write<C: Codable>(_ codable: C, to path: String, with fm: FileManager) throws {
    #if DEBUG
    jsonEncoder.outputFormatting = .prettyPrinted
    #endif
    
    let data = try jsonEncoder.encode(codable)
    try data.write(to: fileURL(path: path, fm: fm))
}

fileprivate func readState(_ path: String, with fm: FileManager) -> AppState {
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

fileprivate func destroy(_ path: String, with fm: FileManager) throws {
    try fm.removeItem(atPath: fileURL(path: path, fm: fm).path)
}


fileprivate func fileURL(path: String, fm: FileManager) throws -> URL {
    try fm
        .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent(path)
}

fileprivate let jsonDecoder: JSONDecoder = {JSONDecoder()}()
fileprivate let jsonEncoder: JSONEncoder = {JSONEncoder()}()

