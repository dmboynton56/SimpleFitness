import SwiftUI

struct ExerciseTemplateSelector: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedTemplate: ExerciseTemplate?
    @Binding var isPresented: Bool
    
    @State private var searchText = ""
    @State private var selectedCategory: String?
    
    private var categories: [String] {
        let request = ExerciseTemplate.fetchRequest()
        let templates = (try? viewContext.fetch(request)) ?? []
        return Array(Set(templates.compactMap { $0.category })).sorted()
    }
    
    private var filteredTemplates: [ExerciseTemplate] {
        let request = ExerciseTemplate.fetchRequest()
        let templates = (try? viewContext.fetch(request)) ?? []
        
        return templates
            .filter { template in
                if let category = selectedCategory {
                    guard template.category == category else { return false }
                }
                if !searchText.isEmpty {
                    guard template.name?.localizedCaseInsensitiveContains(searchText) == true else { return false }
                }
                return true
            }
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
    
    var body: some View {
        List {
            Section {
                TextField("Search", text: $searchText)
            }
            
            if !categories.isEmpty {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { category in
                                Button {
                                    selectedCategory = selectedCategory == category ? nil : category
                                } label: {
                                    Text(category)
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            selectedCategory == category ?
                                            Color.accentColor :
                                            Color.secondary.opacity(0.2)
                                        )
                                        .foregroundColor(
                                            selectedCategory == category ?
                                            .white :
                                            .primary
                                        )
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .listRowInsets(EdgeInsets())
                }
            }
            
            Section {
                ForEach(filteredTemplates) { template in
                    Button {
                        selectedTemplate = template
                        isPresented = false
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(template.name ?? "")
                                    .foregroundColor(.primary)
                                if let category = template.category {
                                    Text(category)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if template.id == selectedTemplate?.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    isPresented = false
                }
            }
        }
    }
} 