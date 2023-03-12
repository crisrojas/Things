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
    
    func testRemoveParent() {
        let parent = UUID()
        let t1 = sut.alter(.parent(parent), .removeParent)
        XCTAssertNil(t1.parent)
    
    }
    
    func testAddTag() {
        let t1 = sut.alter(.add(Tag(name: "Project #1")))
        XCTAssertTrue(t1.children.first?.name == "Project #1")
        XCTAssertTrue(t1.children.first?.parent == sut.id)
    }
    
    func testRemoveTag() {
        let tag = Tag(name: "Shopping List")
        let t1 = sut.alter(.add(tag), .remove(tag))
        XCTAssertTrue(t1.children.isEmpty)
    }
    
}
