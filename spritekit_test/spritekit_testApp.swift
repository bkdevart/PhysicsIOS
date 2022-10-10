//
//  spritekit_testApp.swift
//  spritekit_test
//
//  Created by Brandon Knox on 10/10/22.
//

import SwiftUI

@main
struct spritekit_testApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
