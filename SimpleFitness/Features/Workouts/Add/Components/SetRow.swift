import SwiftUI
import CoreData

struct SetRow: View {
    @ObservedObject var set: ExerciseSet
    let onUpdate: (ExerciseSet) -> Void
    let onDelete: () -> Void
    
    @State private var reps: String
    @State private var weight: String
    @FocusState private var isRepsFocused: Bool
    @FocusState private var isWeightFocused: Bool
    
    init(set: ExerciseSet, onUpdate: @escaping (ExerciseSet) -> Void, onDelete: @escaping () -> Void) {
        self.set = set
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _reps = State(initialValue: String(set.reps))
        _weight = State(initialValue: String(format: "%.1f", set.weight))
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            Text("Set \(set.order + 1)")
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
                .padding(.leading, 16)
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Reps")
                    .font(.caption)
                    .foregroundColor(.secondary)
                NumberField(
                    label: "Reps",
                    value: $reps,
                    range: 1...99
                ) {
                    saveReps()
                }
                .focused($isRepsFocused)
                .frame(width: 80)
                .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Weight")
                    .font(.caption)
                    .foregroundColor(.secondary)
                NumberField(
                    label: "Weight",
                    value: $weight,
                    range: 0...999.9
                ) {
                    saveWeight()
                }
                .focused($isWeightFocused)
                .frame(width: 80)
                .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .padding(.trailing, 16)
        }
        .frame(height: 52)  // Set fixed height for the row
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    if isRepsFocused {
                        saveReps()
                    }
                    if isWeightFocused {
                        saveWeight()
                    }
                    isRepsFocused = false
                    isWeightFocused = false
                }
            }
        }
    }
    
    private func saveReps() {
        if let newReps = Int16(reps) {
            set.reps = newReps
            onUpdate(set)
        }
    }
    
    private func saveWeight() {
        if let newWeight = Double(weight) {
            set.weight = newWeight
            onUpdate(set)
        }
    }
}

extension ExerciseSet: Identifiable {} 
