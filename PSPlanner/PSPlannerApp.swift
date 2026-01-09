//
//  PSPlannerApp.swift
//  PSPlanner
//
//  Created by Sean Raymor on 1/9/26.
//

import SwiftUI
import SwiftData

@main
struct PSPlannerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Task.self,
            Category.self,
        ])
        
        // Local storage only (CloudKit requires paid Apple Developer Program)
        // To enable iCloud sync later, change cloudKitDatabase to .automatic
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
