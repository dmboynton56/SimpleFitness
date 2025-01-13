import Foundation
import CoreData

@MainActor
class ExerciseProgressDetailViewModel: ObservableObject {
    private let template: ExerciseTemplate
    private let progressService: ProgressCalculationService
    
    @Published private(set) var latestProgress: StrengthProgress?
    @Published private(set) var progressMetrics: [ProgressMetric]?
    @Published private(set) var exerciseHistory: [Exercise]?
    
    init(template: ExerciseTemplate, progressService: ProgressCalculationService) {
        self.template = template
        self.progressService = progressService
        Task {
            await loadData()
        }
    }
    
    private func loadData() async {
        // Load latest progress
        if let progress = try? await progressService.getLatestStrengthProgress(for: template) {
            latestProgress = progress
        }
        
        // Load progress metrics
        if let metrics = try? await progressService.getProgressMetrics(for: template) {
            progressMetrics = metrics
        }
        
        // Load exercise history
        await loadExerciseHistory()
    }
    
    private func loadExerciseHistory() async {
        let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "template == %@", template)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.workout?.date, ascending: false)]
        fetchRequest.fetchLimit = 10 // Show last 10 workouts
        
        if let context = template.managedObjectContext {
            do {
                let exercises = try context.fetch(fetchRequest)
                exerciseHistory = exercises
            } catch {
                print("Error fetching exercise history: \(error)")
            }
        }
    }
} 