//
//  DiskSplittedStore.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 14/03/2023.
//

import Foundation

/// Creates a store that serializes to disk each model of the domain on its own file.
/// This is better for scalability on the long run.
func createSplittedDiskStore(
    tasks: String = "tasks",
    areas: String = "areas",
    tags : String = "tags",
    lists: String = "check"
) -> StateStore {
    
    let fm = FileManager.default
    
    let access = {
        let tasks: [Task     ] = read(tasks + ".json", with: fm) ?? []
        let areas: [Area     ] = read(areas + ".json", with: fm) ?? []
        let tags : [Tag      ] = read(tags  + ".json", with: fm) ?? []
        let lists: [Item] = read(lists + ".json", with: fm) ?? []
        return AppState(tasks, areas, tags, lists)
    }
    
    let persist = { (s: AppState) in
        try write(s.tasks, to: tasks, with: fm)
        try write(s.areas, to: areas, with: fm)
        try write(s.tags,  to: tags,  with: fm)
        try write(s.items, to: tags, with: fm)
    }

    var s = access() {didSet {c.call()}}
    var c = [()->()]()
    
    let save   = {try persist(s)}
    let reset  = {s = AppState()}
    let reload = {s = access()}
    let trash  = [reset] + [save] + [reload]
    
    return (
        state   : { s },
        change  : { s = s.alter($0) ; try  persist(s) },
        onChange: { c = c + [$0]    ; try? persist(s) },
        destroy : { try trash.call() }
    )
}
