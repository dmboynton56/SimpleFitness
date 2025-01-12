import SwiftUI

struct ExerciseEditForm: View {
    let exercise: Exercise
    let onSave: (String, [(reps: Int16, weight: Double)]) -> Void
    let onAddSet: () -> Void
    let onRemoveSet: (Int) -> Void
    let onRemoveExercise: () -> Void
    
    @State private var name: String
    @FocusState private var focusedField: Field?
    
    private enum Field: Hashable {
        case name
        case reps(Int)
        case weight(Int)
    }
    
    private var orderedSets: [ExerciseSet] {
        guard let sets = exercise.sets as? Set<ExerciseSet> else { return [] }
        return sets.sorted { $0.order < $1.order }
    }
    
    init(
        exercise: Exercise,
        onSave: @escaping (String, [(reps: Int16, weight: Double)]) -> Void,
        onAddSet: @escaping () -> Void,
        onRemoveSet: @escaping (Int) -> Void,
        onRemoveExercise: @escaping () -> Void
    ) {
        self.exercise = exercise
        self.onSave = onSave
        self.onAddSet = onAddSet
        self.onRemoveSet = onRemoveSet
        self.onRemoveExercise = onRemoveExercise
        
        _name = State(initialValue: exercise.name ?? "")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise Header
            HStack(spacing: 8) {
                TextField("Exercise Name", text: $name)
                    .font(.headline)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .name)
                    .onChange(of: name) { oldValue, newValue in
                        saveChanges()
                    }
                
                Button(role: .destructive) {
                    print("Delete exercise tapped")
                    onRemoveExercise()
                } label: {
                    Image(systemName: "trash")
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
            }
            
            // Sets List
            VStack(spacing: 8) {
                ForEach(orderedSets) { set in
                    HStack(spacing: 8) {
                        Text("Set \(set.order + 1)")
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)
                        
                        NumberField(
                            label: "Reps",
                            value: Binding(
                                get: { String(set.reps) },
                                set: { newValue in
                                    if let reps = Int16(newValue) {
                                        set.reps = reps
                                        saveChanges()
                                    }
                                }
                            ),
                            range: 1...99,
                            onUpdate: { saveChanges() }
                        )
                        .focused($focusedField, equals: .reps(Int(set.order)))
                        
                        NumberField(
                            label: "Weight",
                            value: Binding(
                                get: { String(format: "%.1f", set.weight) },
                                set: { newValue in
                                    if let weight = Double(newValue) {
                                        set.weight = weight
                                        saveChanges()
                                    }
                                }
                            ),
                            range: 0...999.9,
                            onUpdate: { saveChanges() }
                        )
                        .focused($focusedField, equals: .weight(Int(set.order)))
                        
                        Button(role: .destructive) {
                            print("Remove set \(set.order) tapped")
                            withAnimation {
                                onRemoveSet(Int(set.order))
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.vertical, 4)
                    .background(Color.clear)
                }
            }
            
            // Add Set Button
            Button {
                print("Add set tapped")
                withAnimation {
                    onAddSet()
                }
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Set")
                }
                .frame(height: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
    
    private func saveChanges() {
        let sets = orderedSets.map { set in
            (reps: set.reps, weight: set.weight)
        }
        onSave(name, sets)
    }
} 