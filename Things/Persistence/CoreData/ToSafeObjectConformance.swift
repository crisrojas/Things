//
//  ToSafeObjectConformance.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 13/03/2023.
//

import Foundation


extension TaskCD: ToSafeObject {
    
    typealias SafeType = Task
    
    func safeObject() throws -> Task {
        guard
            let id = id,
            let creationDate = creationDate,
            let title = title,
            let notes = notes,
            let type = Task.ListType(rawValue: Int(type)),
            let status = Task.Status(rawValue: Int(status))
        else { throw CoreDataError.invalidMapping }
        
        return .init(
            id,
            creationDate,
            modificationDate,
            date,
            dueDate,
            area,
            project,
            actionGroup,
            title,
            notes,
            tags ?? [],
            checkList ?? [],
            type,
            status,
            Int(index),
            Int(todayIndex),
            trashed,
            nil // @todo recurrency
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
            tags ?? []
        )
    }
}

extension CheckItemCD: ToSafeObject {
    typealias SafeType = Item
    func safeObject() throws -> Item {
        guard
            let id = id,
            let creationDate = creationDate,
            let title = title,
            let task = task
        else { throw CoreDataError.invalidMapping }
        return .init(
            id,
            creationDate,
            modificationDate,
            checked,
            task,
            title,
            Int(index)
        )
    }
}

extension TagCD: ToSafeObject {
    typealias SafeType = Tag
    func safeObject() throws -> Tag {
        guard
            let id = id,
            let name = name
        else { throw CoreDataError.invalidMapping }
        return .init(id, name, parent, Int(index))
    }
}
