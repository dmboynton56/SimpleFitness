//
//  Persistence.swift
//  SimpleFitness
//
//  Created by Drew Boynton on 1/10/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newWorkout = Workout(context: viewContext)
            newWorkout.date = Date()
            newWorkout.distance = 0.0
            newWorkout.duration = 0.0
            newWorkout.type = "Default"
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SimpleFitnessModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Run data migration if needed
        if !inMemory {
            Task {
                await PersistenceController.performDataMigrationIfNeeded()
            }
        }
    }
    
    @MainActor
    private static func performDataMigrationIfNeeded() {
        DataMigrationService.shared.migrateExistingExercises()
    }
}
