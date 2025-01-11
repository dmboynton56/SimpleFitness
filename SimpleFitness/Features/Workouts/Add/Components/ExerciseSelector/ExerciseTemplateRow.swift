import SwiftUI

struct ExerciseTemplateRow: View {
    let template: ExerciseTemplate
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name ?? "")
                    .font(.headline)
                
                if let category = template.category {
                    Text(category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
} 