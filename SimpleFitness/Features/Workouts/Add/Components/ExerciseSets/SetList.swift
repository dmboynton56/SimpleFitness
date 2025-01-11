import SwiftUI

struct SetList: View {
    let exercise: Exercise
    @StateObject private var viewModel: SetListViewModel
    
    init(exercise: Exercise) {
        self.exercise = exercise
        _viewModel = StateObject(wrappedValue: SetListViewModel(exercise: exercise))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exercise.name)
                .font(.headline)
            
            ForEach(viewModel.setGroups.keys.sorted(), id: \.self) { weight in
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(String(format: "%.1f", weight)) lbs")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ForEach(viewModel.setGroups[weight] ?? []) { set in
                        SetRow(set: set) { reps, newWeight in
                            viewModel.updateSet(set, reps: reps, weight: newWeight)
                        } onDelete: {
                            viewModel.deleteSet(set)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            Button(action: viewModel.addSet) {
                Label("Add Set", systemImage: "plus.circle.fill")
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

class SetListViewModel: ObservableObject {
    @Published private(set) var setGroups: [Double: [ExerciseSet]] = [:]
    private let exercise: Exercise
    private let viewContext: NSManagedObjectContext
    
    init(exercise: Exercise, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.exercise = exercise
        self.viewContext = context
        loadSets()
    }
    
    private func loadSets() {
        guard let sets = exercise.sets as? Set<ExerciseSet> else { return }
        
        var groups: [Double: [ExerciseSet]] = [:]
        for set in sets.sorted(by: { $0.order < $1.order }) {
            groups[set.weight, default: []].append(set)
        }
        setGroups = groups
    }
    
    func addSet() {
        let set = ExerciseSet(context: viewContext)
        set.id = UUID()
        set.exercise = exercise
        set.reps = 0
        set.weight = 0
        set.order = Int16(exercise.sets?.count ?? 0)
        
        saveContext()
        loadSets()
    }
    
    func updateSet(_ set: ExerciseSet, reps: Int, weight: Double) {
        set.reps = Int16(reps)
        set.weight = weight
        saveContext()
        loadSets()
    }
    
    func deleteSet(_ set: ExerciseSet) {
        viewContext.delete(set)
        saveContext()
        loadSets()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving set context: \(error)")
        }
    }
} 