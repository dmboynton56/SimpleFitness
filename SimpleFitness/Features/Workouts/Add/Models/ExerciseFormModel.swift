import Foundation

struct ExerciseFormModel: Identifiable {
    let id: UUID
    var name: String
    var sets: Int
    var reps: Int
    var weight: Double
    
    init(id: UUID = UUID(), name: String, sets: Int, reps: Int, weight: Double) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
    }
    
    // Convert from CoreData Exercise entity
    init(from entity: Exercise) {
        self.id = entity.id
        self.name = entity.name
        self.sets = Int(entity.sets)
        self.reps = Int(entity.reps)
        self.weight = entity.weight
    }
} 