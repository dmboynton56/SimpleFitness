import SwiftUI
import CoreData

struct NewExerciseTemplateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    let onTemplateCreated: (ExerciseTemplate) -> Void
    
    @State private var name = ""
    @State private var category = ""
    
    private let templateService = ExerciseTemplateService.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Exercise Name", text: $name)
                    TextField("Category (optional)", text: $category)
                }
            }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveTemplate() {
        let template = templateService.createTemplate(
            name: name,
            category: category.isEmpty ? nil : category
        )
        onTemplateCreated(template)
        dismiss()
    }
} 