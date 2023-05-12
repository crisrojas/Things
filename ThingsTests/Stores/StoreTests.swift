//
//  DiskStore.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 12/03/2023.
//

import XCTest
import CustomDump
@testable import ThingsCore

/// Test default store
class StoreTests: XCTestCase {

    var sut: StateStore!

    override func setUp() async throws {
        sut = createRamStore()
    }

    override func tearDownWithError() throws {
        try sut.destroy()
        sut = nil
    }
    
    func testDestroyStore_ResetsState() async throws {
        let initialVal = AppState()
        try await sut.change(.create(.tag(Tag(name: "Work"))))
        XCTAssertNotEqual(sut.state(), initialVal)
        try sut.destroy()
        XCTAssertNoDifference(sut.state(), initialVal)
    }
    
    func testChangesSuscription() async throws {
        var test = "This string should be changed to banana"
        sut.onChange {
            test = "banana"
        }
        
        try await sut.change(.create(.task(Task())))
        XCTAssertTrue(test == "banana")
    }

    // MARK: - Create
    func testCreateTask() async throws {
        let task = Task()
        try await sut.change(.create(.task(task)))
        XCTAssertTrue(sut.state().tasks.count == 1)
        XCTAssertTrue(sut.state().tasks.first?.id == task.id)
    }

    func testCreateArea() async throws {
        let area = Area()
        try await sut.change(.create(.area(area)))
        XCTAssertTrue(sut.state().areas.first?.id == area.id)
    }

    func testCreateTag() async throws {
        let tag = Tag(name: "Test tag")
        try await sut.change(.create(.tag(tag)))
        XCTAssertEqual(sut.state().tags.first?.id, tag.id)
        XCTAssertEqual(sut.state().tags.first?.name, "Test tag")
    }
    
    func testCreateCheckItem() async throws {
        let task = Task()
        let item = Item(task: task.id)
        try await sut.change(.create(.task(task)))
        try await sut.change(.create(.item(item)))
        XCTAssertFalse(sut.state().items.isEmpty)
    }
    
    
    /// If we try to create an item with an associated task that doesn't exists,
    /// item shouldn't be persisted
    func testCreateItemWithInexistentTask() async throws {
        let item = Item(task: UUID())
       
        try await sut.change(.create(.item(item)))
        XCTAssertTrue(sut.state().items.isEmpty)
    
    }

    // MARK: - Delete
    func testDeleteTask() async throws {
        let task = Task()
        try await sut.change(.create(.task(task)))
        XCTAssertEqual(sut.state().tasks.count, 1)
        try await sut.change(.delete(.task(task)))
        XCTAssertTrue(sut.state().tasks.isEmpty)
    }

    func testDeleteArea() async throws {
        let area = Area()
        try await sut.change(.create(.area(area)))
        try await sut.change(.delete(.area(area)))
        XCTAssertTrue(sut.state().areas.isEmpty)
    }

    func testDeleteTag() async throws {
        let tag = Tag(name: "Testing")
        try await sut.change(.create(.tag(tag)))
        try await sut.change(.delete(.tag(tag.id)))
        
        XCTAssertTrue(sut.state().tags.isEmpty)
    }
    
    func testTagDeletionRemoveRelationships() async throws {
        let tag = Tag(name: "New tag")
        let task = Task().alter(.add(.tag(tag.id)))
        let area = Area().alter(.addTag(tag.id))
        try await sut.change(.create(.tag(tag)))
        try await sut.change(.create(.task(task)))
        try await sut.change(.create(.area(area)))
        try await sut.change(.delete(.tag(tag.id)))
        
        XCTAssertTrue(sut.state().tasks.first!.tags.isEmpty)
        XCTAssertTrue(sut.state().areas.first!.tags.isEmpty)
    }
    
    
    func testDeleteItem() async throws {
        let task = Task()
        let item = Item(task: task.id)
        try await sut.change(.create(.task(task)))
        try await sut.change(.create(.item(item)))
        try await sut.change(.delete(.item(item)))
        XCTAssertTrue(sut.state().items.isEmpty)
        XCTAssertTrue(sut.state().tasks.first!.checkList.isEmpty)
    }

    // MARK: - Update
    func testTaskDSL() async throws {
        let originalTask = Task()
        let checkItem = Item(task: originalTask.id)
        let tag = Tag(name: "Test")

        let changes: [Task.Change] = [
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
            .add(.checkItem(checkItem.id)), 
            .add(.tag(tag.id)),
            .remove(.checkItem(checkItem.id)),
            .remove(.tag(tag.id))
            //            .recurrency(.annual(startDate: Date())),
        ]

        try await sut.change(.create(.task(originalTask)))

        try await changes.asyncForEach { change in
            XCTAssertTrue(sut.state().tasks.count == 1)
            let unmodified = sut.state().tasks.first!

            try await sut.change(.update(.task(unmodified, with: change)))

            let expected = unmodified.alter(change)
            let modified = sut.state().tasks.first!

            XCTAssertNoDifference(modified, expected)
        }
    }

