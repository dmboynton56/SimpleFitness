import Foundation
import Combine

class ExerciseTemplateListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var showingNewExerciseSheet = false
    @Published private(set) var recentTemplates: [ExerciseTemplate] = []
    @Published private(set) var categorizedTemplates: [String: [ExerciseTemplate]] = [:]
    
    private let templateService = ExerciseTemplateService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearchSubscription()
        loadTemplates()
    }
    
    private func setupSearchSubscription() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadTemplates()
            }
            .store(in: &cancellables)
    }
    
    private func loadTemplates() {
        let templates = templateService.fetchTemplates()
        
        if searchText.isEmpty {
            // Show recent templates (last 5 used)
            recentTemplates = Array(templates.prefix(5))
            
            // Categorize remaining templates
            var categorized: [String: [ExerciseTemplate]] = [:]
            for template in templates.dropFirst(5) {
                let category = template.category ?? "Uncategorized"
                categorized[category, default: []].append(template)
            }
            categorizedTemplates = categorized
        } else {
            // Filter templates by search text
            let filtered = templates.filter { template in
                template.name?.localizedCaseInsensitiveContains(searchText) == true ||
                template.category?.localizedCaseInsensitiveContains(searchText) == true
            }
            
            // Show all filtered templates in recent section
            recentTemplates = filtered
            categorizedTemplates = [:]
        }
    }
} 