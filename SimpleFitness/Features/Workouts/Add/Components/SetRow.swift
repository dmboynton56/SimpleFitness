import SwiftUI
import CoreData

struct SetRow: View {
    let set: ExerciseSet
    let onUpdate: (Int, Double) -> Void
    let onDelete: () -> Void
    
    @State private var reps: String
    @State private var weight: String
    
    init(set: ExerciseSet, onUpdate: @escaping (Int, Double) -> Void, onDelete: @escaping () -> Void) {
        self.set = set
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _reps = State(initialValue: String(set.reps))
        _weight = State(initialValue: String(format: "%.1f", set.weight))
    }
    
    var body: some View {
        HStack {
            Text("Set \(set.order + 1)")
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            NumberField(
                label: "Reps",
                value: $reps,
                range: 1...99,
                onUpdate: {
                    if let repsNum = Int(reps) {
                        onUpdate(repsNum, Double(weight) ?? set.weight)
                    }
                }
            )
            
            NumberField(
                label: "Weight",
                value: $weight,
                range: 0...999.9,
                onUpdate: {
                    if let weightNum = Double(weight) {
                        onUpdate(Int(reps) ?? Int(set.reps), weightNum)
                    }
                }
            )
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

extension ExerciseSet: Identifiable {} 
