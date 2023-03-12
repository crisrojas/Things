//
//  CoreData.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 12/03/2023.
//

import XCTest
@testable import Things

final class CoreDataStoreTests: StoreTests {
    override func setUpWithError() throws {
        sut = createCoreDataStore(inMemory: true)
    }
    
    override func testCreateTask() {}
    override func testCreateArea() {}
    override func testCreateTag() {}
    override func testDeleteTask() {}
    override func testDeleteArea() {}
    override func testDeleteTag() {}
    override func testTaskDSL() {}
    override func testTagDSL() {}
    override func testAreaDSL() {}
    override func testConverTaskWithCheckItemsToProject() {}
    override func testConvertHeadingWithSubtasksToProject() {}
}
