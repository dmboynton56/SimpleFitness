import SwiftUI
import CoreData

struct SetList: View {
    @ObservedObject var exercise: Exercise
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(exercise.name ?? "")
                .font(.headline)
                .padding(.horizontal, 8)
            
            VStack(spacing: 12) {
                ForEach(orderedSets) { set in
                    SetRow(set: set) { updatedSet in
                        updateSet(updatedSet)
                    } onDelete: {
                        deleteSet(set)
                    }
                    Divider()
                }
            }
            
            Button(action: addSet) {
                Label("Add Set", systemImage: "plus.circle")
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 12)
    }
    
    private var orderedSets: [ExerciseSet] {
        // Sort by order ascending so newer sets appear at the bottom
        exercise.setsArray.sorted { $0.order < $1.order }
    }
    
    private func addSet() {
        let set = ExerciseSet(context: viewContext)
        set.id = UUID()
        set.exercise = exercise
        
        // Copy values from last set if it exists
        if let lastSet = orderedSets.last {
            set.reps = lastSet.reps
            set.weight = lastSet.weight
        } else {
            set.reps = 0
            set.weight = 0.0
        }
        
        // Add to end of list
        set.order = Int16(orderedSets.count)
        
        saveContext()
    }
    
    private func updateSet(_ set: ExerciseSet) {
        // Ensure changes are saved immediately
        saveContext()
    }
    
    private func deleteSet(_ set: ExerciseSet) {
        viewContext.delete(set)
        saveContext()
        
        // Update order of remaining sets
        let remainingSets = orderedSets
        for (index, set) in remainingSets.enumerated() {
            set.order = Int16(index)
        }
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

extension Exercise {
    var setsArray: [ExerciseSet] {
        let set = sets as? Set<ExerciseSet> ?? []
        return Array(set)
    }
} 