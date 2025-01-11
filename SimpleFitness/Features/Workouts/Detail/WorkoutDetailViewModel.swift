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
            self.exercises = Array(exercises).sorted { 
                let name1 = $0.name ?? ""
                let name2 = $1.name ?? ""
                return name1 < name2
            }
        }
    }
    
    func updateWorkoutName(_ name: String) {
        workout.name = name.isEmpty ? nil : name
        saveChanges()
    }
    
    func updateExercise(_ exercise: Exercise, name: String, reps: Int16, weight: Double) {
        exercise.name = name
        
        // Update the first set or create one if it doesn't exist
        if let sets = exercise.sets as? Set<ExerciseSet>, let firstSet = sets.first {
            firstSet.reps = reps
            firstSet.weight = weight
        } else {
            let set = ExerciseSet(context: viewContext)
            set.id = UUID()
            set.exercise = exercise
            set.order = 0
            set.reps = reps
            set.weight = weight
        }
        
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