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
    
    func updateWorkoutNotes(_ notes: String) {
        workout.notes = notes.isEmpty ? nil : notes
        saveChanges()
    }
    
    func updateExercise(_ exercise: Exercise, name: String, sets: [(reps: Int16, weight: Double)]) {
        exercise.name = name
        
        // Update existing sets or create new ones
        let existingSets = exercise.sets as? Set<ExerciseSet> ?? Set()
        
        // Delete any extra sets
        if existingSets.count > sets.count {
            let orderedSets = existingSets.sorted { $0.order < $1.order }
            for set in orderedSets[sets.count...] {
                viewContext.delete(set)
            }
        }
        
        // Update or create sets
        for (index, setData) in sets.enumerated() {
            let orderedSets = existingSets.sorted { $0.order < $1.order }
            let set: ExerciseSet
            
            if index < orderedSets.count {
                // Update existing set
                set = orderedSets[index]
            } else {
                // Create new set
                set = ExerciseSet(context: viewContext)
                set.id = UUID()
                set.exercise = exercise
            }
            
            set.order = Int16(index)
            set.reps = setData.reps
            set.weight = setData.weight
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
    
    private func saveChanges() {
        do {
            try viewContext.save()
            loadExercises()  // Reload exercises after saving
        } catch {
            print("Error saving workout changes: \(error)")
        }
    }
    
    func addExerciseFromTemplate(_ template: ExerciseTemplate) {
        let exercise = Exercise(context: viewContext)
        exercise.id = UUID()
        exercise.name = template.name
        exercise.workout = workout
        
        // Create default set
        let set = ExerciseSet(context: viewContext)
        set.id = UUID()
        set.order = 0
        set.reps = 0
        set.weight = 0
        set.exercise = exercise
        
        saveChanges()
    }
    
    func removeExercise(_ exercise: Exercise) {
        viewContext.delete(exercise)
        saveChanges()
    }
    
    func addSetToExercise(_ exercise: Exercise) {
        print("ViewModel: Adding set to exercise \(exercise.name ?? "")")
        guard let existingSets = exercise.sets as? Set<ExerciseSet> else {
            print("ViewModel: Failed to get existing sets")
            return
        }
        
        let set = ExerciseSet(context: viewContext)
        set.id = UUID()
        set.order = Int16(existingSets.count)
        set.reps = 0
        set.weight = 0
        set.exercise = exercise
        
        saveChanges()
        print("ViewModel: Successfully added set")
    }
    
    func removeSetFromExercise(_ exercise: Exercise, at index: Int) {
        print("ViewModel: Removing set \(index) from exercise \(exercise.name ?? "")")
        guard let sets = exercise.sets as? Set<ExerciseSet> else {
            print("ViewModel: Failed to get existing sets")
            return
        }
        let orderedSets = sets.sorted { $0.order < $1.order }
        
        guard index < orderedSets.count else {
            print("ViewModel: Invalid set index")
            return
        }
        
        // Delete the set
        viewContext.delete(orderedSets[index])
        
        // Reorder remaining sets
        for i in (index + 1)..<orderedSets.count {
            orderedSets[i].order = Int16(i - 1)
        }
        
        saveChanges()
        print("ViewModel: Successfully removed set")
    }
} 