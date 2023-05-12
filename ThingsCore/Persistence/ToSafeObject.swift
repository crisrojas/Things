//
//  ToSafeObject.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 13/03/2023.
//

protocol ToSafeObject {
    associatedtype SafeType
    func safeObject() throws -> SafeType
}
