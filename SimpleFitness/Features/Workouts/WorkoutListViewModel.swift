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
} 