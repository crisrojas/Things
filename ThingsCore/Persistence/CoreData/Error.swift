//
//  Error.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 13/03/2023.
//

import Foundation

public enum CoreDataError: Error, Equatable {
    case invalidMapping
    case entityNotFound
    case unknownError(String)
}
