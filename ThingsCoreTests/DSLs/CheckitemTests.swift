//
//  Checkitem.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//

import XCTest
@testable import ThingsCore

final class CheckItemTests: XCTestCase {
    
    let sut = Item(task: UUID())
    
    func testDefaults() {
        XCTAssertFalse(sut.checked)
        XCTAssertTrue(sut.title.isEmpty)
        XCTAssertTrue(sut.index == 0)
    }
    
    func testCheck() {
        let t1 = sut.alter(.check)
        XCTAssertTrue(t1.checked)
    }
    
    func testUncheck() {
        let t1 = sut.alter(.check, .uncheck)
        XCTAssertFalse(t1.checked)
    }
    
    func testSetTitle() {
        let t1 = sut.alter(.title("Hello"))
        XCTAssertTrue(t1.title == "Hello")
        XCTAssertTrue(t1.id == sut.id)
    }
    
    func testSetIndex() {
        let t1 = sut.alter(.index(3))
        XCTAssertTrue(t1.index == 3)

    }
    
    func testVariadicAlter() {
        let t1 = sut.alter(.index(4), .title("Check list"), .check)
        XCTAssertTrue(t1.index == 4)
        XCTAssertTrue(t1.title == "Check list")
        XCTAssertTrue(t1.checked)
    }
}
