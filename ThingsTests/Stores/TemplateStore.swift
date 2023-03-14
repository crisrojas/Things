//
//  TemplateStore.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 14/03/2023.
//


@testable import Things
/// To implement and test a store:
/// - Copy paste this file
/// - Rename the class to <YourStore>Tests
/// - Make it inherit from the StoreTests class by uncomenting conformance
/// - Uncomment override keyword
/// - Set the store (sut) using the method that returns your store implementation
/// - Comment/Erase the first override
/// - Run the tests
/// - The erased override tests will fail. Fix it
/// - Comment/Erase the second override
/// - Repeat until there aren't any override
final class DefaultStoreTests /*: StoreTests */ {
    
    /*override*/ func testDestroyStore_ResetsState() async throws {}
    /*override*/ func testChangesSuscription() async throws {}
    /*override*/ func testCreateTask() async throws {}
    /*override*/ func testCreateArea() async throws {}
    /*override*/ func testCreateTag() async throws {}
    /*override*/ func testCreateCheckItem() async throws {}
    /*override*/ func testCreateItemWithInexistentTask() async throws {}
    /*override*/ func testDeleteTask() async throws {}
    /*override*/ func testDeleteArea() async throws {}
    /*override*/ func testDeleteTag() async throws {}
    /*override*/ func testTagDeletionRemoveRelationships() async throws {}
    /*override*/ func testDeleteItem() async throws {}
    /*override*/ func testTaskDSL() async throws {}
    /*override*/ func testAreaDSL() async throws {}
    /*override*/ func testTagDSL() async throws {}
    /*override*/ func testItemDSL() async throws {}
    /*override*/ func testConverTaskWithCheckItemsToProject() async throws {}
    /*override*/ func testConvertHeadingWithSubtasksToProject() async throws {}
}
