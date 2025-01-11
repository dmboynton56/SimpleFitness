import SwiftUI

struct WorkoutListView: View {
    @StateObject private var viewModel = WorkoutListViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.workouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(workout.name ?? "Untitled Workout")
                                .font(.headline)
                            
                            HStack {
                                Text(workout.type ?? "Unknown")
                                    .foregroundColor(.secondary)
                                Text("•")
                                    .foregroundColor(.secondary)
                                Text(viewModel.workoutDetails(workout))
                                    .foregroundColor(.secondary)
                            }
                            .font(.subheadline)
                            
                            Text(viewModel.formattedDate(workout.date))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: viewModel.deleteWorkouts)
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showingAddWorkout = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddWorkout, onDismiss: {
                viewModel.fetchWorkouts()
            }) {
                AddWorkoutView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
} 