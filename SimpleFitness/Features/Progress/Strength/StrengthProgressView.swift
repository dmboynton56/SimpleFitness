import SwiftUI

struct StrengthProgressView: View {
    @StateObject private var viewModel = StrengthProgressViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Search and Filter
                VStack(spacing: 12) {
                    // Search
                    TextField("Search exercises", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CategoryButton(
                                title: "All",
                                isSelected: viewModel.selectedCategory == nil,
                                action: { viewModel.selectedCategory = nil }
                            )
                            
                            ForEach(viewModel.categories, id: \.self) { category in
                                CategoryButton(
                                    title: category,
                                    isSelected: viewModel.selectedCategory == category,
                                    action: { viewModel.selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .background(Color(.secondarySystemGroupedBackground))
                
                // Exercise List
                ForEach(viewModel.filteredTemplates) { template in
                    ExerciseProgressCard(
                        template: template,
                        latestProgress: viewModel.getLatestProgress(for: template),
                        progressMetrics: viewModel.getProgress(for: template)
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
}

private struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? .blue : .clear)
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? .clear : .gray.opacity(0.3))
                )
        }
    }
}

#Preview {
    StrengthProgressView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 