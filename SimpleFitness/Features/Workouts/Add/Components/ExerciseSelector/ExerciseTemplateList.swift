import SwiftUI

struct ExerciseTemplateList: View {
    @StateObject private var viewModel = ExerciseTemplateListViewModel()
    @Environment(\.dismiss) private var dismiss
    let onSelectTemplate: (ExerciseTemplate) -> Void
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Recent Exercises")) {
                    ForEach(viewModel.recentTemplates, id: \.id) { template in
                        ExerciseTemplateRow(template: template) {
                            onSelectTemplate(template)
                            dismiss()
                        }
                    }
                }
                
                if !viewModel.categorizedTemplates.isEmpty {
                    ForEach(viewModel.categorizedTemplates.keys.sorted(), id: \.self) { category in
                        Section(header: Text(category)) {
                            ForEach(viewModel.categorizedTemplates[category] ?? [], id: \.id) { template in
                                ExerciseTemplateRow(template: template) {
                                    onSelectTemplate(template)
                                    dismiss()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Exercise")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add New") {
                        viewModel.showingNewExerciseSheet = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search exercises")
            .sheet(isPresented: $viewModel.showingNewExerciseSheet) {
                NewExerciseTemplateView { template in
                    onSelectTemplate(template)
                    dismiss()
                }
            }
        }
    }
}

struct NewExerciseTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var category = ""
    let onSave: (ExerciseTemplate) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Exercise Name", text: $name)
                TextField("Category (optional)", text: $category)
            }
            .navigationTitle("New Exercise")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    let template = ExerciseTemplateService.shared.createTemplate(
                        name: name,
                        category: category.isEmpty ? nil : category
                    )
                    onSave(template)
                    dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
    }
} 