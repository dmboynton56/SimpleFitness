import SwiftUI

struct ExerciseEditForm: View {
    let exercise: Exercise
    let onSave: (String, Int, Int, Double) -> Void
    
    @State private var name: String
    @State private var sets: String
    @State private var reps: String
    @State private var weight: String
    
    init(exercise: Exercise, onSave: @escaping (String, Int, Int, Double) -> Void) {
        self.exercise = exercise
        self.onSave = onSave
        _name = State(initialValue: exercise.name)
        _sets = State(initialValue: String(exercise.sets))
        _reps = State(initialValue: String(exercise.reps))
        _weight = State(initialValue: String(format: "%.1f", exercise.weight))
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
                NumberField(label: "Sets", value: $sets, range: 1...99) {
                    saveChanges()
                }
                
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
        guard let setsNum = Int(sets),
              let repsNum = Int(reps),
              let weightNum = Double(weight) else {
            return
        }
        
        onSave(name, setsNum, repsNum, weightNum)
    }
} 