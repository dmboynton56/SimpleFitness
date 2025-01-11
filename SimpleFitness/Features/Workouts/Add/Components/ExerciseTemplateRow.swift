import SwiftUI
import CoreData

struct ExerciseTemplateRow: View {
    let template: ExerciseTemplate
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading) {
                Text(template.name ?? "")
                    .font(.body)
                if let category = template.category {
                    Text(category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
} 