//
//  ThingsApp.swift
//  Things
//
//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.
//

import SwiftUI

@main
struct ThingsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
