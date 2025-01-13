import SwiftUI

struct EditExerciseForm: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let workout: Workout
    let exercise: Exercise?
    let onSave: (Exercise) -> Void
    
    @State private var selectedTemplate: ExerciseTemplate?
    @State private var showingTemplateSelector = false
    @State private var sets: [(reps: String, weight: String)] = []
    
    init(workout: Workout, exercise: Exercise?, onSave: @escaping (Exercise) -> Void) {
        self.workout = workout
        self.exercise = exercise
        self.onSave = onSave
        
        if let exercise = exercise {
            let exerciseSets = (exercise.sets as? Set<ExerciseSet>)?
                .sorted { $0.order < $1.order }
                .map { set in
                    (
                        reps: String(set.reps),
                        weight: String(format: "%.1f", set.weight)
                    )
                }
            _sets = State(initialValue: exerciseSets ?? [])
            _selectedTemplate = State(initialValue: exercise.template)
        } else {
            _sets = State(initialValue: [(reps: "0", weight: "0.0")])
        }
    }
    
    var body: some View {
        Form {
            exerciseSelectionSection
            setsSection
        }
        .navigationTitle(exercise == nil ? "Add Exercise" : "Edit Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveExercise()
                }
                .disabled(selectedTemplate == nil)
            }
        }
        .sheet(isPresented: $showingTemplateSelector) {
            NavigationView {
                ExerciseTemplateSelector(
                    selectedTemplate: $selectedTemplate,
                    isPresented: $showingTemplateSelector
                )
            }
        }
    }
    
    private var exerciseSelectionSection: some View {
        Section {
            exerciseTemplateButton
        }
    }
    
    private var exerciseTemplateButton: some View {
        Button {
            showingTemplateSelector = true
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(selectedTemplate?.name ?? "Select Exercise")
                        .font(.headline)
                        .foregroundColor(selectedTemplate == nil ? .secondary : .primary)
                    if let category = selectedTemplate?.category {
                        Text(category)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var setsSection: some View {
        Section {
            ForEach(sets.indices, id: \.self) { index in
                setRow(at: index)
            }
            
            Button {
                sets.append((reps: "0", weight: "0.0"))
            } label: {
                Label("Add Set", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Sets")
        }
    }
    
    private func setRow(at index: Int) -> some View {
        HStack {
            Text("Set \(index + 1)")
                .foregroundStyle(.secondary)
            
            Spacer()
            
            TextField("Reps", text: $sets[index].reps)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 60)
            
            Text("×")
                .foregroundStyle(.secondary)
            
            TextField("Weight", text: $sets[index].weight)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 60)
            
            if sets.count > 1 {
                Button {
                    sets.remove(at: index)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private func saveExercise() {
        guard let template = selectedTemplate else { return }
        
        let exercise = self.exercise ?? Exercise(context: viewContext)
        exercise.id = UUID()
        exercise.template = template
        
        // Remove existing sets if editing
        if let existingSets = exercise.sets as? Set<ExerciseSet> {
            existingSets.forEach { viewContext.delete($0) }
        }
        
        // Create new sets
        sets.enumerated().forEach { index, setData in
            let set = ExerciseSet(context: viewContext)
            set.id = UUID()
            set.order = Int16(index)
            set.reps = Int16(setData.reps) ?? 0
            set.weight = Double(setData.weight) ?? 0.0
            exercise.addToSets(set)
        }
        
        onSave(exercise)
        dismiss()
    }
} 