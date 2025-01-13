import SwiftUI

struct StrengthProgressView: View {
    @StateObject private var viewModel = StrengthProgressViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Search and Filter Section
                VStack(spacing: 12) {
                    TextField("Search exercises", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CategoryButton(
                                title: "All",
                                isSelected: viewModel.selectedCategory == nil,
                                action: { viewModel.selectedCategory = nil }
                            )
                            
                            ForEach(viewModel.categories as [String], id: \.self) { category in
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
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                
                // Exercise List
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.filteredTemplates as [ExerciseTemplate]) { template in
                        ExerciseProgressCard(
                            template: template,
                            latestProgress: viewModel.getLatestProgress(for: template),
                            progressMetrics: viewModel.getProgress(for: template)
                        )
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
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