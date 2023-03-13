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
        try await sut.create(CheckItem(task: UUID()))
        let objects = try await sut.readCheckItems()
        XCTAssertEqual(objects.count, 1)
    }
    
    func testCreateTask() async throws {
        try await sut.create(ToDo())
        
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
        let task = ToDo()
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
        let checkItem = CheckItem(task: UUID())
        try await sut.create(checkItem)
        
        var objects = try await sut.readCheckItems()
        XCTAssertEqual(objects.count, 1)
        try await sut.delete(checkItem: checkItem.id)
        objects = try await sut.readCheckItems()
        XCTAssertEqual(objects.count, 0)
    }
}

