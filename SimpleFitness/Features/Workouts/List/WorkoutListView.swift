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
                            HStack {
                                Text(workout.type ?? "Unknown")
                                    .font(.headline)
                                Spacer()
                                Text(viewModel.formattedDate(workout.date))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(viewModel.workoutDetails(workout))
                                .font(.subheadline)
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