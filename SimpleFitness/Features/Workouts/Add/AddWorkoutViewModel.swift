import Foundation
import CoreData
import Combine
import CoreLocation

class AddWorkoutViewModel: ObservableObject {
    // Shared properties
    @Published var workoutType: WorkoutType?
    @Published var notes: String = ""
    
    // Strength workout properties
    @Published var exercises: [ExerciseFormModel] = []
    
    // Cardio workout properties
    @Published var isActiveWorkout = false
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var distance: String = ""
    @Published var activeDistance: Double?
    
    private let viewContext: NSManagedObjectContext
    private let locationManager: LocationManager
    private var locationSubscription: AnyCancellable?
    private var startLocation: CLLocation?
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext,
         locationManager: LocationManager = LocationManager.shared) {
        self.viewContext = context
        self.locationManager = locationManager
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
    
    // MARK: - Strength Workout Methods
    
    func addExercise(_ exercise: ExerciseFormModel) {
        exercises.append(exercise)
    }
    
    func updateExercise(_ exercise: ExerciseFormModel) {
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[index] = exercise
        }
    }
    
    func removeExercises(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
    }
    
    // MARK: - Saving Methods
    
    func saveWorkout() {
        let workout = Workout(context: viewContext)
        workout.id = UUID()
        workout.date = Date()
        workout.type = workoutType?.rawValue
        
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
        // Create Exercise entities and associate them with the workout
        exercises.forEach { exerciseForm in
            let exerciseEntity = Exercise(context: viewContext)
            exerciseEntity.id = exerciseForm.id
            exerciseEntity.name = exerciseForm.name
            exerciseEntity.sets = Int16(exerciseForm.sets)
            exerciseEntity.reps = Int16(exerciseForm.reps)
            exerciseEntity.weight = exerciseForm.weight
            exerciseEntity.workout = workout
        }
    }
    
    private func saveCardioWorkout(_ workout: Workout) {
        // Convert duration to seconds
        let totalSeconds = (hours * 3600) + (minutes * 60) + seconds
        workout.duration = Double(totalSeconds)
        
        // Convert distance string to double
        if let distance = Double(distance) {
            workout.distance = distance
        }
    }
}

enum WorkoutType: String, CaseIterable {
    case strength = "Strength"
    case running = "Running"
    case biking = "Biking"
} 
