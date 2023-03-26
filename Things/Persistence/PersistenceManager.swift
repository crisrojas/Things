//
//  PersistenceManager.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 16/03/2023.
//

import Foundation

protocol PersistenceManager {
    // MARK: - C
    func create(_ task: Task) async throws
    func create(_ area: Area) async throws
    func create(_ item: Item) async throws
    func create(_ tag: Tag) async throws
    // MARK: - R
    func readTasks() async throws -> [Task]
    func readAreas() async throws -> [Area]
    func readTags() async throws -> [Tag]
    func readCheckItems() async throws -> [Item]
    // MARK: - U
    func update(_ task: Task, _ cmd: Task.Change) async throws
    func update(_ area: Area, _ cmd: Area.Change) async throws
    func update(_ tag: Tag, _ cmd: Tag.Change) async throws
    func update(_ item: Item, _ cmd: Item.Change) async throws
    // MARK: - D
    func delete(task: UUID) async throws
    func delete(area: UUID) async throws
    func delete(checkItem: UUID) async throws
    func delete(tag: UUID) async throws
    func destroy()
}