    func testAreaDSL() async throws {

        let tag = Tag(name: "Work")

        let changes: [Area.Change] = [
            .title("My new area"),
            .makeVisible,
            .makeInvisible,
            .addTag(tag.id),
            .removeTag(tag.id)
        ]

        let originalArea = Area()
        try await sut.change(.create(.area(originalArea)))

        try await changes.asyncForEach { change in

            XCTAssertTrue(sut.state().areas.count == 1)
            let unmodified = sut.state().areas.first!

            try await sut.change(.update(.area(unmodified, with: change)))

            let expected = unmodified.alter(change)
            let modified = sut.state().areas.first!

            XCTAssertNoDifference(modified, expected)
        }
    }

    func testTagDSL() async throws {
        let tag = Tag(name: "Original tag")
        let changes: [Tag.Change] = [
            .name("Work"),
            .parent(UUID()),
            .removeParent,
            .index(5)
        ]

        try await sut.change(.create(.tag(tag)))

        try await changes.asyncForEach { change in

            XCTAssertTrue(sut.state().tags.count == 1)

            let unmodified = sut.state().tags.first!
            try await sut.change(.update(.tag(unmodified, with: change)))

            let expected = unmodified.alter(change)
            let modified = sut.state().tags.first!

            XCTAssertNoDifference(modified, expected)
        }
    }
   
    
    func testItemDSL() async throws {
        
        let task = Task().alter(.title("Task with checkItem"))
        let item = Item(task: task.id).alter(.title("CheckItem"))
        
        try await sut.change(.create(.task(task)))
        try await sut.change(.create(.item(item)))
        
        let commands: [Item.Change] = [
            .title("My check item descriptive title"),
            .check,
            .uncheck,
            .index(20)
        ]
        
        try await commands.asyncForEach { cmd in
         
            let unmodified = sut.state().items.first!
            
            try await sut.change(.update(.item(unmodified, with: cmd)))
            XCTAssertEqual(sut.state().tasks.first!.id, task.id)
            let expected = unmodified.alter(cmd)
            let modified = sut.state().items.first!
            XCTAssertNoDifference(modified, expected)
        }
        
    }

    /// When converting a task that has associated checklist
    /// - CheckList set should be emptied
    /// - CheckList items should become tasks with an associated project
    func testConverTaskWithCheckItemsToProject() async throws {
       
        let task = Task().alter(
            .project(UUID()),
            .actionGroup(UUID()),
            .index(4)
        )

        let c1 = Item(task: task.id)
        let c2 = Item(task: task.id)
        let c3 = Item(task: task.id)

        try await sut.change(.create(.task(task)))
        try await sut.change(.create(.item(c1)))
        try await sut.change(.create(.item(c2)))
        try await sut.change(.create(.item(c3)))

        XCTAssertFalse(sut.state().tasks.first!.checkList.isEmpty)
        XCTAssertEqual(sut.state().tasks.first?.checkList.count, 3)

        let injectedTask = sut.state().tasks.first!

        try await sut.change(
            .update(.task(injectedTask, with: .type(.project)))
        )

        XCTAssertEqual(sut.state().tasks.first?.checkList.count, 0)
        XCTAssertEqual(sut.state().items.count, 0)
        XCTAssertEqual(sut.state().tasks.count, 4)


        let tasks = sut.state().tasks.filter {$0.type != .project}
        XCTAssertEqual(tasks.count, 3)

        tasks.forEach {
            XCTAssertTrue($0.project == task.id)
        }
    }
    
    /// Wheh converting a heading to project:
    /// Heading items 'actionGroup' becomes nil
    /// Heading tiems 'proejct' is assigned with the heading id
    func testConvertHeadingWithSubtasksToProject() async throws {
        let heading = Task().alter(.type(.heading))
        let createCMD = Array(1...4)
            .map { _ in Task().alter(.actionGroup(heading.id)) }
            .map { AppState.Change.create(.task($0)) }

        try await sut.change(.create(.task(heading)))
        try await createCMD.asyncForEach {
                try await sut.change($0)
            }

        XCTAssertTrue(sut.state().tasks.count == 5)
        XCTAssertTrue(sut.state().tasks.filter {$0.type == .project}.isEmpty)

        try await sut.change(
            .update(
                .task(heading, with: .type(.project)
            ))
        )
        
        let modifiedHeading = sut.state().tasks.filter { $0.type == .project }.first

        XCTAssertNotNil(modifiedHeading)
        let subTasks = sut.state().tasks.filter { $0.type != .project }
        XCTAssertTrue(subTasks.count == 4)
        subTasks.forEach {
            XCTAssertNil($0.actionGroup)
        }
    }
}

