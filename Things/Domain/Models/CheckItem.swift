//
//  CheckItem.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//

import Foundation


struct CheckItem: Hashable {
    let id: UUID
    let creationDate: Date
    let modificationDate: Date
    let checked: Bool
    let task: UUID
    let title: String
    let index: Int
    
    init(task: UUID) {
        self.id = UUID()
        self.creationDate = Date()
        self.modificationDate = Date()
        self.checked = false
        self.task = task
        self.title = ""
        self.index = 0
    }
}

extension CheckItem: IdentiCodable {
    init(
        _ id: UUID = UUID(),
        _ creationDate: Date = Date(),
        _ checked: Bool = false,
        _ task: UUID,
        _ title: String = "",
        _ index: Int = 0
    ) {
        self.id = id
        self.creationDate = creationDate
        self.modificationDate = Date()
        self.checked = checked
        self.task = task
        self.title = title
        self.index = index
    }
}


extension CheckItem {
    enum Change {
        case check
        case uncheck
        case title(String)
        case index(Int)
    }
    
    func alter(_ c: Change...) -> Self {c.reduce(self){$0.alter($1)}}
    func alter(_ c: Change) -> Self {
        switch c {
        case .check:
            return .init(id, creationDate, true, task, title, index)
        case .uncheck:
            return .init(id, creationDate, false, task, title, index)
        case .title(let title):
            return .init(id, creationDate, checked, task, title, index)
        case .index(let index):
            return .init(id, creationDate, checked, task, title, index)
        }
    }
}

