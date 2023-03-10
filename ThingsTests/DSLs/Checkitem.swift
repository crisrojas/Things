//
//  Checkitem.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//

import XCTest
@testable import Things

final class CheckItemTests: XCTestCase {
    
    let sut = CheckItem(task: UUID())
    
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
    }
    
    func testSetIndex() {
        let t1 = sut.alter(.index(3))
        XCTAssertTrue(t1.index == 3)

    }
}
