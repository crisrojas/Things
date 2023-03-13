//
//  Task.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//
import Foundation

struct ToDo {
    let id: UUID
    let creationDate: Date
    let modificationDate: Date?
    let date: Date?
    let dueDate: Date?
    let area: UUID?
    let project: UUID?
    let actionGroup: UUID?
    let title: String
    let notes: String
    let tags: Set<UUID>
    let checkList: Set<UUID>
    let type: ListType
    let status: Status
    let index: Int
    let todayIndex: Int
    let trashed: Bool
    let recurrencyRule: RecurrencyRule?
}

extension ToDo: Identifiable, Codable {}
extension ToDo.Change.Add: Equatable {}
extension ToDo.Change.Remove: Equatable {}
extension ToDo.Change: Equatable {}
extension ToDo.ListType: Equatable {}
extension ToDo.RecurrencyRule: Equatable {}
extension ToDo.Status: Equatable {}

extension ToDo {
    enum RecurrencyRule: Codable {
        case daily(startDate: Date)
        case weekly(startDate: Date)
        case monthly(startDate: Date)
        case annual(startDate: Date)
    }

    enum ListType: Int, Codable {
        case task
        case heading
        case project
    }

    enum Status: Int, Codable {
        case open
        case cancelled
        case completed
    }
}


extension ToDo {
        init(
        _ id: UUID = UUID(),
        _ creationDate: Date = Date(),
        _ modificationDate: Date? = nil,
        _ date: Date? = nil,
        _ dueDate: Date? = nil,
        _ area: UUID? = nil,
        _ project: UUID? = nil,
        _ actionGroup: UUID? = nil,
        _ title: String = "",
        _ notes: String = "",
        _ tags: Set<UUID> = [],
        _ checkList: Set<UUID> = [],
        _ type: ListType = .task,
        _ status: Status = .open,
        _ index: Int = 0,
        _ todayIndex: Int = 0,
        _ trashed: Bool = false,
        _ recurrencyRule: RecurrencyRule? = nil
     ) {
        self.id = id
        self.creationDate = creationDate
        self.modificationDate = modificationDate
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
extension ToDo {
    enum Change {
        case title(String)
        case notes(String)
        case area(UUID)
        case date(Date)
        case deadline(Date)
        case project(UUID)
        case actionGroup(UUID)
        case type(ListType)
        case status(Status)
        case index(Int)
        case todayIndex(Int)
        case trash
        case untrash
        case recurrency(RecurrencyRule)
        case remove(Remove)
        case add(Add)
        case duplicate
        
        
        enum Add {
            case checkItem(UUID)
            case tag(UUID)
        }
        
        enum Remove {
            case deadline
            case checkItem(UUID)
            case project
            case recurrency
            case area
            case actionGroup
            case tag(UUID)
            case date
            case checkList
        }
    }
    
    func alter(_ c: [Change]) -> Self{c.reduce(self){$0.alter($1)}}
    func alter(_ c: Change...) -> Self{alter(c)}
    func alter(_ c: Change) -> Self {
        let modificationDate = Date()
        switch c {
        case .title(let title):
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
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .notes(let notes):
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
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .deadline(let dueDate):
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
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .area(let area):
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
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .project(let project):
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
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .actionGroup(let actionGroup):
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
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .add(let command):
            return handleAdd(command)
        case .type(let type):
            return .init(
                id,
                creationDate,
                modificationDate,
                date,
                dueDate,
                area,
                type == .project ? nil : project,
                type == .project ? nil : actionGroup,
                title,
                notes,
                tags,
                type == .project ? [] : checkList,
                type,
                status,
                type == .project ? 0 : index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .status(let status):
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
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .index(let index):
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
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .todayIndex(let todayIndex):
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
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .trash:
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
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                true,
                recurrencyRule
            )
        case .untrash:
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
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                false,
                recurrencyRule
            )
        case .recurrency(let recurrencyRule):
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
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .date(let date):
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
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .duplicate:
            return .init(
                UUID(),
                creationDate,
                self.modificationDate,
                date,
                dueDate,
                area,
                project,
                actionGroup,
                title,
                notes,
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .remove(let command): return handleRemove(command)
        }
    }
    
    private func handleAdd(_ command: Change.Add) -> Self {
        let modificationDate = Date()
        switch command {
        case .checkItem(let item):
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
                tags,
                checkList.add(item),
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .tag(let tag):
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
                tags.add(tag),
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        }
    }
    
    private func handleRemove(_ command: Change.Remove) -> Self {
        let modificationDate = Date()
        switch command {
        case .checkList:
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
                tags,
                [],
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .deadline:
            return .init(
                id,
                creationDate,
                modificationDate,
                date,
                nil,
                area,
                project,
                actionGroup,
                title,
                notes,
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .checkItem(let item):
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
                tags,
                checkList.delete(item),
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .project:
            return .init(
                id,
                creationDate,
                modificationDate,
                date,
                dueDate,
                area,
                nil,
                actionGroup,
                title,
                notes,
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .area:
            return .init(
                id,
                creationDate,
                modificationDate,
                date,
                dueDate,
                nil,
                project,
                actionGroup,
                title,
                notes,
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .recurrency:
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
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                nil
            )
        case .actionGroup:
            return .init(
                id,
                creationDate,
                modificationDate,
                date,
                dueDate,
                area,
                project,
                nil,
                title,
                notes,
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .tag(let tag):
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
                tags.delete(tag),
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        case .date:
            return .init(
                id,
                creationDate,
                modificationDate,
                nil,
                dueDate,
                area,
                project,
                actionGroup,
                title,
                notes,
                tags,
                checkList,
                type,
                status,
                index,
                todayIndex,
                trashed,
                recurrencyRule
            )
        }
    }
}

