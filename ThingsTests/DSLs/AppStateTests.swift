////
////  AppState.swift
////  ThingsTests
////
////  Created by Cristian Felipe Patiño Rojas on 12/03/2023.
////
//
//import XCTest
//@testable import Things
//
//final class AppStateTests: XCTestCase {
//
//    let sut = AppState()
//
//    // MARK: - Create
//    func testCreateTask() {
//        let task = ToDo()
//        let t1 = sut.alter(.create(.task(task)))
//        XCTAssertTrue(t1.tasks.first?.id == task.id)
//    }
//
//    func testCreateArea() {
//        let area = Area()
//        let t1 = sut.alter(.create(.area(area)))
//        XCTAssertTrue(t1.areas.first?.id == area.id)
//    }
//
//    func testCreateTag() {
//        let tag = Tag(name: "Family")
//        let t1 = sut.alter(.create(.tag(tag)))
//        XCTAssertTrue(t1.tags.first?.name == "Family")
//    }
//
//    func testCreateCheckList() {
//        let task = ToDo()
//        let t1 = sut.alter(.create(.task(task)))
//
//        let item = CheckItem(task: task.id)
//        let t2 = t1.alter(.create(.checkItem(item)))
//
//        let injectedTask = t2.tasks.first!
//
//        XCTAssertFalse(injectedTask.checkList.isEmpty)
//        XCTAssertFalse(t2.checkItems.isEmpty)
//        XCTAssertTrue(t2.tasks.first?.checkList.first == item.id)
//        XCTAssertTrue(t2.checkItems.first!.id == item.id)
//        XCTAssertTrue(t2.checkItems.first!.task == task.id)
//    }
//
//    // MARK: - Delete
//    func testDeleteTask() {
//        let task = ToDo()
//        let t1 = sut.alter(.create(.task(task)))
//        let t2 =  t1.alter(.delete(.task(task)))
//        XCTAssertTrue(t2.tasks.isEmpty)
//    }
//
//    func testDeleteAreas() {
//        let area = Area()
//        let t1 = sut.alter(.create(.area(area)))
//        let t2 =  t1.alter(.delete(.area(area)))
//        XCTAssertTrue(t2.areas.isEmpty)
//    }
//
//    func testDeleteTag() {
//        let tag = Tag(name: "Test tag")
//        let t1 = sut.alter(.create(.tag(tag)))
//        let t2 =  t1.alter(.delete(.tag(tag.id)))
//        XCTAssertTrue(t2.tags.isEmpty)
//    }
//
//    func testDeleteTagAssociated() {
//        let tag = Tag(name: "Work")
//        let task = ToDo().alter(.add(.tag(tag.id)))
//        let area = Area().alter(.addTag(tag.id))
//
//
//        let t1 = sut
//            .alter(.create(.tag(tag)))
//            .alter(.create(.area(area)))
//            .alter(.delete(.tag(tag.id)))
//
//        XCTAssertTrue(t1.tags.isEmpty)
//        XCTAssertFalse(t1.areas.isEmpty)
//        XCTAssertTrue(t1.areas[0].tags.isEmpty)
//    }
//
//    func testDeleteCheckItem() {
//        let task = ToDo()
//        let t1 = sut.alter(.create(.task(task)))
//
//        let item = CheckItem(task: task.id)
//        let t2 = t1.alter(.create(.checkItem(item)))
//        let t3 = t2.alter(.delete(.checkItem(item)))
//
//        XCTAssertTrue(t3.checkItems.isEmpty)
//        XCTAssertTrue(t3.tasks.first!.checkList.isEmpty)
//    }
//
//    // MARK: - Update through object specific DSL
//    func testTaskDSL() {
//
//        let originalTask = ToDo()
//        let checkItem = CheckItem(task: originalTask.id)
//        let tag = Tag(name: "Test")
//
//        let changes: [ToDo.Change] = [
//            .title("My title"),
//            .notes("My notes"),
//            .area(UUID()),
//            .date(Date()),
//            .deadline(Date()),
//            .project(UUID()),
//            .actionGroup(UUID()),
//            .type(.project),
//            .status(.completed),
//            .index(3),
//            .todayIndex(4),
//            .trash,
//            .untrash,
//            .recurrency(.annual(startDate: Date())),
//            .add(.checkItem(checkItem.id)),
//            .add(.tag(tag.id)),
//            .remove(.checkItem(checkItem.id)),
//            .remove(.tag(tag.id))
//        ]
//
//        var t1 = sut.alter(.create(.task(originalTask)))
//
//        changes.forEach { change in
//            XCTAssertTrue(t1.tasks.count == 1)
//            let unmodified = t1.tasks.first!
//
//            t1 = t1.alter(.update(.task(unmodified, with: change)))
//
//            let expected = unmodified.alter(change)
//            let modified = t1.tasks.first!
//
//            XCTAssertTrue(modified == expected)
//        }
//    }
//
//    func testAreaDSL() {
//
//        let tag = Tag(name: "Work")
//
//        let changes: [Area.Change] = [
//            .title("My new area"),
//            .makeVisible,
//            .makeInvisible,
//            .addTag(tag.id),
//            .removeTag(tag.id)
//        ]
//
//        let originalArea = Area()
//        var t1 = sut.alter(.create(.area(originalArea)))
//
//        changes.forEach { change in
//
//            XCTAssertTrue(t1.areas.count == 1)
//            let unmodified = t1.areas.first!
//
//            t1 = t1.alter(.update(.area(unmodified, with: change)))
//
//            let expected = unmodified.alter(change)
//            let modified = t1.areas.first!
//
//            XCTAssertTrue(modified == expected)
//        }
//    }
//
//    func testTagDSL() {
//        let originalTag = Tag(name: "Original tag")
//        let childTag = Tag(name: "Family")
//        let changes: [Tag.Change] = [
//            .name("Work"),
//            .add(childTag),
//            .remove(childTag),
//            .parent(UUID()),
//            .removeParent,
//            .index(5)
//        ]
//
//        var t1 = sut.alter(.create(.tag(originalTag)))
//
//        changes.forEach { change in
//
//            XCTAssertTrue(t1.tags.count == 1)
//
//            let unmodified = t1.tags.first!
//            t1 = sut.alter(.update(.tag(unmodified, with: change)))
//
//            let expected = unmodified.alter(change)
//            let modified = t1.tags.first!
//
//            XCTAssertTrue(modified == expected)
//        }
//    }
//
//    func testConverTaskWithCheckItemsToProject() {
//
//        var task = ToDo().alter(
//            .project(UUID()),
//            .actionGroup(UUID()),
//            .index(4)
//        )
//
//        let c1 = CheckItem(task: task.id)
//        let c2 = CheckItem(task: task.id)
//        let c3 = CheckItem(task: task.id)
//
//        task = task.alter(
//            .add(.checkItem(c1.id)),
//            .add(.checkItem(c2.id)),
//            .add(.checkItem(c3.id))
//        )
//
//        var s = sut
//            .alter(.create(.task(task)))
//            .alter(.create(.checkItem(c1)))
//            .alter(.create(.checkItem(c2)))
//            .alter(.create(.checkItem(c3)))
//
//
//        XCTAssertEqual(s.checkItems.count, 3)
//
//        s =  s.alter(.update(.task(task, with: .type(.project))))
//        XCTAssertEqual(s.tasks.first?.checkList.count, 0)
//        XCTAssertEqual(s.tasks.count, 4)
//
//        let tasks = s.tasks.filter {$0.type != .project}
//        XCTAssertEqual(tasks.count, 3)
//
//        tasks.forEach {
//            XCTAssertTrue($0.project == task.id)
//        }
//    }
//
//    func testConvertHeadingWithSubtasksToProject() {
//        let heading = ToDo().alter(.type(.heading))
//        let createCMD = Array(1...4)
//            .map { _ in ToDo().alter(.actionGroup(heading.id)) }
//            .map { AppState.Change.create(.task($0)) }
//
//        let t1 = sut.alter([.create(.task(heading))] + createCMD)
//
//        XCTAssertTrue(t1.tasks.count == 5)
//        XCTAssertTrue(t1.tasks.filter {$0.type == .project}.isEmpty)
//
//        let t2 = t1.alter(.update(.task(heading, with: .type(.project))))
//        let modifiedHeading = t2.tasks.filter { $0.type == .project }.first
//
//        XCTAssertNotNil(modifiedHeading)
//        let subTasks = t2.tasks.filter { $0.type != .project }
//        XCTAssertTrue(subTasks.count == 4)
//        subTasks.forEach {
//            XCTAssertNil($0.actionGroup)
//        }
//    }
//}
//
//

