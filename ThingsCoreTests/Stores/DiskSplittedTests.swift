//
//  DiskSplittedTests.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 14/03/2023.
//

@testable import ThingsCore

final class DiskSplittedStoreTests: StoreTests {
    override func setUpWithError() throws {
        sut = createSplittedDiskStore(
            tasks: "tasks-tests",
            areas: "areas-tests",
            tags: "tags-tests",
            lists: "lists-tests"
        )
    }
}
