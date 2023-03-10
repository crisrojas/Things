//
//  Tag.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//
import Foundation

struct Tag: IdentiCodable, Hashable {
    let id: UUID
    let name: String
    let children: Set<Tag>
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.children = []
    }
}

extension Tag  {
    init(
        _ id: UUID = UUID(),
        _ name: String,
        _ children: Set<Tag>
    ) {
        self.id = id
        self.name = name
        self.children = children
    }
}
