//
//  AppState.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 09/03/2023.
//

import Foundation

// MARK: - App State
struct AppState: Codable {
    let todos     : [Task]
    let areas     : [Area]
    let tags      : [Tag]
    let checkLists: [CheckItem]
}

extension AppState {
    init(
        _ todos     : [Task] = [],
        _ areas     : [Area] = [],
        _ tags      : [Tag]  = [],
        _ checkLists: [CheckItem] = []
    ) {
        self.todos = todos
        self.areas = areas
        self.checkLists = checkLists
        self.tags = tags
    }
}


// MARK: - DSL APi
extension AppState {
    enum Change {}
}

extension AppState {
    func alter(_ change: Change) -> Self {self}
}
