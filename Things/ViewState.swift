//
//  ViewState.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 09/03/2023.
//

import Foundation

// MARK: - ViewState
final class ViewState: ObservableObject {
    
    @Published private var inbox      = [ToDo]()
    @Published private var today      = [ToDo]()
    @Published private var done       = [ToDo]()
    @Published private var later      = [ToDo]()
    @Published private var trashed    = [ToDo]()
    @Published private var projects   = [ToDo]()
    @Published private var laterProj  = [ToDo]()
    
    
    init(store: StateStore) {
        
        store.callback { [weak self] in
            self?.process(store.state())
        }
        
        process(store.state())
    }
    
    func process(_ state: AppState) {}
}
