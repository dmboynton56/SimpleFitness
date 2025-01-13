import Foundation
import CoreData

struct SampleData {
    static func generateSampleData(in context: NSManagedObjectContext) {
        // Create exercise templates
        let templates = ExerciseTemplate.createPreviewTemplates(in: context)
        
        // Generate workouts over the past 30 days
        let calendar = Calendar.current
        let today = Date()
        
        for template in templates {
            // Create 6 workouts over the past 30 days
            for i in 0..<6 {
                guard let workoutDate = calendar.date(byAdding: .day, value: -(i * 5), to: today) else { continue }
                
                let workout = Workout(context: context)
                workout.id = UUID()
                workout.date = workoutDate
                workout.type = "Strength"
                
                let exercise = Exercise(context: context)
                exercise.id = UUID()
                exercise.template = template
                exercise.workout = workout
                
                // Generate 3-5 sets with progressive overload
                let setCount = Int.random(in: 3...5)
                let baseWeight = template.name?.contains("Press") == true ? 95.0 : 135.0
                let baseReps = 8
                
                for setIndex in 0..<setCount {
                    let set = ExerciseSet(context: context)
                    set.id = UUID()
                    set.exercise = exercise
                    set.order = Int16(setIndex)
                    
                    // Add some variation and progression
                    let weekProgress = Double(5 - (i * 5)) // More recent workouts have higher weights
                    let setDecrement = Double(setIndex) * 0.5 // Later sets might have slightly lower weights
                    set.weight = baseWeight + weekProgress - setDecrement
                    set.reps = Int16(baseReps - setIndex) // Reps decrease with each set
                }
            }
        }
        
        // Save the context
        do {
            try context.save()
        } catch {
            print("Error saving sample data: \(error)")
        }
    }
    
    static func clearAllData(in context: NSManagedObjectContext) {
        let entities = ["Workout", "Exercise", "ExerciseSet", "ExerciseTemplate", "ProgressMetric"]
        
        for entityName in entities {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Error clearing \(entityName) data: \(error)")
            }
        }
        
        // Save the context
        do {
            try context.save()
        } catch {
            print("Error saving after clearing data: \(error)")
        }
    }
} 