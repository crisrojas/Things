//
//  ThingsTests.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//

import XCTest
@testable import Things

final class TaskTests: XCTestCase {
    
    let sut: Task = Task()

    func testDefaults() throws {
        XCTAssertTrue(sut.title.isEmpty)
        XCTAssertTrue(sut.notes.isEmpty)
        XCTAssertNil(sut.date)
        XCTAssertNil(sut.dueDate)
        XCTAssertNil(sut.area)
        XCTAssertNil(sut.project)
        XCTAssertNil(sut.actionGroup)
        XCTAssertTrue(sut.tags.isEmpty)
        XCTAssertTrue(sut.checkList.isEmpty)
        XCTAssertTrue(sut.type == .task)
        XCTAssertTrue(sut.status == .open)
        XCTAssertTrue(sut.index == 0)
        XCTAssertTrue(sut.todayIndex == 0)
        XCTAssertFalse(sut.trashed)
        XCTAssertNil(sut.recurrencyRule)
    }
    
    func testSetInfo() {
        
        let t1 = sut.alter(.title("My new task"))
        XCTAssertTrue(t1.title == "My new task")
        
        let t2 = t1.alter(.notes("My notes"))
        XCTAssertTrue(t2.notes == "My notes")
        
        
        XCTAssertTrue(modDateChange(t1))
        XCTAssertTrue(modDateChange(t1,  t2))
    }
    
    
    func testSetDeadline() {
        let dueDate = Date()
        let t1 = sut.alter(.deadline(dueDate))
        XCTAssertTrue(t1.dueDate == dueDate)
        XCTAssertTrue(modDateChange(t1))
    }
    
    func testSetDate() {
        let date = Date()
        let t1 = sut.alter(.date(date))
        XCTAssertTrue(t1.date == date)
        XCTAssertTrue(modDateChange(t1))
    }
    
    func testSetArea() {
        let area = Area()
        let t1 = sut.alter(.area(area.id))
        
        XCTAssertTrue(t1.area == area.id)
        XCTAssertTrue(modDateChange(t1))
    }
    
    func testSetProject() {
        let project = Task().alter(.type(.project))
        let t1 = sut.alter(.project(project.id))
        
        XCTAssertTrue(project.type == .project)
        XCTAssertTrue(t1.project == project.id)
        XCTAssertTrue(modDateChange(t1))
    }
    
    func testAddToActionGroup() {
        let heading = Task().alter(.type(.heading))
        let t1 = sut.alter(.actionGroup(heading.id))
        
        XCTAssertTrue(heading.type == .heading)
        XCTAssertTrue(t1.actionGroup == heading.id)
        XCTAssertTrue(modDateChange(t1))
    }
    
    func testAddCheckList() {
        let checkItem = CheckItem(task: sut.id)
        let t1 = sut.alter(.add(.checkItem(checkItem)))
        
        XCTAssertTrue(!t1.checkList.isEmpty)
        XCTAssertTrue(t1.checkList.first!.id == checkItem.id)
        XCTAssertTrue(modDateChange(t1))
    }
    
    func testSetIndex() {
        let t1 = sut.alter(.index(2))
        XCTAssertTrue(t1.index == 2)
        XCTAssertTrue(modDateChange(t1))
    }
    
    func testSetTodayIndex() {
        let t1 = sut.alter(.todayIndex(2))
        XCTAssertTrue(t1.todayIndex == 2)
        XCTAssertTrue(modDateChange(t1))
    }
    
    func testAddTag() {
        let tag = Tag(name: "Work")
        let t1 = sut.alter(.add(.tag(tag)))
        
        XCTAssertTrue(!t1.tags.isEmpty)
        XCTAssertTrue(t1.tags.first!.id == tag.id)
        XCTAssertTrue(modDateChange(t1))
    }
    
    func testTrash() {
        let t1 = sut.alter(.trash)
        XCTAssertTrue(t1.trashed)
        XCTAssertTrue(modDateChange(t1))
    }
    
    func testUntrash() {
        let t1 = sut.alter(.trash)
        let t2 = sut.alter(.untrash)
        XCTAssertFalse(t2.trashed)
        XCTAssertTrue(modDateChange(t1))
        XCTAssertTrue(modDateChange(t1, t2))
    }
    
    func testSetStatus() {
        let t1 = sut.alter(.status(.cancelled))
        XCTAssertTrue(t1.status == .cancelled)
        let t2 = sut.alter(.status(.completed))
        XCTAssertTrue(t2.status == .completed)
        XCTAssertTrue(modDateChange(t1))
        XCTAssertTrue(modDateChange(t1, t2))
    }
    
    func testRemoveTag() {
        let tag = Tag(name: "Urgent")
        let t1 = sut.alter(.add(.tag(tag)))
        let t2 = t1.alter(.remove(.tag(tag)))
        XCTAssertTrue(t2.tags.isEmpty)
        XCTAssertTrue(modDateChange(t1))
        XCTAssertTrue(modDateChange(t1, t2))
    }
    
    func testRemoveCheckItem() {
        let checkItem = CheckItem(task: sut.id)
        let t1 = sut.alter(.add(.checkItem(checkItem)))
        let t2 = t1.alter(.remove(.checkList(checkItem)))
        
        XCTAssertTrue(t2.checkList.isEmpty)
        XCTAssertTrue(modDateChange(t1))
        XCTAssertTrue(modDateChange(t1, t2))
    }
    
    
    func testRemoveDeadline() {
        let t1 = sut.alter(.deadline(Date()))
        let t2 = t1.alter(.remove(.deadline))
        XCTAssertNotNil(t1.dueDate)
        XCTAssertNil(t2.dueDate)
        XCTAssertTrue(modDateChange(t1))
        XCTAssertTrue(modDateChange(t1, t2))
    }
    
    func testRemoveProject() {
        let t1 = sut.alter(.project(UUID()))
        let t2 = t1.alter(.remove(.project))
        XCTAssertNotNil(t1.project)
        XCTAssertNil(t2.project)
        XCTAssertTrue(modDateChange(t1))
        XCTAssertTrue(modDateChange(t1, t2))
    }
    
    
    func testRemoveArea() {
        let t1 = sut.alter(.area(UUID()))
        let t2 = t1.alter(.remove(.area))
        XCTAssertNotNil(t1.area)
        XCTAssertNil(t2.area)
        XCTAssertTrue(modDateChange(t1))
        XCTAssertTrue(modDateChange(t1, t2))
    }
    
    
    func testRemoveActionGroup() {
        let t1 = sut.alter(.actionGroup(UUID()))
        let t2 = t1.alter(.remove(.actionGroup))
        XCTAssertNotNil(t1.actionGroup)
        XCTAssertNil(t2.actionGroup)
        XCTAssertTrue(modDateChange(t1))
        XCTAssertTrue(modDateChange(t1, t2))
    }
    
    func testRemoveDate() {
        let t1 = sut.alter(.date(Date()))
        let t2 = t1.alter(.remove(.date))
        XCTAssertNotNil(t1.date)
        XCTAssertNil(t2.date)
        XCTAssertTrue(modDateChange(t1))
        XCTAssertTrue(modDateChange(t1, t2))
    }
    
    
    /// Checks if the new instance has a different modificationDate from the SUT
    private func modDateChange(_ t2: Task) -> Bool {
        modDateChange(sut, t2)
    }
     
    private func modDateChange(_ t1: Task, _ t2: Task) -> Bool {
        t1.modificationDate !=  t2.modificationDate
    }
        
    
}
