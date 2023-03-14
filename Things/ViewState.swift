//
//  ViewState.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 09/03/2023.
//

import Foundation

// MARK: - ViewState
final class ViewState: ObservableObject {
    
    @Published private var inbox      = [Task]()
    @Published private var today      = [Task]()
    @Published private var done       = [Task]()
    @Published private var later      = [Task]()
    @Published private var trashed    = [Task]()
    @Published private var projects   = [Task]()
    @Published private var laterProj  = [Task]()
    
    
    init(store: StateStore) {
        store.callback { [weak self] in
            self?.process(store.state())
        }
        
        process(store.state())
    }
    
    func process(_ state: AppState) {}
}
