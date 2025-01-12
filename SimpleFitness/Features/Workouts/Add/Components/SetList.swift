import SwiftUI
import CoreData

struct SetList: View {
    @ObservedObject var exercise: Exercise
    @Environment(\.managedObjectContext) private var viewContext
    
    private var orderedSets: [ExerciseSet] {
        // Sort by order ascending so newer sets appear at the bottom
        exercise.setsArray.sorted { $0.order < $1.order }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(exercise.name ?? "")
                .font(.headline)
                .padding(.horizontal, 16)
            
            VStack(spacing: 12) {
                ForEach(orderedSets) { set in
                    VStack {
                        SetRow(
                            set: set,
                            onUpdate: { reps, weight in
                                updateSet(set, reps: reps, weight: weight)
                            },
                            onDelete: {
                                deleteSet(set)
                            }
                        )
                        .padding(.horizontal, 16)
                        
                        Divider()
                            .padding(.horizontal, 8)
                    }
                }
            }
            
            Button(action: addSet) {
                Label("Add Set", systemImage: "plus.circle")
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
    }
    
    private func addSet() {
        let set = ExerciseSet(context: viewContext)
        set.id = UUID()
        set.order = Int16(orderedSets.count)
        set.reps = 0
        set.weight = 0.0
        set.exercise = exercise
        
        saveChanges()
    }
    
    private func updateSet(_ set: ExerciseSet, reps: Int, weight: Double) {
        set.reps = Int16(reps)
        set.weight = weight
        saveChanges()
    }
    
    private func deleteSet(_ set: ExerciseSet) {
        viewContext.delete(set)
        
        // Reorder remaining sets
        let remainingSets = orderedSets.filter { $0 != set }
        for (index, set) in remainingSets.enumerated() {
            set.order = Int16(index)
        }
        
        saveChanges()
    }
    
    private func saveChanges() {
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