//
//  Manager.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 12/03/2023.
//

import XCTest

@testable import Things

final class ManagerTest: XCTestCase {
    
    let context = PersistenceController.get(inMemory: true).context()
    var sut: CoreDataManager!
    
    override func setUp() {
        sut = CoreDataManager(context: context)
    }
    
    override func tearDown() {
        sut = nil
    }
    
    
    func testAddTask() {
        let task = ToDo()
        sut.create(task)
//        waitForExpectations(timeout: 2.0) {}
    }
}
