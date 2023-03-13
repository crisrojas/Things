//
//  Error.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 13/03/2023.
//

import Foundation

enum CoreDataError: Error {
    case invalidMapping
    case entityNotFound
    case unknownError(String)
}
