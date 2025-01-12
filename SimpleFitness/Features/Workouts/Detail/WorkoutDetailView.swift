import SwiftUI

struct WorkoutDetailView: View {
    @StateObject private var viewModel: WorkoutDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingExerciseSelector = false
    
    init(workout: Workout) {
        _viewModel = StateObject(wrappedValue: WorkoutDetailViewModel(workout: workout))
    }
    
    var body: some View {
        List {
            // Workout Metadata Section
            Section {
                if viewModel.isEditing {
                    TextField("Workout Name", text: Binding(
                        get: { viewModel.workout.name ?? "" },
                        set: { viewModel.updateWorkoutName($0) }
                    ))
                } else {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(viewModel.workout.name ?? "Untitled Workout")
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text("Type")
                    Spacer()
                    Text(viewModel.workout.type ?? "Unknown")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Date")
                    Spacer()
                    Text(viewModel.formattedDate())
                        .foregroundColor(.secondary)
                }
                
                if viewModel.workout.type == "Running" || viewModel.workout.type == "Biking" {
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(viewModel.workoutDuration())
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Distance")
                        Spacer()
                        Text(viewModel.workoutDistance())
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("Workout Details")
            }
            
            // Exercises Section (for strength workouts)
            if viewModel.workout.type == "Strength" {
                Section {
                    ForEach(viewModel.exercises) { exercise in
                        if viewModel.isEditing {
                            ExerciseEditForm(
                                exercise: exercise,
                                onSave: { name, sets in
                                    viewModel.updateExercise(exercise, name: name, sets: sets)
                                },
                                onAddSet: {
                                    viewModel.addSetToExercise(exercise)
                                },
                                onRemoveSet: { index in
                                    viewModel.removeSetFromExercise(exercise, at: index)
                                },
                                onRemoveExercise: {
                                    viewModel.removeExercise(exercise)
                                }
                            )
                        } else {
                            ExerciseSetList(exercise: exercise)
                        }
                    }
                    
                    if viewModel.isEditing {
                        Button(action: { showingExerciseSelector = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Exercise")
                            }
                        }
                    }
                } header: {
                    Text("Exercises")
                }
            }
            
            // Notes Section
            Section {
                if viewModel.isEditing {
                    TextField("Notes", text: Binding(
                        get: { viewModel.workout.notes ?? "" },
                        set: { viewModel.updateWorkoutNotes($0) }
                    ), axis: .vertical)
                    .lineLimit(3...6)
                } else if let notes = viewModel.workout.notes, !notes.isEmpty {
                    Text(notes)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Notes")
            }
        }
        .navigationTitle(viewModel.workout.type ?? "Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.workout.type == "Strength" {
                    Button(viewModel.isEditing ? "Done" : "Edit") {
                        viewModel.isEditing.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $showingExerciseSelector) {
            NavigationView {
                ExerciseTemplateList { template in
                    viewModel.addExerciseFromTemplate(template)
                    showingExerciseSelector = false
                }
            }
        }
    }
} 