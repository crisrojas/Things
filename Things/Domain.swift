//
//  Domain.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 09/03/2023.
//

import Foundation

typealias IdentiCodable = Codable & Identifiable

enum ItemDate {
    case today
    case tonight
    case date(Date)
    case oneDay
}
enum RecurrencyRule: Codable { case weekly ; case afterFinish }
enum ListType: Codable {
    case task
    case heading
    case project
}

enum Status: Codable {
    case open
    case cancelled
    case completed
}

struct ToCheck: IdentiCodable, Hashable {
    let id: UUID
    let creationDate: Date
    let modificationDate: Date
    let done: Bool
    let task: UUID
    let title: String
    let index: Int
}

extension ToCheck {
    init(
        _ id: UUID,
        _ creationDate: Date = Date(),
        _ done: Bool = false,
        _ task: UUID,
        _ title: String = "",
        _ index: Int = 0
    ) {
        self.id = id
        self.creationDate = creationDate
        self.modificationDate = Date()
        self.done = done
        self.task = task
        self.title = title
        self.index = index
    }
}

struct Tag: IdentiCodable, Hashable {
    let id: UUID
    let name: String
}

extension Tag {
    init(
        _ id: UUID = UUID(),
        _ name: String
    ) {
        self.id = id
        self.name = name
    }
}

struct Area: IdentiCodable {
    let id: UUID
    let title: String
    let visible: Bool
    let index: Int
    let tags: Set<Tag>
}

extension Area {
     init(
        _ id: UUID = UUID(),
        _ title: String = "",
        _ visible: Bool = false,
        _ index: Int = 0,
        _ tags: Set<Tag> = []
     ) {
        self.id = id
        self.title = title
        self.visible = visible
        self.index = index
        self.tags = tags
    }
    
}


struct Task: IdentiCodable {
    let id: UUID
    let creationDate: Date
    let modificationDate: Date
    let date: Date?
    let dueDate: Date?
    let area: UUID?
    let project: UUID?
    let actionGroup: UUID?
    let title: String
    let notes: String
    let tags: Set<Tag>
    let checkList: Set<ToCheck>
    let type: ListType
    let status: Status
    let index: Int
    let todayIndex: Int
    let trashed: Bool
    let recurrencyRule: RecurrencyRule?
}


extension Task {
     init(
        _ id: UUID = UUID(),
        _ creationDate: Date = Date(),
        _ date: Date? = nil,
        _ dueDate: Date? = nil,
        _ area: UUID? = nil,
        _ project: UUID? = nil,
        _ actionGroup: UUID? = nil,
        _ title: String = "",
        _ notes: String = "",
        _ tags: Set<Tag> = [],
        _ checkList: Set<ToCheck> = [],
        _ type: ListType = .task,
        _ status: Status = .open,
        _ index: Int = 0,
        _ todayIndex: Int = 0,
        _ trashed: Bool = false,
        _ recurrencyRule: RecurrencyRule? = nil
     ) {
        self.id = id
        self.creationDate = creationDate
        self.modificationDate = Date()
        self.date = date
        self.dueDate = dueDate
        self.area = area
        self.project = project
        self.actionGroup = actionGroup
        self.title = title
        self.notes = notes
        self.tags = tags
        self.checkList = checkList
        self.type = type
        self.status = status
        self.index = index
        self.todayIndex = todayIndex
        self.trashed = trashed
        self.recurrencyRule = recurrencyRule
    }
}

// MARK: Task DSL

extension Task {
    enum Change {
        case updateTitle(String)
        case updateNotes(String)
        case addDeadline(Date)
        case removeDeadline
        case addProject(UUID)
        case removeProject(UUID)
        case addCheckList(ToCheck)
        case removeCheckList(UUID)
        case setType(ListType)
        case setStatus(Status)
        case setIndex(Int)
        case trash
        case untrash
        case addRecurrency(RecurrencyRule)
        case removeRecurrency
    }
    
//    func alter(_ change: Change) -> Self {
//        switch change {
//            
//        case .updateTitle(_):
//            <#code#>
//        case .updateNotes(_):
//            <#code#>
//        case .addDeadline(_):
//            <#code#>
//        case .removeDeadline:
//            <#code#>
//        case .addProject(_):
//            <#code#>
//        case .removeProject(_):
//            <#code#>
//        case .addCheckList(_):
//            <#code#>
//        case .removeCheckList(_):
//            <#code#>
//        case .setType(_):
//            <#code#>
//        case .setStatus(_):
//            <#code#>
//        case .setIndex(_):
//            <#code#>
//        case .trash:
//            <#code#>
//        case .untrash:
//            <#code#>
//        case .addRecurrency(_):
//            <#code#>
//        case .removeRecurrency:
//            <#code#>
//        }
//    }
}
