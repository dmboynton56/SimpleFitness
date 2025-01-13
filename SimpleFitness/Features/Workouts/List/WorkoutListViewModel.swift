import Foundation
import CoreData
import SwiftUI

class WorkoutListViewModel: NSObject, ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var showingAddWorkout = false
    
    private let viewContext: NSManagedObjectContext
    private var workoutsController: NSFetchedResultsController<Workout>?
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        super.init()
        setupFetchedResultsController()
        fetchWorkouts()
    }
    
    func generateSampleData() {
        // First clear existing data
        SampleData.clearAllData(in: viewContext)
        
        // Then generate new sample data
        SampleData.generateSampleData(in: viewContext)
        
        // Refresh the workouts list
        fetchWorkouts()
    }
    
    private func setupFetchedResultsController() {
        let request = NSFetchRequest<Workout>(entityName: "Workout")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: false)]
        
        workoutsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        workoutsController?.delegate = self
    }
    
    func fetchWorkouts() {
        do {
            try workoutsController?.performFetch()
            workouts = workoutsController?.fetchedObjects ?? []
        } catch {
            print("Error fetching workouts: \(error)")
        }
    }
    
    func deleteWorkouts(at offsets: IndexSet) {
        for index in offsets {
            let workout = workouts[index]
            viewContext.delete(workout)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error deleting workout: \(error)")
        }
    }
    
    // Helper function to format workout details
    func workoutDetails(_ workout: Workout) -> String {
        switch workout.type {
        case "Strength":
            let exerciseCount = (workout.exercises as? Set<Exercise>)?.count ?? 0
            return "\(exerciseCount) exercise\(exerciseCount == 1 ? "" : "s")"
        case "Running", "Biking":
            let duration = workout.duration
            let distance = workout.distance
            let hours = Int(duration) / 3600
            let minutes = Int(duration.truncatingRemainder(dividingBy: 3600)) / 60
            let distanceStr = String(format: "%.1f miles", distance)
            return "\(hours)h \(minutes)m • \(distanceStr)"
        default:
            return ""
        }
    }
    
    func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

extension WorkoutListViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        fetchWorkouts()
    }
} 
