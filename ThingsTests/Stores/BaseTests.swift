//
//  DiskStore.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 12/03/2023.
//

import XCTest
@testable import Things

class StoreTests: XCTestCase {

    var sut: StateStore!

    override func setUp() async throws {
        sut = createRamStore()
    }

    override func tearDownWithError() throws {
        sut.destroy()
        sut = nil
    }

    // MARK: - Create
    func testCreateTask() {
        let task = ToDo()
        sut.change(.create(.task(task)))
        XCTAssertTrue(sut.state().tasks.first?.id == task.id)
    }

    func testCreateArea() {
        let area = Area()
        sut.change(.create(.area(area)))
        XCTAssertTrue(sut.state().areas.first?.id == area.id)
    }

    func testCreateTag() {
        let tag = Tag(name: "Test tag")
        sut.change(.create(.tag(tag)))
        XCTAssertTrue(sut.state().tags.first?.id == tag.id)
    }

    // MARK: - Delete
    func testDeleteTask() {
        let task = ToDo()
        sut.change(.create(.task(task)))
        sut.change(.delete(.task(task)))
        XCTAssertTrue(sut.state().tags.isEmpty)
    }

    func testDeleteArea() {
        let area = Area()
        sut.change(.create(.area(area)))
        sut.change(.delete(.area(area)))
        XCTAssertTrue(sut.state().areas.isEmpty)
    }

    func testDeleteTag() {
        let tag = Tag(name: "Testing")
        sut.change(.create(.tag(tag)))
        sut.change(.delete(.tag(tag)))
        XCTAssertTrue(sut.state().tags.isEmpty)
    }

    // MARK: - Update
    // MARK: - Task
    func testTaskDSL() {
        let originalTask = ToDo()
        let checkItem = CheckItem(task: originalTask.id)
        let tag = Tag(name: "Test")

        let changes: [ToDo.Change] = [
            .title("My title"),
            .notes("My notes"),
            .area(UUID()),
            .date(Date()),
            .deadline(Date()),
            .project(UUID()),
            .actionGroup(UUID()),
            .type(.project),
            .status(.completed),
            .index(3),
            .todayIndex(4),
            .trash,
            .untrash,
            .recurrency(.annual(startDate: Date())),
            .add(.checkItem(checkItem)),
            .add(.tag(tag)),
            .remove(.checkList(checkItem)),
            .remove(.tag(tag))
        ]

        sut.change(.create(.task(originalTask)))

        changes.forEach { change in
            XCTAssertTrue(sut.state().tasks.count == 1)
            let unmodified = sut.state().tasks.first!

            sut.change(.update(.task(unmodified, with: change)))

            let expected = unmodified.alter(change)
            let modified = sut.state().tasks.first!

            XCTAssertTrue(modified == expected)
        }
    }

    func testAreaDSL() {

        let tag = Tag(name: "Work")

        let changes: [Area.Change] = [
            .title("My new area"),
            .makeVisible,
            .makeInvisible,
            .addTag(tag),
            .removeTag(tag)
        ]

        let originalArea = Area()
        sut.change(.create(.area(originalArea)))

        changes.forEach { change in

            XCTAssertTrue(sut.state().areas.count == 1)
            let unmodified = sut.state().areas.first!

            sut.change(.update(.area(unmodified, with: change)))

            let expected = unmodified.alter(change)
            let modified = sut.state().areas.first!

            XCTAssertTrue(modified == expected)
        }
    }

    func testTagDSL() {
        let originalTag = Tag(name: "Original tag")
        let childTag = Tag(name: "Family")
        let changes: [Tag.Change] = [
            .name("Work"),
            .add(childTag),
            .remove(childTag),
            .parent(UUID()),
            .removeParent,
            .index(5)
        ]

        sut.change(.create(.tag(originalTag)))

        changes.forEach { change in

            XCTAssertTrue(sut.state().tags.count == 1)

            let unmodified = sut.state().tags.first!
            sut.change(.update(.tag(unmodified, with: change)))

            let expected = unmodified.alter(change)
            let modified = sut.state().tags.first!

            XCTAssertTrue(modified == expected)
        }
    }

    func testConverTaskWithCheckItemsToProject() {

        let t0Task = ToDo().alter(
            .project(UUID()),
            .actionGroup(UUID()),
            .index(4)
        )

        let checkItems: [ToDo.Change] = Array(1...3).map {
            .add(.checkItem(
                CheckItem(task: t0Task.id)
                    .alter(.title("Task \($0)"))
            ))
        }

        let t1Task = t0Task.alter(checkItems)

        sut.change(.create(.task(t1Task)))
        sut.change(.update(.task(t1Task, with: .type(.project))))

        XCTAssertTrue(t1Task.checkList.count == 3)
        XCTAssertTrue(sut.state().tasks.count == 4)

        let tasks = sut.state().tasks.filter {$0.type != .project}
        XCTAssertTrue(tasks.count == 3)

        tasks.forEach {
            XCTAssertTrue($0.project == t1Task.id)
        }
    }
    
    func testConvertHeadingWithSubtasksToProject() {
        let heading = ToDo().alter(.type(.heading))
        let createCMD = Array(1...4)
            .map { _ in ToDo().alter(.actionGroup(heading.id)) }
            .map { AppState.Change.create(.task($0)) }
        
        sut.change(.create(.task(heading)))
        createCMD.forEach {sut.change($0)}
        
        XCTAssertTrue(sut.state().tasks.count == 5)
        XCTAssertTrue(sut.state().tasks.filter {$0.type == .project}.isEmpty)
        
        sut.change(.update(.task(heading, with: .type(.project))))
        let modifiedHeading = sut.state().tasks.filter { $0.type == .project }.first
        
        XCTAssertNotNil(modifiedHeading)
        let subTasks = sut.state().tasks.filter { $0.type != .project }
        XCTAssertTrue(subTasks.count == 4)
        subTasks.forEach {
            XCTAssertNil($0.actionGroup)
        }
    }
}


final class DiskStoreTests: StoreTests {
    override func setUpWithError() throws {
        sut = createDiskStore(path: "diskStore-test.json")
    }
}


