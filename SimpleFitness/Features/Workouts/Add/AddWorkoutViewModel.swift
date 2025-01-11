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
    @Published var exercises: [ExerciseFormModel] = []
    
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
        let exercise = ExerciseFormModel(
            name: template.name ?? "",
            sets: 1,
            reps: 10,
            weight: 0.0
        )
        exercises.append(exercise)
        templateService.updateLastUsed(template)
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
        exercises.forEach { exerciseForm in
            let exercise = exerciseForm.toExercise(context: viewContext)
            exercise.workout = workout
            
            // Find and link template
            if let template = templateService.findTemplate(named: exercise.name) {
                exercise.template = template
                templateService.updateLastUsed(template)
            }
        }
    }
    
    private func saveCardioWorkout(_ workout: Workout) {
        let totalSeconds = (hours * 3600) + (minutes * 60) + seconds
        workout.duration = Double(totalSeconds)
        
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
