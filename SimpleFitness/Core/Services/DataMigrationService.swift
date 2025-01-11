import Foundation
import CoreData

class DataMigrationService {
    static let shared = DataMigrationService()
    
    private let viewContext: NSManagedObjectContext
    private let templateService: ExerciseTemplateService
    
    private init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext,
                templateService: ExerciseTemplateService = .shared) {
        self.viewContext = context
        self.templateService = templateService
    }
    
    func migrateExistingExercises() {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        
        do {
            let exercises = try viewContext.fetch(request)
            
            for exercise in exercises {
                // Skip if already has sets
                if let sets = exercise.sets as? Set<ExerciseSet>, !sets.isEmpty {
                    continue
                }
                
                // Create or find template
                if let name = exercise.name {
                    let template = templateService.findTemplate(named: name) ?? templateService.createTemplate(name: name)
                    exercise.template = template
                }
                
                // Create set from existing data
                let set = ExerciseSet(context: viewContext)
                set.id = UUID()
                set.exercise = exercise
                set.order = 0
                
                try viewContext.save()
            }
        } catch {
            print("Error migrating exercises: \(error)")
        }
    }
} 