//
//  Array+remove.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 26/03/2023.
//

import Foundation

extension Array where Element: Identifiable {
    func remove(_ e: Element) -> Self {filter {$0.id == e.id}}
}
