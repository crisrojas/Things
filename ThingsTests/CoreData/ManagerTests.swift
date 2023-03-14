//
//  Manager.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 12/03/2023.
//

import XCTest
import CoreData
@testable import Things

@available(iOS 15.0.0, *)
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
    
    func testCreateCheckItem() async throws {
        let task = Task()
        
        try await sut.create(task)
        try await sut.create(CheckItem(task: task.id))
        let objects = try await sut.readCheckItems()
        XCTAssertEqual(objects.count, 1)
    }
    
    func testCreateTask() async throws {
        try await sut.create(Task())
        
        let objects = try await sut.readTasks()
        XCTAssertEqual(objects.count, 1)
    }
    
    func testCreateArea() async throws {
        var objects = try await sut.readAreas()
        XCTAssertTrue(objects.count == 0)

        try await sut.create(Area())
        objects = try await sut.readAreas()
        XCTAssertEqual(objects.count, 1)
    }
    
    func testDeleteTask() async throws {
        let task = Task()
        try await sut.create(task)

        var objects = try await sut.readTasks()
        XCTAssertEqual(objects.count, 1)
        try await sut.delete(task: task.id)
        
        objects = try await sut.readTasks()
        XCTAssertEqual(objects.count, 0)
    }
    
    func testDeleteArea() async throws {
        let area = Area()
        try await sut.create(area)
        
        var objects = try await sut.readAreas()
        XCTAssertEqual(objects.count, 1)
        try await sut.delete(area: area.id)
        objects = try await sut.readAreas()
        XCTAssertEqual(objects.count, 0)
    }
    
    func testDeleteCheckList() async throws {
        let task = Task()
        let checkItem = CheckItem(task: task.id)
        try await sut.create(task)
        try await sut.create(checkItem)
        
//        var objects = try await sut.readCheckItems()
//        XCTAssertEqual(objects.count, 1)
//        try await sut.delete(checkItem: checkItem.id)
//        objects = try await sut.readCheckItems()
//        XCTAssertEqual(objects.count, 0)
    }
}

