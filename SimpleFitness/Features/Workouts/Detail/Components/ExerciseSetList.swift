import SwiftUI

struct ExerciseSetList: View {
    let exercise: Exercise
    
    private var orderedSets: [ExerciseSet] {
        guard let sets = exercise.sets as? Set<ExerciseSet> else { return [] }
        return sets.sorted { $0.order < $1.order }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(exercise.name ?? "")
                        .font(.headline)
                    if let category = exercise.template?.category {
                        Text(category)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chart.xyaxis.line")
                    .foregroundStyle(.blue)
                    .font(.caption)
            }
            
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
            
            if orderedSets.isEmpty {
                Text("No sets recorded")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
} 