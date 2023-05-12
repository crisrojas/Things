//
//  Area.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//

import Foundation

public struct Area {
    public let id: UUID
    public let title: String
    public let visible: Bool
    public let index: Int
    public let tags: Set<UUID>
}

public extension Area {
    enum Change {
        case title(String)
        case makeVisible
        case makeInvisible
        case index(Int)
        case addTag(UUID)
        case removeTag(UUID)
    }
    
     init(
        _ id: UUID = UUID(),
        _ title: String = "",
        _ visible: Bool = false,
        _ index: Int = 0,
        _ tags: Set<UUID> = []
     ) {
        self.id = id
        self.title = title
        self.visible = visible
        self.index = index
        self.tags = tags
    }
    
    func alter(_ c: Change...) -> Self {c.reduce(self){$0.alter($1)}}
    func alter(_ c: Change) -> Self {
        switch c {
        case .title(let title):
            return .init(id, title, visible, index, tags)
        case .makeVisible:
            return .init(id, title, true, index, tags)
        case .makeInvisible:
            return .init(id, title, false, index, tags)
        case .index(let index):
            return .init(id, title, visible, index, tags)
        case .addTag(let tag):
            return .init(id, title, visible, index, tags.add(tag))
        case .removeTag(let tag):
            return .init(id, title, visible, index, tags.delete(tag))
        }
    }
}

extension Area: Identifiable, Codable, Equatable {}
