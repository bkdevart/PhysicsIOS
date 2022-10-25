//
//  PhysicsTestApp.swift
//  PhysicsTest
//
//  Created by Brandon Knox on 10/18/22.
//

import SwiftUI

@main
struct PhysicsTestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
