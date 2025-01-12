import SwiftUI
import CoreData

struct StrengthWorkoutForm: View {
    @ObservedObject var viewModel: AddWorkoutViewModel
    @State private var showingExerciseSelector = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Section {
                    ForEach(viewModel.exercises) { exercise in
                        SetList(exercise: exercise)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                    }
                    .onDelete { indexSet in
                        viewModel.removeExercises(at: indexSet)
                    }
                    
                    Button(action: {
                        showingExerciseSelector = true
                    }) {
                        Label("Add Exercise", systemImage: "plus.circle.fill")
                    }
                    .padding()
                } header: {
                    Text("Exercises")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
                
                Section {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                } header: {
                    Text("Notes")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingExerciseSelector) {
            ExerciseTemplateList(onSelectTemplate: { template in
                viewModel.addExerciseFromTemplate(template)
            })
        }
    }
} 
