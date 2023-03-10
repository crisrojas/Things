//
//  Set.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//

import Foundation

extension Set {
    
    func droppingLast() -> Self { Set(self.dropLast()) }
    
    func add(_ item: Element) -> Self {
        var new = self
        new.insert(item)
        return new
    }
    
    func delete(_ item: Element) -> Self {
        var new = self
        new.remove(item)
        return new
    }
}
