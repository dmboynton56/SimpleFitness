import Foundation
import CoreData

class WorkoutDetailViewModel: ObservableObject {
    private let workout: Workout
    private let context: NSManagedObjectContext
    private let progressService: ProgressCalculationService
    
    @Published var exercises: [Exercise] = []
    
    // Public read-only access to workout properties
    var workoutName: String { workout.name ?? "" }
    var workoutDate: Date? { workout.date }
    
    init(workout: Workout) {
        self.workout = workout
        self.context = workout.managedObjectContext!
        self.progressService = ProgressCalculationService(viewContext: context)
        loadExercises()
    }
    
    private func loadExercises() {
        guard let exerciseSet = workout.exercises as? Set<Exercise> else { return }
        exercises = exerciseSet.sorted { ($0.template?.name ?? "") < ($1.template?.name ?? "") }
    }
    
    func updateWorkoutName(_ name: String) {
        workout.name = name
        saveContext()
    }
    
    func addExercise(_ exercise: Exercise) {
        exercises.append(exercise)
        workout.addToExercises(exercise)
        progressService.updateStrengthProgress(for: exercise)
        saveContext()
    }
    
    func deleteExercise(_ exercise: Exercise) {
        if let index = exercises.firstIndex(of: exercise) {
            exercises.remove(at: index)
            workout.removeFromExercises(exercise)
            context.delete(exercise)
            saveContext()
        }
    }
    
    // Method to safely access workout for exercise form
    func prepareExerciseForm(exercise: Exercise?) -> (workout: Workout, exercise: Exercise?) {
        return (workout, exercise)
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
} 