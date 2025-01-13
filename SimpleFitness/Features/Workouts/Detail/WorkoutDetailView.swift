import SwiftUI
import CoreData
import MapKit

struct WorkoutDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: WorkoutDetailViewModel
    @State private var showingEditExerciseForm = false
    @State private var selectedExercise: Exercise?
    
    init(workout: Workout) {
        _viewModel = StateObject(wrappedValue: WorkoutDetailViewModel(workout: workout))
    }
    
    var body: some View {
        List {
            Section {
                workoutMetadataSection
                
                if viewModel.isCardioWorkout, let route = viewModel.workout.route {
                    RouteMapView(route: route)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            if !viewModel.isCardioWorkout {
                Section {
                    ForEach(viewModel.exercises) { exercise in
                        NavigationLink {
                            if let template = exercise.template {
                                ExerciseProgressDetail(template: template)
                            }
                        } label: {
                            ExerciseSetList(exercise: exercise)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        viewModel.deleteExercise(exercise)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        selectedExercise = exercise
                                        showingEditExerciseForm = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                } header: {
                    HStack {
                        Text("Exercises")
                        Spacer()
                        Button {
                            selectedExercise = nil
                            showingEditExerciseForm = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.workoutName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingEditExerciseForm) {
            NavigationView {
                EditExerciseForm(
                    workout: viewModel.prepareExerciseForm(exercise: selectedExercise).workout,
                    exercise: viewModel.prepareExerciseForm(exercise: selectedExercise).exercise,
                    onSave: { exercise in
                        if selectedExercise == nil {
                            viewModel.addExercise(exercise)
                        }
                        showingEditExerciseForm = false
                    }
                )
            }
        }
    }
    
    private var workoutMetadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Workout Name", text: Binding(
                get: { viewModel.workoutName },
                set: { viewModel.updateWorkoutName($0) }
            ))
            .font(.headline)
            
            if let date = viewModel.workoutDate {
                Text(date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if viewModel.isCardioWorkout {
                HStack {
                    Label {
                        Text(String(format: "%.2f mi", viewModel.workout.distance))
                    } icon: {
                        Image(systemName: "figure.run")
                    }
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Label {
                        Text(DateComponentsFormatter.timeFormatter.string(from: viewModel.workout.duration) ?? "0:00")
                    } icon: {
                        Image(systemName: "clock")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }
}

// Add time formatter
private extension DateComponentsFormatter {
    static let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        return formatter
    }()
} 