import Foundation
import CoreData
import SwiftUI

class WorkoutListViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var showingAddWorkout = false
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        fetchWorkouts()
    }
    
    func fetchWorkouts() {
        let request = NSFetchRequest<Workout>(entityName: "Workout")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: false)]
        
        do {
            workouts = try viewContext.fetch(request)
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
            fetchWorkouts()
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
