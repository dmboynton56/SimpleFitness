//
//  Persistence.swift
//  SimpleFitness
//
//  Created by Drew Boynton on 1/10/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Generate sample data
        SampleData.generateSampleData(in: viewContext)
        
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SimpleFitnessModel")
        
        // Configure the persistent store description
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Reduce debug logging
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        container.persistentStoreDescriptions.first?.setOption(FileProtectionType.complete as NSObject, forKey: NSPersistentStoreFileProtectionKey)
        
        // Reduce SQLite debug messages
        let description = container.persistentStoreDescriptions.first
        description?.setOption(false as NSNumber, forKey: "com.apple.SQLite.DebugModeKey")
        description?.setOption(false as NSNumber, forKey: "com.apple.CoreData.SQLDebug")
        description?.setOption(false as NSNumber, forKey: "com.apple.CoreData.Logging.stderr")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
