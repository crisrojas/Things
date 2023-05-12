//
//  StateStore.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 09/03/2023.
//

import Foundation

// MARK: - StateStore
public typealias Access   = (               ) -> AppState
public typealias Change   = (AppState.Change) async throws -> ()
public typealias Updated  = (@escaping()->()) -> ()
public typealias Destroy  = (               ) throws -> ()

public typealias StateStore = (
    state   : Access,
    change  : Change,
    onChange: Updated,
    destroy : Destroy
)

