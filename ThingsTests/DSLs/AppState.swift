//
//  AppState.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 12/03/2023.
//

import XCTest
@testable import Things

final class AppStateTests: XCTestCase {
    
    let sut = AppState()
    
    // MARK: - Create
    func testCreateTask() {
        let task = Task()
        let t1 = sut.alter(.create(.task(task)))
        XCTAssertTrue(t1.tasks.first?.id == task.id)
    }
    
    func testCreateArea() {
        let area = Area()
        let t1 = sut.alter(.create(.area(area)))
        XCTAssertTrue(t1.areas.first?.id == area.id)
    }
    
    func testCreateTag() {
        let tag = Tag(name: "Family")
        let t1 = sut.alter(.create(.tag(tag)))
        XCTAssertTrue(t1.tags.first?.name == "Family")
    }
    
    // MARK: - Delete
    func testDeleteTask() {
        let task = Task()
        let t1 = sut.alter(.create(.task(task)))
        let t2 =  t1.alter(.delete(.task(task)))
        XCTAssertTrue(t2.tasks.isEmpty)
    }
    
    func testDeleteAreas() {
        let area = Area()
        let t1 = sut.alter(.create(.area(area)))
        let t2 =  t1.alter(.delete(.area(area)))
        XCTAssertTrue(t2.areas.isEmpty)
    }
    
    func testDeleteTags() {
        let tag = Tag(name: "Test tag")
        let t1 = sut.alter(.create(.tag(tag)))
        let t2 =  t1.alter(.delete(.tag(tag)))
        XCTAssertTrue(t2.tags.isEmpty)
        
        
    }
    
    // MARK: - Update through object specific DSL
    func testTaskDSL() {
        
        let originalTask = Task()
        let checkItem = CheckItem(task: originalTask.id)
        let tag = Tag(name: "Test")
        
        let changes: [Task.Change] = [
            .title("My title"),
            .notes("My notes"),
            .area(UUID()),
            .date(Date()),
            .deadline(Date()),
            .project(UUID()),
            .actionGroup(UUID()),
            .type(.project),
            .status(.completed),
            .index(3),
            .todayIndex(4),
            .trash,
            .untrash,
            .recurrency(.annual(startDate: Date())),
            .add(.checkItem(checkItem)),
            .add(.tag(tag)),
            .remove(.checkList(checkItem)),
            .remove(.tag(tag))
        ]
        
        var t1 = sut.alter(.create(.task(originalTask)))
        
        changes.forEach { change in
            XCTAssertTrue(t1.tasks.count == 1)
            let unmodified = t1.tasks.first!
            
            t1 = t1.alter(.update(.task(unmodified, with: change)))
            
            let expected = unmodified.alter(change)
            let modified = t1.tasks.first!
            
            XCTAssertTrue(modified == expected)
        }
    }
    
    func testAreaDSL() {
        
        let tag = Tag(name: "Work")

        let changes: [Area.Change] = [
            .title("My new area"),
            .makeVisible,
            .makeInvisible,
            .addTag(tag),
            .removeTag(tag)
        ]
        
        let originalArea = Area()
        var t1 = sut.alter(.create(.area(originalArea)))
       
        changes.forEach { change in
            
            XCTAssertTrue(t1.areas.count == 1)
            let unmodified = t1.areas.first!
            
            t1 = t1.alter(.update(.area(unmodified, with: change)))
            
            let expected = unmodified.alter(change)
            let modified = t1.areas.first!
            
            XCTAssertTrue(modified == expected)
        }
    }
    
    func testTagDSL() {
        let originalTag = Tag(name: "Original tag")
        let childTag = Tag(name: "Family")
        let changes: [Tag.Change] = [
            .name("Work"),
            .add(childTag),
            .remove(childTag),
            .parent(UUID()),
            .removeParent,
            .index(5)
        ]
        
        var t1 = sut.alter(.create(.tag(originalTag)))
        
        changes.forEach { change in
            
            XCTAssertTrue(t1.tags.count == 1)
            
            let unmodified = t1.tags.first!
            t1 = sut.alter(.update(.tag(unmodified, with: change)))
            
            let expected = unmodified.alter(change)
            let modified = t1.tags.first!
            
            XCTAssertTrue(modified == expected)
        }
    }
    
    func testConverTaskWithCheckItemsToProject() {
        
        let t0Task = Task().alter(
            .project(UUID()),
            .actionGroup(UUID()),
            .index(4)
        )
        
        let checkItems: [Task.Change] = Array(1...3).map {
            .add(.checkItem(
                CheckItem(task: t0Task.id)
                    .alter(.title("Task \($0)"))
            ))
        }
        
        let t1Task = t0Task.alter(checkItems)
        
        let t1 = sut
            .alter(.create(.task(t1Task)))
            .alter(.update(.task(t1Task, with: .type(.project))))
        
        XCTAssertTrue(t1Task.checkList.count == 3)
        XCTAssertTrue(t1.tasks.count == 4)
       
        let tasks = t1.tasks.filter {$0.type != .project}
        XCTAssertTrue(tasks.count == 3)
        
        tasks.forEach {
            XCTAssertTrue($0.project == t1Task.id)
        }
    }
    
    func testConvertHeadingWithSubtasksToProject() {
        let heading = Task().alter(.type(.heading))
        let createCMD = Array(1...4)
            .map { _ in Task().alter(.actionGroup(heading.id)) }
            .map { AppState.Change.create(.task($0)) }
        
        let t1 = sut.alter([.create(.task(heading))] + createCMD)
        
        XCTAssertTrue(t1.tasks.count == 5)
        XCTAssertTrue(t1.tasks.filter {$0.type == .project}.isEmpty)
        
        let t2 = t1.alter(.update(.task(heading, with: .type(.project))))
        let modifiedHeading = t2.tasks.filter { $0.type == .project }.first
        
        XCTAssertNotNil(modifiedHeading)
        let subTasks = t2.tasks.filter { $0.type != .project }
        XCTAssertTrue(subTasks.count == 4)
        subTasks.forEach {
            XCTAssertNil($0.actionGroup)
        }
    }
}


// MARK: - Equatable conformance
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
