import SwiftUI

struct WorkoutDetailView: View {
    @StateObject private var viewModel: WorkoutDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
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
                            ExerciseEditForm(exercise: exercise) { name, reps, weight in
                                viewModel.updateExercise(exercise, name: name, reps: reps, weight: weight)
                            }
                        } else {
                            VStack(alignment: .leading) {
                                Text(exercise.name ?? "")
                                    .font(.headline)
                                if let sets = exercise.sets as? Set<ExerciseSet>, let firstSet = sets.first {
                                    HStack {
                                        Text("\(firstSet.reps) reps")
                                        Text("•")
                                        Text(String(format: "%.1f lbs", firstSet.weight))
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text("Exercises")
                }
            }
            
            // Notes Section
            if let notes = viewModel.workout.notes, !notes.isEmpty {
                Section {
                    Text(notes)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Notes")
                }
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
    }
} 