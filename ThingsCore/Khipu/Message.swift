//
//  Messages.swift
//  Message
//
//  Created by Cristian Felipe Patiño Rojas on 09/03/2023.
//

import Foundation

// MARK: - Message

typealias   Input = (Message) -> ()
typealias  Output = (Message) -> ()
typealias AppCore = (Message) -> ()

enum Message {
    case create(AppState.Change.Create)
    case update(AppState.Change.Update)
    case delete(AppState.Change.Delete)
}
