import SwiftUI

struct StrengthWorkoutForm: View {
    @ObservedObject var viewModel: AddWorkoutViewModel
    @State private var newExerciseName = ""
    @State private var showingExerciseInput = false
    
    var body: some View {
        List {
            Section(header: Text("Exercises")) {
                ForEach(viewModel.exercises) { exercise in
                    ExerciseRow(exercise: exercise) { updatedExercise in
                        viewModel.updateExercise(updatedExercise)
                    }
                }
                .onDelete { indexSet in
                    viewModel.removeExercises(at: indexSet)
                }
                
                Button(action: {
                    showingExerciseInput = true
                }) {
                    Label("Add Exercise", systemImage: "plus.circle.fill")
                }
            }
            
            Section(header: Text("Notes")) {
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 100)
            }
        }
        .sheet(isPresented: $showingExerciseInput) {
            NavigationView {
                AddExerciseView { exercise in
                    viewModel.addExercise(exercise)
                    showingExerciseInput = false
                }
            }
        }
    }
}

struct ExerciseRow: View {
    let exercise: ExerciseFormModel
    let onUpdate: (ExerciseFormModel) -> Void
    
    @State private var sets: String
    @State private var reps: String
    @State private var weight: String
    
    init(exercise: ExerciseFormModel, onUpdate: @escaping (ExerciseFormModel) -> Void) {
        self.exercise = exercise
        self.onUpdate = onUpdate
        _sets = State(initialValue: String(exercise.sets))
        _reps = State(initialValue: String(exercise.reps))
        _weight = State(initialValue: String(format: "%.1f", exercise.weight))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(exercise.name)
                .font(.headline)
            
            HStack {
                NumberField(label: "Sets", value: $sets, range: 1...99) {
                    updateExercise()
                }
                
                NumberField(label: "Reps", value: $reps, range: 1...99) {
                    updateExercise()
                }
                
                NumberField(label: "Weight", value: $weight, range: 0...999.9) {
                    updateExercise()
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func updateExercise() {
        let updatedExercise = ExerciseFormModel(
            id: exercise.id,
            name: exercise.name,
            sets: Int(sets) ?? exercise.sets,
            reps: Int(reps) ?? exercise.reps,
            weight: Double(weight) ?? exercise.weight
        )
        onUpdate(updatedExercise)
    }
}

struct NumberField: View {
    let label: String
    @Binding var value: String
    let range: ClosedRange<Double>
    let onUpdate: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            TextField(label, text: $value)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: value) { _ in
                    if let number = Double(value), range.contains(number) {
                        onUpdate()
                    }
                }
        }
    }
}

struct AddExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var exerciseName = ""
    let onAdd: (ExerciseFormModel) -> Void
    
    var body: some View {
        Form {
            TextField("Exercise Name", text: $exerciseName)
        }
        .navigationTitle("Add Exercise")
        .navigationBarItems(
            leading: Button("Cancel") {
                dismiss()
            },
            trailing: Button("Add") {
                let exercise = ExerciseFormModel(
                    name: exerciseName,
                    sets: 3,
                    reps: 10,
                    weight: 0.0
                )
                onAdd(exercise)
            }
            .disabled(exerciseName.isEmpty)
        )
    }
} 