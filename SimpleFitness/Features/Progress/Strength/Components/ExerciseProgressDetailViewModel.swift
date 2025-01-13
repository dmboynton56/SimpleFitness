import Foundation
import CoreData

@MainActor
class ExerciseProgressDetailViewModel: ObservableObject {
    private(set) var template: ExerciseTemplate
    private let progressService: ProgressCalculationService
    
    @Published var selectedMetricType: MetricType = .oneRepMax
    @Published var latestProgress: StrengthProgress?
    @Published var progressMetrics: [ProgressMetric] = []
    @Published var exerciseHistory: [(date: Date, sets: [ExerciseSet])] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    init(template: ExerciseTemplate) {
        self.template = template
        self.progressService = ProgressCalculationService(viewContext: template.managedObjectContext!)
        Task { await loadData() }
    }
    
    @MainActor
    func loadData() async {
        isLoading = true
        error = nil
        
        do {
            // Load latest progress
            if let progress = try await progressService.getLatestStrengthProgress(for: template) {
                latestProgress = progress
            }
            
            // Load progress metrics
            let metrics = try await progressService.getProgressMetrics(for: template)
            progressMetrics = metrics
            
            // Load exercise history
            let history = try await loadExerciseHistory()
            exerciseHistory = history
            
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    private func loadExerciseHistory() async throws -> [(date: Date, sets: [ExerciseSet])] {
        let context = template.managedObjectContext!
        let request = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "template == %@ AND workout != nil", template)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.workout?.date, ascending: false)]
        request.fetchLimit = 10
        
        let exercises = try context.fetch(request)
        return exercises.compactMap { exercise in
            guard let date = exercise.workout?.date,
                  let sets = exercise.sets?.allObjects as? [ExerciseSet] else {
                return nil
            }
            return (date: date, sets: sets)
        }
    }
} 