//
//  Manager.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 12/03/2023.
//

import XCTest
import CoreData
import ThingsCore

@available(iOS 15.0.0, *)
/* @todo:
 There're some unhandled cases:
 
 what if we create a task/area asociated with an inexistent tag?
 */
final class ManagerTest: XCTestCase {
    
    var context: NSManagedObjectContext!
    var sut: CoreDataManager!
    
    override func setUp() {
        context = PersistenceController(inMemory: true).context()
        sut = CoreDataManager(context: context)
    }
    
    override func tearDown() {
        sut = nil
        context = nil
    }
    
  
    // MARK: - CheckItem
    func testCheckItemCreation_withInexistentParentTask_fails() async throws {
        try await sut.create(Item(task: .init()))
        let objects = try await sut.readCheckItems()
        XCTAssertEqual(objects.count, 0)
    }
    
    func testCheckItemCreation_withExistentParentTask_succeds() async throws {
        let task = Task()
        
        try await sut.create(task)
        try await sut.create(Item(task: task.id))
        let objects = try await sut.readCheckItems()
        XCTAssertEqual(objects.count, 1)
    }
    
    func testDeleteCheckList() async throws {
        let task = Task()
        let checkItem = Item(task: task.id)
        try await sut.create(task)
        try await sut.create(checkItem)
        
        var objects = try await sut.readCheckItems()
        XCTAssertEqual(objects.count, 1)
        try await sut.delete(checkItem: checkItem.id)
        objects = try await sut.readCheckItems()
        XCTAssertEqual(objects.count, 0)
    }
    
    // MARK: - Task
    func testTaskCreation_succeds() async throws {
        try await sut.create(Task())
        
        let objects = try await sut.readTasks()
        XCTAssertEqual(objects.count, 1)
    }
    
    
    func testExistentTaskDeletion_succeeds() async throws {
        let task = Task()
        try await sut.create(task)

        var objects = try await sut.readTasks()
        XCTAssertEqual(objects.count, 1)
        try await sut.delete(task: task.id)
        
        objects = try await sut.readTasks()
        XCTAssertEqual(objects.count, 0)
    }
    
    func testInexistentTaskDeletion_throwsEntityNotFoundError() async throws {
        do {
            try await sut.delete(task: .init())
        } catch {
            let error = error as! CoreDataError
            XCTAssertEqual(error, .entityNotFound)
        }
    }

    #warning("@todo: implement")
    func testTaskCreation_inexistentParent_fails/*not sure this should fail*/() async throws {}
    
    // MARK: - Area
    func testAreaCreation_succeds() async throws {
        var objects = try await sut.readAreas()
        XCTAssertTrue(objects.count == 0)

        try await sut.create(Area())
        objects = try await sut.readAreas()
        XCTAssertEqual(objects.count, 1)
    }
    
    func testExistentAreaDeletion_succeeds() async throws {
        let area = Area()
        try await sut.create(area)
        
        var objects = try await sut.readAreas()
        XCTAssertEqual(objects.count, 1)
        try await sut.delete(area: area.id)
        objects = try await sut.readAreas()
        XCTAssertEqual(objects.count, 0)
    }
    
    func testInexistentAreaDeletion_throwsEntityNotFoundError() async throws {
        do {
            try await sut.delete(area: .init())
        } catch {
            let error = error as! CoreDataError
            XCTAssertEqual(error, .entityNotFound)
        }
    }
    
    // MARK: - Tags
    #warning("@todo: implement")
    func testTagCreation_succeds() async throws {}
    func testTagDeletion_succeds() async throws {}
    
    func testInexistentTagDeletion_throwsEntityNotFoundError() async throws {
        do {
            try await sut.delete(tag: .init())
        } catch {
            let error = error as! CoreDataError
            XCTAssertEqual(error, .entityNotFound)
        }
    }

    func testTagDeletion_withTagAssignedToAreasAndTasks_isUnassigned() async throws {
        
        // Given existen area and task with associated tag
        let tag = Tag(name: "Test tag")
        let area = Area().alter(.addTag(tag.id))
        let task = Task().alter(.add(.tag(tag.id)))
        
        try await sut.create(tag)
        try await sut.create(task)
        try await sut.create(area)
        
        // When deleting tag
        try await sut.delete(tag: tag.id)
        
        // Then
        let tags  = try await sut.readTags()
        let areas = try await sut.readAreas()
        let tasks = try await sut.readTasks()
        let firstArea = try XCTUnwrap(areas.first)
        let firstTask = try XCTUnwrap(tasks.first)
        
        XCTAssertTrue(tags.isEmpty)
        
        // Unassigned from task and area
        XCTAssertTrue(firstArea.tags.isEmpty)
        XCTAssertTrue(firstTask.tags.isEmpty)
        
    }
}

