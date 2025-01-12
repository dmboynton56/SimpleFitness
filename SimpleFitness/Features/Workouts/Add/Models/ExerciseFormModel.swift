import Foundation
import CoreData

struct ExerciseFormModel: Identifiable {
    let id: UUID
    var name: String
    var sets: Int
    var reps: Int
    var weight: Double
    
    init(id: UUID = UUID(), name: String, sets: Int = 1, reps: Int = 0, weight: Double = 0.0) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
    }
    
    // Convert from CoreData Exercise entity
    init(from entity: Exercise) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        if let sets = entity.sets as? Set<ExerciseSet> {
            self.sets = sets.count
            if let firstSet = sets.first {
                self.reps = Int(firstSet.reps)
                self.weight = firstSet.weight
            } else {
                self.reps = 0
                self.weight = 0.0
            }
        } else {
            self.sets = 0
            self.reps = 0
            self.weight = 0.0
        }
    }
    
    func toExercise(context: NSManagedObjectContext) -> Exercise {
        let exercise = Exercise(context: context)
        exercise.id = id
        exercise.name = name
        
        // Create all sets
        for i in 0..<sets {
            let set = ExerciseSet(context: context)
            set.id = UUID()
            set.reps = Int16(reps)
            set.weight = weight
            set.order = Int16(i)
            set.exercise = exercise
        }
        
        return exercise
    }
} 