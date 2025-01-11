import SwiftUI

struct ExerciseEditForm: View {
    let exercise: Exercise
    let onSave: (String, Int16, Double) -> Void
    
    @State private var name: String
    @State private var reps: String
    @State private var weight: String
    
    init(exercise: Exercise, onSave: @escaping (String, Int16, Double) -> Void) {
        self.exercise = exercise
        self.onSave = onSave
        
        // Initialize with default values if nil
        _name = State(initialValue: exercise.name ?? "")
        
        // Get the first set's values or defaults
        let firstSet = (exercise.sets as? Set<ExerciseSet>)?.first
        _reps = State(initialValue: String(firstSet?.reps ?? 0))
        _weight = State(initialValue: String(format: "%.1f", firstSet?.weight ?? 0.0))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            TextField("Exercise Name", text: $name)
                .font(.headline)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: name) { oldValue, newValue in
                    saveChanges()
                }
            
            HStack {
                NumberField(label: "Reps", value: $reps, range: 1...99) {
                    saveChanges()
                }
                
                NumberField(label: "Weight", value: $weight, range: 0...999.9) {
                    saveChanges()
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func saveChanges() {
        guard let repsNum = Int16(reps),
              let weightNum = Double(weight) else {
            return
        }
        
        onSave(name, repsNum, weightNum)
    }
} 