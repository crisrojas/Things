//
//  Tag.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//
import Foundation

struct Tag {
    let id: UUID
    let name: String
    let parent: UUID?
    let index: Int
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.parent = nil
        self.index = 0
    }
}

extension Tag  {
    
    enum Change {
        case name(String)
        case parent(UUID)
        case removeParent
        case index(Int)
    }
    
    init(
        _ id: UUID = UUID(),
        _ name: String,
        _ parent: UUID?,
        _ index: Int
    ) {
        self.id = id
        self.name = name
        self.parent = parent
        self.index = index
    }
    
    func alter(_ c: Change...) -> Self {c.reduce(self){$0.alter($1)}}
    func alter(_ c: Change) -> Self {
        switch c {
        case .name(let name): return .init(id, name, parent, index)
        case .parent(let parent): return .init(id, name, parent, index)
        case .removeParent: return .init(id, name, nil, index)
        case .index(let index): return .init(id, name, parent, index)
        }
    }
}

extension Tag: Identifiable, Codable, Hashable, Equatable {}