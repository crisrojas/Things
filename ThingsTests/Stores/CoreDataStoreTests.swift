//
//  CoreData.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 12/03/2023.
//

import XCTest
@testable import Things

final class CoreDataStoreTests: StoreTests {

    let controller = PersistenceController(inMemory: true)
    override func setUpWithError() throws {
        sut = createCoreDataStore(controller: controller)
    }

//    override func testCreateTask() async throws {}
//    override func testCreateArea() async throws {}
//    override func testCreateCheckItem() async throws {}
//    override func testCreateTag() async throws {}
//    override func testDeleteTask() async throws {}
//    override func testDeleteArea() async throws {}
//    override func testDeleteTag() async throws {}
//    override func testDeleteCheck() async throws {}
//    override func testTaskDSL() async throws {}
//    override func testTagDSL() async throws {}
//    override func testAreaDSL() async throws {}
    override func testItemDSL() async throws {}
    override func testConverTaskWithCheckItemsToProject() async throws {}
    override func testConvertHeadingWithSubtasksToProject() async throws {}
}
