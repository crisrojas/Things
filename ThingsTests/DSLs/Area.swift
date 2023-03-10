//
//  Area.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//

import XCTest
@testable import Things

final class AreaTests: XCTestCase {
    
    let sut = Area()
    
    func testSetTitle() {
        let t1 = sut.alter(.title("My area title"))
        XCTAssertTrue(t1.title == "My area title")
    }
    
    func testSetVisible() {
        let t1 = sut.alter(.makeVisible)
        XCTAssertTrue(t1.visible)
    }
    
    func testSetInvisible() {
        let t1 = sut.alter(.makeVisible, .makeInvisible)
        XCTAssertFalse(t1.visible)
    }
    
    func testSetIndex() {
        let t1 = sut.alter(.index(2))
        XCTAssertTrue(t1.index == 2)
    }
    
    func testAddTag() {
        let tag = Tag(name: "Important")
        let t1 = sut.alter(.addTag(tag))
        XCTAssertFalse(t1.tags.isEmpty)
        XCTAssertTrue(tag.id == t1.tags.first!.id)
    }
    
    func testRemoveTag() {
        let tag = Tag(name: "Family")
        let t1 = sut.alter(.addTag(tag), .removeTag(tag))
        XCTAssertTrue(t1.tags.isEmpty)
    }
    
}

