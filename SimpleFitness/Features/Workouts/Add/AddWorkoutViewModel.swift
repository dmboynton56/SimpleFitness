import Foundation
import CoreData
import Combine

class AddWorkoutViewModel: ObservableObject {
    // Shared properties
    @Published var workoutType: WorkoutType?
    @Published var workoutName: String = ""
    @Published var notes: String = ""
    
    // Strength workout properties
    @Published private(set) var exercises: [Exercise] = []
    
    let viewContext: NSManagedObjectContext
    private let templateService: ExerciseTemplateService
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext,
         templateService: ExerciseTemplateService = ExerciseTemplateService.shared) {
        self.viewContext = context
        self.templateService = templateService
    }
    
    func saveWorkout() {
        guard let type = workoutType else { return }
        
        let workout = Workout(context: viewContext)
        workout.id = UUID()
        workout.type = type.rawValue
        workout.name = workoutName.isEmpty ? nil : workoutName
        workout.date = Date()
        workout.notes = notes.isEmpty ? nil : notes
        
        // Add exercises to workout
        if type == .strength {
            let exerciseSet = NSSet(array: exercises)
            workout.exercises = exerciseSet
        }
        
        do {
            try viewContext.save()
            // Notify observers after successful save
            objectWillChange.send()
        } catch {
            print("Error saving workout: \(error)")
        }
    }
    
    func workoutSaved(_ workout: Workout) {
        // Notify any observers that a workout was saved
        objectWillChange.send()
    }
    
    // MARK: - Exercise Management
    
    func addExerciseFromTemplate(_ template: ExerciseTemplate) {
        let exercise = Exercise(context: viewContext)
        exercise.id = UUID()
        exercise.name = template.name
        exercise.template = template
        exercises.append(exercise)
        
        // Create initial set
        let set = ExerciseSet(context: viewContext)
        set.id = UUID()
        set.exercise = exercise
        set.order = 0
        
        templateService.updateLastUsed(template)
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving exercise: \(error)")
        }
    }
    
    func removeExercises(at indexSet: IndexSet) {
        for index in indexSet {
            let exercise = exercises[index]
            viewContext.delete(exercise)
        }
        exercises.remove(atOffsets: indexSet)
        
        do {
            try viewContext.save()
        } catch {
            print("Error removing exercises: \(error)")
        }
    }
}

enum WorkoutType: String, CaseIterable {
    case strength = "Strength"
    case running = "Running"
    case biking = "Biking"
} 
