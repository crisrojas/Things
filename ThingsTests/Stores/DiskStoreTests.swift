//
//  DiskStore.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 14/03/2023.
//

import Foundation
@testable import Things

final class DiskStoreTests: StoreTests {
    override func setUpWithError() throws {
        sut = createDiskStore(path: "diskStore-test.json")
    }
}
