//
//  RamStore.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 13/03/2023.
//

import Foundation

// MARK: - Ram Store
func createRamStore() -> StateStore {
    var state = AppState() {didSet{c.call()}}
    var c = [()->()]()
    
    return (
        state   : { state                   },
        change  : { state = state.alter($0) },
        callback: { c = c + [$0]            },
        reset   : { state = AppState()      },
        destroy : { state = AppState()      }
    )
}
