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
    /// Only one case of the update enum is needed for asserting the objects are being updated
    /// since we're reusing their [Object].Change enum, which has been already tested
    func testTaskDSL() {
        
        let task = Task()
        let t1 = sut.alter(.create(.task(task)))
        let t2 = t1.alter(.update(.task(task, with: .title("New title"))))
        XCTAssertTrue(t2.tasks.first?.title == "New title")
        
        let item = CheckItem(task: task.id)
        let t3 = t1.alter(.update(.task(task, with: .add(.checkItem(item)))))
        XCTAssertTrue(t3.tasks.first?.checkList.first?.id == item.id)
    }
    
    func testAreaDSL() {
        let area = Area()
        let t1 = sut.alter(.create(.area(area)))
        let t2 = t1.alter(.update(.area(area, with: .title("Work"))))
        XCTAssertTrue(t2.areas.first?.title == "Work")
    }
}

