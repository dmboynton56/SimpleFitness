import SwiftUI
import CoreData

struct AddWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddWorkoutViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.workoutType == nil {
                    WorkoutTypeSelectionView(selectedType: $viewModel.workoutType)
                } else {
                    switch viewModel.workoutType {
                    case .strength:
                        StrengthWorkoutForm(viewModel: viewModel)
                    case .running, .biking:
                        CardioWorkoutForm(viewModel: viewModel)
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
                trailing: Button("Save") {
                    viewModel.saveWorkout()
                    dismiss()
                }
                .disabled(viewModel.workoutType == nil)
            )
        }
    }
}

struct AddWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        AddWorkoutView()
    }
} 