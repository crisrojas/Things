//
//  Task.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//
import Foundation

let task = try! ToDo.initTask()
    .convert(to: .project)

let taskB = try! ToDo.initTask()
    .convert(to: .heading)

enum ToDo {
    case task(
        id: UUID,
        cDate: Date,
        mDate: Date?,
        dDate: Date?,
        area: UUID?,
        project: UUID?,
        title: String,
        notes: String,
        tags: Set<UUID>,
        checkList: Set<UUID>,
        status: Task.Status,
        index: Int,
        todayIndex: Int,
        trashed: Bool,
        recurrencyRule: Task.RecurrencyRule?
    )
    
    case project(
        id: UUID,
        cDate: Date,
        mDate: Date?,
        dDate: Date?,
        area: UUID?,
        title: String,
        notes: String,
        tags: Set<UUID>,
        status: Task.Status,
        index: Int,
        todayIndex: Int,
        trashed: Bool
    )
    
    case heading(
        id: UUID,
        cDate: Date,
        mDate: Date?,
        project: UUID?,
        title: String,
        index: Int,
        todayIndex: Int,
        trashed: Bool
    )
    
    enum Target {
        case task
        case project
        case heading
    }
    
    enum TaskError: Error {
        case conversionError(String)
        case changeError(String)
    }
    
    func convert(to target: Target) throws -> Self {
        switch self {
        case .task(
            id: let id,
            cDate: let cDate,
            mDate: let mDate,
            dDate: let dDate,
            area: let area,
            project: let project,
            title: let title,
            notes: let notes,
            tags: let tags,
            checkList: _,
            status: let status,
            index: _,
            todayIndex: _,
            trashed: let trashed,
            recurrencyRule: _):
            
            switch target {
            case .project:
                return .project(
                    id: id,
                    cDate: cDate,
                    mDate: mDate,
                    dDate: dDate,
                    area: area,
                    title: title,
                    notes: notes,
                    tags: tags,
                    status: status,
                    index: 0,
                    todayIndex: 0,
                    trashed: trashed
                )
            case .heading:
                return .heading(
                    id: id,
                    cDate: cDate,
                    mDate: mDate,
                    project: project,
                    title: title,
                    index: 0,
                    todayIndex: 0,
                    trashed: trashed
                )
            default: throw TaskError.conversionError("A task cannot ve converted to itself")
            }
        case .project:
            throw TaskError.conversionError("A project cannot be converted to a \(target)")
            
        case .heading(
            id: let id,
            cDate: let cdate,
            mDate: let mDate,
            project: _,
            title: let title,
            index: _,
            todayIndex: _,
            trashed: let trashed):
            
            switch target {
            case .project: return .project(
                id: id,
                cDate: cdate,
                mDate: mDate,
                dDate: nil,
                area: nil,
                title: title,
                notes: "",
                tags: [],
                status: .open,
                index: 0,
                todayIndex: 0,
                trashed: trashed
            )
            default: throw TaskError.conversionError("A heading cannot be converted into \(target)")
            }
        }
    }
}


// MARK: - Task API
extension ToDo {
    
    enum Change {
        case todo(ToDo)
        
        enum ToDo {
            case creationDate(Date)
            case modificationDate(Date)
            case dueDate(Date?)
            case area(UUID?)
            case project(UUID?)
            case title(String)
            case notes(String)
            case tags(Set<UUID>)
            case checkList(Set<UUID>)
            case status(Task.Status)
            case index(Int)
            case todayIndex(Int)
            case trashed(Bool)
            case rule(Task.RecurrencyRule?)
            
            case add(Add)
            
            enum Add {
                case item(UUID)
                case tag(UUID)
            }
        }
    }
    
    static func initTask() -> Self {
        .task(
            id: UUID(),
            cDate: Date(),
            mDate: nil,
            dDate: nil,
            area: nil,
            project: nil,
            title: "",
            notes: "",
            tags: [],
            checkList: [],
            status: .open,
            index: 0,
            todayIndex: 0,
            trashed: false,
            recurrencyRule: nil
        )
    }
    
    func initFullTask(
        _ id: UUID,
        _ cDate: Date,
        _ mDate: Date?,
        _ dDate: Date?,
        _ area: UUID?,
        _ project: UUID?,
        _ title: String,
        _ notes: String,
        _ tags: Set<UUID>,
        _ checkList: Set<UUID>,
        _ status: Task.Status,
        _ index: Int,
        _ todayIndex: Int,
        _ trashed: Bool,
        _ recurrencyRule: Task.RecurrencyRule?
    ) -> Self {
        return .task(
            id: id,
            cDate: cDate,
            mDate: mDate,
            dDate: dDate,
            area: area,
            project: project,
            title: title,
            notes: notes,
            tags: tags,
            checkList: checkList,
            status: status,
            index: index,
            todayIndex: todayIndex,
            trashed: trashed,
            recurrencyRule: recurrencyRule
        )
    }
    
    func apply(taskChange: Change.ToDo) throws -> Self {
        guard case var .task(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule) = self else {
            throw TaskError.changeError("Cannot apply a change to a type \(self)")
        }
        
        switch taskChange {
        case .creationDate(let cDate):
            return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
        case .modificationDate(let mDate):
            return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
        case .dueDate(let dDate):
            return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
        case .area(let area):
            return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
        case .project(let project):
            return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
        case .title(let title):
            return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
        case .notes(let notes):
            return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
        case .tags(let tags):
            return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
        case .checkList(let checkList):
            return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
        case .status(let status):
            return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
        case .index(let index):
            return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
        case .todayIndex(let todayIndex):
            return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
        case .trashed(let trashed):
            return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
        case .rule(let recurrencyRule):
            return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
        case .add(let cmd):
            switch cmd {
            case .item(let item):
                let checkList = checkList.add(item)
                return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
            case .tag(let tag):
                let tag = tags.add(tag)
                return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
            }
        }
        
        return self.initFullTask(id, cDate, mDate, dDate, area, project, title, notes, tags, checkList, status, index, todayIndex, trashed, recurrencyRule)
    }
}


struct Task {
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

// MARK: - Subtypes
extension Task {
    enum RecurrencyRule: Codable {
        case afterComplete(AfterCompleted)
        case daily(startDate: Date)
        case weekly(startDate: Date)
        case monthly(startDate: Date)
        case annual(startDate: Date)
        
        enum AfterCompleted: Codable {
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
extension Task {
    
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
extension Task {
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
