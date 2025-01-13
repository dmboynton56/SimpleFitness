import Foundation
import CoreData
import SwiftUI

@MainActor
class StrengthProgressViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: String?
    @Published var categories: [String] = []
    @Published private(set) var filteredTemplates: [ExerciseTemplate] = []
    
    private var templates: [ExerciseTemplate] = []
    private let viewContext: NSManagedObjectContext
    private let progressService: ProgressCalculationService
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext,
         progressService: ProgressCalculationService = ProgressCalculationService.shared) {
        self.viewContext = context
        self.progressService = progressService
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        let fetchRequest = ExerciseTemplate.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ExerciseTemplate.name, ascending: true)]
        
        do {
            templates = try viewContext.fetch(fetchRequest)
            categories = Array(Set(templates.compactMap { $0.category })).sorted()
            updateFilteredTemplates()
        } catch {
            print("Error fetching exercise templates: \(error)")
        }
    }
    
    private func updateFilteredTemplates() {
        var filtered = templates
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { template in
                guard let name = template.name else { return false }
                return name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        filteredTemplates = filtered
    }
    
    func getLatestProgress(for template: ExerciseTemplate) -> StrengthProgress? {
        progressService.getLatestStrengthProgress(for: template)
    }
    
    func getProgress(for template: ExerciseTemplate) -> [ProgressMetric] {
        progressService.getProgressMetrics(for: template)
    }
} 