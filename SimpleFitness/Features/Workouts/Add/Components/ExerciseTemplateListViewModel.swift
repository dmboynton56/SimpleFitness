import Foundation
import Combine
import CoreData

class ExerciseTemplateListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var showingNewExerciseSheet = false
    @Published var recentTemplates: [ExerciseTemplate] = []
    @Published var categorizedTemplates: [String: [ExerciseTemplate]] = [:]
    
    private let templateService: ExerciseTemplateService
    private var cancellables = Set<AnyCancellable>()
    
    init(templateService: ExerciseTemplateService = .shared) {
        self.templateService = templateService
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
        
        // Filter templates based on search text
        let filteredTemplates = searchText.isEmpty ? templates : templates.filter {
            $0.name?.localizedCaseInsensitiveContains(searchText) == true ||
            $0.category?.localizedCaseInsensitiveContains(searchText) == true
        }
        
        // Get recent templates (used in last 7 days)
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        recentTemplates = filteredTemplates.filter {
            guard let lastUsed = $0.lastUsedDate else { return false }
            return lastUsed > oneWeekAgo
        }
        
        // Categorize remaining templates
        var categorized: [String: [ExerciseTemplate]] = [:]
        
        for template in filteredTemplates {
            let category = template.category ?? "Uncategorized"
            var templatesInCategory = categorized[category] ?? []
            templatesInCategory.append(template)
            categorized[category] = templatesInCategory
        }
        
        categorizedTemplates = categorized
    }
} 