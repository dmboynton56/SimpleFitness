import SwiftUI
import CoreData

struct AddWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = AddWorkoutViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.workoutType == nil {
                    WorkoutTypeSelectionView(selectedType: $viewModel.workoutType)
                } else {
                    switch viewModel.workoutType {
                    case .strength:
                        VStack(spacing: 16) {
                            TextField("Workout Name (optional)", text: $viewModel.workoutName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                            StrengthWorkoutForm(viewModel: viewModel)
                        }
                    case .running, .biking:
                        CardioWorkoutView { workout in
                            // Refresh workout list after saving
                            viewModel.workoutSaved(workout)
                        }
                    case .none:
                        EmptyView()
                    }
                }
            }
            .navigationTitle("Add Workout")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Group {
                    if viewModel.workoutType == .strength {
                        Button("Save") {
                            viewModel.saveWorkout()
                            DispatchQueue.main.async {
                                dismiss()
                            }
                        }
                    }
                }
            )
        }
    }
}

#Preview {
    AddWorkoutView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 