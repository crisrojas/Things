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
        XCTAssertNil(sut.modificationDate)
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
        
        assertModDateChanged(t1, t2)
    }
    
    
    func testSetDeadline() {
        let dueDate = Date()
        let t1 = sut.alter(.deadline(dueDate))
        XCTAssertTrue(t1.dueDate == dueDate)
        XCTAssertTrue(modDateChanged(t1))
    }
    
    func testSetDate() {
        let date = Date()
        let t1 = sut.alter(.date(date))
        XCTAssertTrue(t1.date == date)
        XCTAssertTrue(modDateChanged(t1))
    }
    
    func testSetArea() {
        let area = Area()
        let t1 = sut.alter(.area(area.id))
        
        XCTAssertTrue(t1.area == area.id)
        XCTAssertTrue(modDateChanged(t1))
    }
    
    
    func testSetProject() {
        
        let project = Task().alter(.type(.project))
        
        let t1 = sut.alter(.project(project.id))
        
        XCTAssertTrue(project.type == .project)
        XCTAssertTrue(t1.project == project.id)
        
        
        XCTAssertTrue(modDateChanged(t1))
    }
    
    
    func testConvertToProject() {
       
        let task = Task()
            .alter(
                .project(UUID()),
                .actionGroup(UUID()),
                .index(4),
                .add(.checkItem(UUID())),
                .add(.checkItem(UUID())),
                .add(.checkItem(UUID()))
            )
    
        XCTAssertTrue(task.checkList.count == 3)

        let project = task.alter(.type(.project))
        XCTAssertTrue(project.type == .project)
        XCTAssertTrue(project.checkList.isEmpty)
        XCTAssertNil(project.project)
        XCTAssertNil(project.actionGroup)
        XCTAssertTrue(project.index == 0)
    }
    
    func testAddToActionGroup() {
        let heading = Task().alter(.type(.heading))
        let t1 = sut.alter(.actionGroup(heading.id))
        
        XCTAssertTrue(heading.type == .heading)
        XCTAssertTrue(t1.actionGroup == heading.id)
        XCTAssertTrue(modDateChanged(t1))
    }
    
    func testAddCheckList() {
        let checkItem = CheckItem(task: sut.id)
        let t1 = sut.alter(.add(.checkItem(checkItem.id)))
        
        XCTAssertTrue(!t1.checkList.isEmpty)
        XCTAssertTrue(t1.checkList.first == checkItem.id)
        XCTAssertTrue(modDateChanged(t1))
    }
    
    func testSetIndex() {
        let t1 = sut.alter(.index(2))
        XCTAssertTrue(t1.index == 2)
        XCTAssertTrue(modDateChanged(t1))
    }
    
    func testSetTodayIndex() {
        let t1 = sut.alter(.todayIndex(2))
        XCTAssertTrue(t1.todayIndex == 2)
        XCTAssertTrue(modDateChanged(t1))
    }
    
    func testAddTag() {
        let tag = Tag(name: "Work")
        let t1 = sut.alter(.add(.tag(tag.id)))
        
        XCTAssertTrue(!t1.tags.isEmpty)
        XCTAssertTrue(t1.tags.first == tag.id)
        XCTAssertTrue(modDateChanged(t1))
    }
    
    func testTrash() {
        let t1 = sut.alter(.trash)
        XCTAssertTrue(t1.trashed)
        XCTAssertTrue(modDateChanged(t1))
    }
    
    func testUntrash() {
        let t1 = sut.alter(.trash)
        let t2 = sut.alter(.untrash)
        XCTAssertFalse(t2.trashed)
        assertModDateChanged(t1, t2)
    }
    
    func testSetStatus() {
        let t1 = sut.alter(.status(.cancelled))
        XCTAssertTrue(t1.status == .cancelled)
        let t2 = sut.alter(.status(.completed))
        XCTAssertTrue(t2.status == .completed)
        assertModDateChanged(t1, t2)
    }
    
    func testRemoveTag() {
        let tag = Tag(name: "Urgent")
        let t1 = sut.alter(.add(.tag(tag.id)))
        let t2 = t1.alter(.remove(.tag(tag.id)))
        XCTAssertTrue(t2.tags.isEmpty)
        assertModDateChanged(t1, t2)
    }
    
    func testRemoveCheckItem() {
        let checkItem = CheckItem(task: sut.id)
        let t1 = sut.alter(.add(.checkItem(checkItem.id)))
        let t2 = t1.alter(.remove(.checkItem(checkItem.id)))
        
        XCTAssertTrue(t2.checkList.isEmpty)
        assertModDateChanged(t1, t2)
    }
    
    
    func testRemoveDeadline() {
        let t1 = sut.alter(.deadline(Date()))
        let t2 = t1.alter(.remove(.deadline))
        XCTAssertNotNil(t1.dueDate)
        XCTAssertNil(t2.dueDate)
        assertModDateChanged(t1, t2)
    }
    
    func testRemoveProject() {
        let t1 = sut.alter(.project(UUID()))
        let t2 = t1.alter(.remove(.project))
        XCTAssertNotNil(t1.project)
        XCTAssertNil(t2.project)
        assertModDateChanged(t1, t2)
    }
    
    
    func testRemoveArea() {
        let t1 = sut.alter(.area(UUID()))
        let t2 = t1.alter(.remove(.area))
        XCTAssertNotNil(t1.area)
        XCTAssertNil(t2.area)
        assertModDateChanged(t1, t2)
    }
    
    
    func testRemoveActionGroup() {
        let t1 = sut.alter(.actionGroup(UUID()))
        let t2 = t1.alter(.remove(.actionGroup))
        XCTAssertNotNil(t1.actionGroup)
        XCTAssertNil(t2.actionGroup)
        assertModDateChanged(t1, t2)
    }
    
    func testRemoveDate() {
        let t1 = sut.alter(.date(Date()))
        let t2 = t1.alter(.remove(.date))
        XCTAssertNotNil(t1.date)
        XCTAssertNil(t2.date)
        assertModDateChanged(t1, t2)
    }
    
    func testAddRecurrency() {
        let t1 = sut.alter(.recurrency(.daily(startDate: Date())))
        XCTAssertNotNil(t1.recurrencyRule)
    }
    
    func testRemoveRecurrency() {
        let t1 = sut
            .alter(.recurrency(.daily(startDate: Date())))
            .alter(.remove(.recurrency))
        
        XCTAssertNil(t1.recurrencyRule)
    }
    
    func testDuplicate() {
        let t1 = sut.alter(.index(1))
        XCTAssertNotNil(t1.modificationDate)
        
        let t2 = t1.alter(.duplicate)
        XCTAssertTrue(t1.modificationDate == t2.modificationDate)
        
    }
    
    func testVariadicChanges() {
        let t1 = sut.alter(.title("New title"), .index(3), .status(.completed), .trash)
        XCTAssertTrue(t1.title == "New title")
        XCTAssertTrue(t1.index == 3)
        XCTAssertTrue(t1.status == .completed)
        XCTAssertTrue(t1.trashed)
    }
    
    private func assertModDateChanged(_ t1: Task, _ t2: Task) {
        XCTAssertTrue(modDateChanged(t1))
        XCTAssertTrue(modDateChange(t1, t2))
    }
    
    
    /// Checks if the new instance has a different modificationDate from the SUT
    private func modDateChanged(_ t2: Task) -> Bool {
        modDateChange(sut, t2)
    }
     
    /// @todo: Sometimes testsUntrash fails here. My guess is that the difference in date creation is too small
    /// and the Swift clock is not granular enough when comparing those dates
    private func modDateChange(_ t1: Task, _ t2: Task) -> Bool {
        t1.modificationDate !=  t2.modificationDate
    }
}
