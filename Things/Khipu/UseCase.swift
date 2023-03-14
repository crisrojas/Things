//
//  UseCase.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 09/03/2023.
//

import Foundation

// MARK: UseCase
protocol UseCase {
    associatedtype RequestType
    associatedtype ResponseType
    
    func request(_ request: RequestType)
}
