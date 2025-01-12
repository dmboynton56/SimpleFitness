import SwiftUI

struct ExerciseSetList: View {
    let exercise: Exercise
    
    private var orderedSets: [ExerciseSet] {
        guard let sets = exercise.sets as? Set<ExerciseSet> else { return [] }
        return sets.sorted { $0.order < $1.order }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.name ?? "")
                .font(.headline)
            
            ForEach(orderedSets, id: \.id) { set in
                HStack {
                    Text("Set \(set.order + 1)")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(set.reps) reps")
                    Text("•")
                    Text(String(format: "%.1f lbs", set.weight))
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
} 