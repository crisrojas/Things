//
//  CoreData.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 12/03/2023.
//
@testable import ThingsCore

final class CoreDataStoreTests: StoreTests {

    let controller = PersistenceController(inMemory: true)
    override func setUpWithError() throws {
        sut = createCoreDataStore(controller: controller)
    }
}
