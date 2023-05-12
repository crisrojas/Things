//
//  Task.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//
import Foundation

public struct Task {
    public let id: UUID
    public let creationDate: Date
    public let modificationDate: Date?
    public let date: Date?
    public let dueDate: Date?
    public let area: UUID?
    public let project: UUID?
    public let actionGroup: UUID?
    public let title: String
    public let notes: String
    public let tags: Set<UUID>
    public let checkList: Set<UUID>
    public let type: ListType
    public let status: Status
    public let index: Int
    public let todayIndex: Int
    public let trashed: Bool
    public let recurrencyRule: RecurrencyRule?
}

// MARK: - Subtypes
public extension Task {
    enum RecurrencyRule: Codable {
        case afterComplete(AfterCompleted)
        case daily(startDate: Date)
        case weekly(startDate: Date)
        case monthly(startDate: Date)
        case annual(startDate: Date)
        
        public enum AfterCompleted: Codable {
            case day(Int)
            case week(Int)
            case month(Int)
            case year(Int)
        }
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

// MARK: - Type conformances
extension Task: Identifiable, Codable {}
extension Task.ListType: Equatable {}
extension Task.RecurrencyRule: Equatable {}
extension Task.RecurrencyRule.AfterCompleted: Equatable {}
extension Task.Status: Equatable {}
extension Task.Change: Equatable {}
extension Task.Change.Add: Equatable {}
extension Task.Change.Remove: Equatable {}

extension Task: Equatable {
    /// Don't include "modificationDate"
    public static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
        && lhs.title == rhs.title
        && lhs.creationDate == rhs.creationDate
        && lhs.notes == rhs.notes
        && lhs.date == rhs.date
        && lhs.dueDate == rhs.dueDate
        && lhs.area == rhs.area
        && lhs.project == rhs.project
        && lhs.actionGroup == rhs.actionGroup
        && lhs.tags == rhs.tags
        && lhs.checkList == rhs.checkList
        && lhs.type == rhs.type
        && lhs.status == rhs.status
        && lhs.index == rhs.index
        && lhs.todayIndex == rhs.todayIndex
        && lhs.trashed == rhs.trashed
        && lhs.recurrencyRule == rhs.recurrencyRule
    }
}

// MARK: - ToDo DSL
public extension Task {
    
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
public extension Task {
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
        
        
        public enum Add {
            case checkItem(UUID)
            case tag(UUID)
        }
        
        public enum Remove {
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

// MARK: - Mapping to CoreData Entity
import CoreData

extension Task {
    func toTaskCD(with c: NSManagedObjectContext) -> TaskCD {
        let entity = TaskCD(context: c)
        entity.id = id
        entity.creationDate = creationDate
        entity.modificationDate = modificationDate
        entity.date = date
        entity.dueDate = dueDate
        entity.area = area
        entity.project = project
        entity.actionGroup = actionGroup
        entity.title = title
        entity.notes = notes
        entity.tags = tags
        entity.checkList = checkList
        entity.type = Int16(type.rawValue)
        entity.status = Int16(status.rawValue)
        entity.index = Int16(index)
        entity.todayIndex = Int16(todayIndex)
        entity.trashed = trashed
//         entity.recurrencyRule = task.recurrencyRule // @todo
        return entity
    }
}
