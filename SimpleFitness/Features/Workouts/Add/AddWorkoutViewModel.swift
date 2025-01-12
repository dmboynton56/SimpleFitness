import Foundation
import CoreData
import Combine
import CoreLocation

class AddWorkoutViewModel: ObservableObject {
    // Shared properties
    @Published var workoutType: WorkoutType?
    @Published var workoutName: String = ""
    @Published var notes: String = ""
    
    // Strength workout properties
    @Published private(set) var exercises: [Exercise] = []
    
    // Cardio workout properties
    @Published var isActiveWorkout = false
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var distance: String = ""
    @Published var activeDistance: Double?
    
    let viewContext: NSManagedObjectContext
    private let locationManager: LocationManager
    private let templateService: ExerciseTemplateService
    private var locationSubscription: AnyCancellable?
    private var startLocation: CLLocation?
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext,
         locationManager: LocationManager = LocationManager.shared,
         templateService: ExerciseTemplateService = ExerciseTemplateService.shared) {
        self.viewContext = context
        self.locationManager = locationManager
        self.templateService = templateService
    }
    
    func addExerciseFromTemplate(_ template: ExerciseTemplate) {
        let exercise = Exercise(context: viewContext)
        exercise.id = UUID()
        exercise.name = template.name
        exercise.template = template
        
        // Create default sets
        for i in 0..<3 {  // Default to 3 sets
            let set = ExerciseSet(context: viewContext)
            set.id = UUID()
            set.reps = 10  // Default to 10 reps
            set.weight = 0.0
            set.order = Int16(i)
            set.exercise = exercise
        }
        
        exercises.append(exercise)
        templateService.updateLastUsed(template)
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving exercise: \(error)")
        }
    }
    
    func removeExercises(at offsets: IndexSet) {
        for index in offsets {
            let exercise = exercises[index]
            viewContext.delete(exercise)
        }
        exercises.remove(atOffsets: offsets)
        
        do {
            try viewContext.save()
        } catch {
            print("Error removing exercises: \(error)")
        }
    }
    
    // MARK: - Saving Methods
    
    func saveWorkout() {
        let workout = Workout(context: viewContext)
        workout.id = UUID()
        workout.date = Date()
        workout.type = workoutType?.rawValue
        workout.name = workoutName.isEmpty ? nil : workoutName
        workout.notes = notes.isEmpty ? nil : notes
        
        switch workoutType {
        case .strength:
            saveStrengthWorkout(workout)
        case .running, .biking:
            saveCardioWorkout(workout)
        case .none:
            break
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving workout: \(error)")
        }
    }
    
    private func saveStrengthWorkout(_ workout: Workout) {
        // Link existing exercises to workout
        for exercise in exercises {
            exercise.workout = workout
        }
    }
    
    private func saveCardioWorkout(_ workout: Workout) {
        let totalSeconds = (hours * 3600) + (minutes * 60) + seconds
        workout.duration = Double(totalSeconds)
        
        if let distance = Double(distance) {
            workout.distance = distance
        }
    }
    
    // MARK: - Location Tracking
    
    func startLocationTracking() {
        locationManager.startTracking()
        startLocation = nil
        locationSubscription = locationManager.$location
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.updateDistance(with: location)
            }
    }
    
    func stopLocationTracking() {
        locationManager.stopTracking()
        locationSubscription?.cancel()
        locationSubscription = nil
        startLocation = nil
    }
    
    private func updateDistance(with newLocation: CLLocation) {
        if startLocation == nil {
            startLocation = newLocation
        }
        
        if let start = startLocation {
            // Convert meters to miles
            let distanceInMeters = newLocation.distance(from: start)
            let distanceInMiles = distanceInMeters / 1609.34
            activeDistance = distanceInMiles
        }
    }
}

enum WorkoutType: String, CaseIterable {
    case strength = "Strength"
    case running = "Running"
    case biking = "Biking"
} 
