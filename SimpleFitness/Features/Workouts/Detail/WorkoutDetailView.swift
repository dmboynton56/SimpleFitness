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
                        VStack(alignment: .leading) {
                            Text(exercise.name)
                                .font(.headline)
                            HStack {
                                Text("\(exercise.sets) sets")
                                Text("•")
                                Text("\(exercise.reps) reps")
                                Text("•")
                                Text(String(format: "%.1f lbs", exercise.weight))
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
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
                Button(viewModel.isEditing ? "Done" : "Edit") {
                    viewModel.isEditing.toggle()
                }
            }
        }
    }
} 