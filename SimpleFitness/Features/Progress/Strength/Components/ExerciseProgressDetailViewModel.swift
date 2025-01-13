import Foundation
import CoreData

@MainActor
class ExerciseProgressDetailViewModel: ObservableObject {
    @Published private(set) var latestProgress: StrengthProgress?
    @Published private(set) var progressMetrics: [ProgressMetric] = []
    @Published private(set) var exerciseHistory: [(date: Date, sets: [ExerciseSet])] = []
    
    private let template: ExerciseTemplate
    private let progressService: ProgressCalculationService
    private let viewContext: NSManagedObjectContext
    
    init(template: ExerciseTemplate,
         progressService: ProgressCalculationService = ProgressCalculationService.shared,
         viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.template = template
        self.progressService = progressService
        self.viewContext = viewContext
        
        Task {
            await loadData()
        }
    }
    
    private func loadData() async {
        latestProgress = progressService.getLatestStrengthProgress(for: template)
        progressMetrics = progressService.getProgressMetrics(for: template)
        loadExerciseHistory()
    }
    
    private func loadExerciseHistory() {
        let request = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "template == %@", template)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.workout?.date, ascending: false)]
        request.fetchLimit = 10 // Last 10 workouts
        
        do {
            let exercises = try viewContext.fetch(request)
            exerciseHistory = exercises.compactMap { exercise in
                guard let date = exercise.workout?.date,
                      let sets = exercise.sets as? Set<ExerciseSet> else {
                    return nil
                }
                return (date: date, sets: Array(sets))
            }
        } catch {
            print("Error fetching exercise history: \(error)")
        }
    }
} 