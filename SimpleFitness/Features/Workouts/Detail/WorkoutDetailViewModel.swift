import Foundation
import CoreData
import Combine

class WorkoutDetailViewModel: ObservableObject {
    @Published var workout: Workout
    @Published var exercises: [Exercise] = []
    @Published var isEditing = false
    
    private let viewContext: NSManagedObjectContext
    
    init(workout: Workout, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.workout = workout
        self.viewContext = context
        loadExercises()
    }
    
    private func loadExercises() {
        if let exercises = workout.exercises as? Set<Exercise> {
            self.exercises = Array(exercises).sorted { $0.name < $1.name }
        }
    }
    
    func updateExercise(_ exercise: Exercise, name: String, sets: Int, reps: Int, weight: Double) {
        exercise.name = name
        exercise.sets = Int16(sets)
        exercise.reps = Int16(reps)
        exercise.weight = weight
        
        saveChanges()
        loadExercises() // Reload to reflect any sorting changes
    }
    
    func formattedDate() -> String {
        guard let date = workout.date else { return "Unknown Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func workoutDuration() -> String {
        let duration = workout.duration
        let hours = Int(duration) / 3600
        let minutes = Int(duration.truncatingRemainder(dividingBy: 3600)) / 60
        return "\(hours)h \(minutes)m"
    }
    
    func workoutDistance() -> String {
        return String(format: "%.2f miles", workout.distance)
    }
    
    func saveChanges() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving workout changes: \(error)")
        }
    }
} 