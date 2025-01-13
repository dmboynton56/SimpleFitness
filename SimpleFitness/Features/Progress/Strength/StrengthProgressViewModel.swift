import Foundation
import CoreData
import SwiftUI

@MainActor
class StrengthProgressViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: String?
    @Published private(set) var templates: [ExerciseTemplate] = []
    @Published private(set) var categories: [String] = []
    
    private let progressService: ProgressCalculationService
    private let viewContext: NSManagedObjectContext
    
    init(progressService: ProgressCalculationService = ProgressCalculationService.shared,
         viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.progressService = progressService
        self.viewContext = viewContext
        
        Task {
            await loadData()
        }
    }
    
    var filteredTemplates: [ExerciseTemplate] {
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
        
        return filtered
    }
    
    func getLatestProgress(for template: ExerciseTemplate) -> StrengthProgress? {
        progressService.getLatestStrengthProgress(for: template)
    }
    
    func getProgress(for template: ExerciseTemplate) -> [ProgressMetric] {
        progressService.getProgressMetrics(for: template)
    }
    
    private func loadData() async {
        let fetchRequest = ExerciseTemplate.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ExerciseTemplate.name, ascending: true)]
        
        do {
            templates = try viewContext.fetch(fetchRequest)
            categories = Array(Set(templates.compactMap { $0.category })).sorted()
        } catch {
            print("Error fetching exercise templates: \(error)")
        }
    }
} 