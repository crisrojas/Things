//
//  RamStore.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 13/03/2023.
//

import Foundation

// MARK: - Ram Store
public func createRamStore() -> StateStore {
    var state = AppState() {didSet{c.call()}}
    var c = [()->()]()
    
    return (
        state   : { state                   },
        change  : { state = state.alter($0) },
        onChange: { c = c + [$0]            },
        destroy : { state = AppState()      }
    )
}
