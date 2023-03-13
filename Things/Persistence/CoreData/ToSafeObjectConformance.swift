//
//  ToSafeObjectConformance.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 13/03/2023.
//

import Foundation


extension TaskCD: ToSafeObject {
    
    typealias SafeType = ToDo
    
    func safeObject() throws -> ToDo {
        guard
            let id = id,
            let creationDate = creationDate,
            let title = title,
            let notes = notes,
            let type = ToDo.ListType(rawValue: Int(type)),
            let status = ToDo.Status(rawValue: Int(status))
        else { throw CoreDataError.invalidMapping }
        
        return .init(
            id,
            creationDate,
            modificationDate,
            date,
            dueDate,
            nil,
            nil,
            nil,
            title,
            notes,
            [],
            [],
            type,
            status,
            Int(index),
            Int(todayIndex),
            trashed,
            nil // @todo
        )
    }
}

extension AreaCD: ToSafeObject {
    typealias SafeType = Area
    func safeObject() throws -> Area {
        guard
            let id = id,
            let title = title
        else { throw CoreDataError.invalidMapping }
        
        return Area(
            id,
            title,
            visible,
            Int(index),
            []
        )
    }
}

extension CheckItemCD: ToSafeObject {
    typealias SafeType = CheckItem
    func safeObject() throws -> CheckItem {
        guard
            let id = id,
            let creationDate = creationDate,
            let title = title
        else { throw CoreDataError.invalidMapping }
        return .init(
            id,
            creationDate,
            modificationDate,
            checked,
            UUID(), // @todo: Relationships
            title,
            Int(index)
        )
    }
}
