//
//  CheckItem.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//

import Foundation

public struct Item {
    public let id: UUID
    public let creationDate: Date
    public let modificationDate: Date?
    public let checked: Bool
    public let task: UUID
    public let title: String
    public let index: Int
    
    public init(task: UUID) {
        self.id = UUID()
        self.creationDate = Date()
        self.modificationDate = nil
        self.checked = false
        self.task = task
        self.title = ""
        self.index = 0
    }
}

public extension Item {
    init(
        _ id: UUID = UUID(),
        _ creationDate: Date = Date(),
        _ modificationDate: Date?,
        _ checked: Bool = false,
        _ task: UUID,
        _ title: String = "",
        _ index: Int = 0
    ) {
        self.id = id
        self.creationDate = creationDate
        self.modificationDate = nil
        self.checked = checked
        self.task = task
        self.title = title
        self.index = index
    }
}

public extension Item {
    enum Change {
        case check
        case uncheck
        case title(String)
        case index(Int)
    }
    
    func alter(_ c: Change...) -> Self {c.reduce(self){$0.alter($1)}}
    func alter(_ c: Change) -> Self {
        let modificationDate = Date()
        switch c {
        case .check:
            return .init(id, creationDate, modificationDate, true, task, title, index)
        case .uncheck:
            return .init(id, creationDate, modificationDate, false, task, title, index)
        case .title(let title):
            return .init(id, creationDate, modificationDate, checked, task, title, index)
        case .index(let index):
            return .init(id, creationDate, modificationDate, checked, task, title, index)
        }
    }
}


extension Item {
    func toTask() -> Task {
        Task().alter(
            .title(title),
            .project(task)
        )
    }
}

extension Item: Identifiable, Codable, Hashable, Equatable {}
