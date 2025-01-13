import Foundation
import CoreData

class ProgressCalculationService {
    static let shared = ProgressCalculationService()
    
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }
    
    func getLatestStrengthProgress(for template: ExerciseTemplate) -> StrengthProgress? {
        let request = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "template == %@", template)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.workout?.date, ascending: false)]
        request.fetchLimit = 1
        
        do {
            guard let lastExercise = try viewContext.fetch(request).first,
                  let sets = lastExercise.sets as? Set<ExerciseSet> else {
                return nil
            }
            
            let progress = StrengthProgress(context: viewContext)
            progress.date = lastExercise.workout?.date
            progress.exerciseTemplate = template
            
            // Calculate metrics
            let sortedSets = sets.sorted { $0.order < $1.order }
            progress.maxWeight = sortedSets.map { $0.weight }.max() ?? 0
            progress.maxReps = sortedSets.map { $0.reps }.max() ?? 0
            progress.totalSets = Int16(sets.count)
            progress.totalVolume = sortedSets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
            progress.averageWeight = sortedSets.map { $0.weight }.reduce(0, +) / Double(sets.count)
            
            // Calculate one rep max using Brzycki formula
            if let bestSet = sortedSets.max(by: { $0.weight * Double($0.reps) < $1.weight * Double($1.reps) }) {
                progress.oneRepMax = bestSet.weight * (36 / (37 - Double(bestSet.reps)))
            }
            
            return progress
        } catch {
            print("Error fetching latest progress: \(error)")
            return nil
        }
    }
    
    func getProgressMetrics(for template: ExerciseTemplate) -> [ProgressMetric] {
        let request = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "template == %@", template)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.workout?.date, ascending: true)]
        
        do {
            let exercises = try viewContext.fetch(request)
            var metrics: [ProgressMetric] = []
            
            for exercise in exercises {
                guard let date = exercise.workout?.date,
                      let sets = exercise.sets as? Set<ExerciseSet> else { continue }
                
                let sortedSets = sets.sorted { $0.order < $1.order }
                
                // Max weight metric
                if let maxWeight = sortedSets.map({ $0.weight }).max() {
                    let metric = ProgressMetric(context: viewContext)
                    metric.date = date
                    metric.type = MetricType.maxWeight.rawValue
                    metric.value = maxWeight
                    metrics.append(metric)
                }
                
                // Max reps metric
                if let maxReps = sortedSets.map({ Double($0.reps) }).max() {
                    let metric = ProgressMetric(context: viewContext)
                    metric.date = date
                    metric.type = MetricType.maxReps.rawValue
                    metric.value = maxReps
                    metrics.append(metric)
                }
                
                // One rep max metric
                if let bestSet = sortedSets.max(by: { $0.weight * Double($0.reps) < $1.weight * Double($1.reps) }) {
                    let metric = ProgressMetric(context: viewContext)
                    metric.date = date
                    metric.type = MetricType.oneRepMax.rawValue
                    metric.value = bestSet.weight * (36 / (37 - Double(bestSet.reps)))
                    metrics.append(metric)
                }
                
                // Total volume metric
                let totalVolume = sortedSets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
                let volumeMetric = ProgressMetric(context: viewContext)
                volumeMetric.date = date
                volumeMetric.type = MetricType.totalVolume.rawValue
                volumeMetric.value = totalVolume
                metrics.append(volumeMetric)
                
                // Average weight metric
                let avgWeight = sortedSets.map { $0.weight }.reduce(0, +) / Double(sets.count)
                let avgMetric = ProgressMetric(context: viewContext)
                avgMetric.date = date
                avgMetric.type = MetricType.averageWeight.rawValue
                avgMetric.value = avgWeight
                metrics.append(avgMetric)
            }
            
            return metrics
        } catch {
            print("Error fetching progress metrics: \(error)")
            return []
        }
    }
} 