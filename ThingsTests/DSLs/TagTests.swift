//
//  Tag.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 12/03/2023.
//

import XCTest
@testable import Things

final class TagTests: XCTestCase {
    
    let sut = Tag(name: "Work")
    
    func testChangeName() {
        let t1 = sut.alter(.name("Family"))
        XCTAssertTrue(t1.name == "Family")
    }
    
    func testChangeParent() {
        let parent = UUID()
        let t1 = sut.alter(.parent(parent))
        XCTAssertTrue(t1.parent == parent)
    }
    
    func testChangeIndex() {
        let t1 = sut.alter(.index(3))
        XCTAssertEqual(t1.index, 3)
    }
    
    func testRemoveParent() {
        let parent = UUID()
        let t1 = sut.alter(.parent(parent), .removeParent)
        XCTAssertNil(t1.parent)
    }    
}
