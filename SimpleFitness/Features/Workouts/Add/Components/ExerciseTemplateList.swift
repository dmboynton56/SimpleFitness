import SwiftUI
import CoreData

struct ExerciseTemplateList: View {
    @StateObject private var viewModel = ExerciseTemplateListViewModel()
    let onTemplateSelected: (ExerciseTemplate) -> Void
    
    var body: some View {
        NavigationView {
            List {
                if !viewModel.recentTemplates.isEmpty {
                    Section("Recent") {
                        ForEach(viewModel.recentTemplates) { template in
                            ExerciseTemplateRow(template: template) {
                                onTemplateSelected(template)
                            }
                        }
                    }
                }
                
                ForEach(viewModel.categorizedTemplates.keys.sorted(), id: \.self) { category in
                    Section(category) {
                        ForEach(viewModel.categorizedTemplates[category] ?? []) { template in
                            ExerciseTemplateRow(template: template) {
                                onTemplateSelected(template)
                            }
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchText)
            .navigationTitle("Select Exercise")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add New") {
                        viewModel.showingNewExerciseSheet = true
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingNewExerciseSheet) {
                NewExerciseTemplateSheet { template in
                    onTemplateSelected(template)
                }
            }
        }
    }
}

extension ExerciseTemplate: Identifiable {} 
