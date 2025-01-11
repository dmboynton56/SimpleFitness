//
//  SimpleFitnessApp.swift
//  SimpleFitness
//
//  Created by Drew Boynton on 1/10/25.
//

import SwiftUI
import CoreData

@main
struct SimpleFitnessApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var locationManager = LocationManager.shared

    var body: some Scene {
        WindowGroup {
            WorkoutListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(locationManager)
        }
    }
}
