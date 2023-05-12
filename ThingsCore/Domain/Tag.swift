//
//  Tag.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//
import Foundation

public struct Tag {
    public let id: UUID
    public let name: String
    public let parent: UUID?
    public let index: Int
    
    public init(name: String) {
        self.id = UUID()
        self.name = name
        self.parent = nil
        self.index = 0
    }
}

public extension Tag  {
    
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
