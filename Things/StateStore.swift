//
//  StateStore.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 09/03/2023.
//

import Foundation

// MARK: - StateStore
typealias Access   = (               ) -> AppState
typealias Change   = (AppState.Change) async throws -> ()
typealias Updated  = (@escaping()->()) -> ()
typealias Reset    = (               ) -> ()
typealias Destroy  = (               ) -> ()

typealias StateStore = (
    state   : Access,
    change  : Change,
    callback: Updated,
    reset   : Reset,
    destroy : Destroy
)
