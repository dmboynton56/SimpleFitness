import Foundation
import CoreData

class ProgressCalculationService {
    static let shared = ProgressCalculationService()
    
    private let context: NSManagedObjectContext
    
    private init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    // MARK: - Strength Progress
    
    func updateStrengthProgress(for exercise: Exercise) {
        // Create new progress entry
        let progress = StrengthProgress.create(in: context)
        progress.exercise = exercise
        
        // Process all sets to find maxes
        if let sets = exercise.sets as? Set<ExerciseSet> {
            for set in sets {
                progress.updateFromSet(set)
            }
        }
        
        // Create or update template metrics
        if let template = exercise.template {
            updateProgressMetrics(for: template, from: progress)
        }
        
        saveContext()
    }
    
    // MARK: - Cardio Progress
    
    func updateCardioProgress(for route: Route) {
        // Create new progress entry
        let progress = CardioProgress.create(in: context)
        progress.route = route
        progress.updateFromRoute(route)
        
        saveContext()
    }
    
    // MARK: - Progress Metrics
    
    private func updateProgressMetrics(for template: ExerciseTemplate, from progress: StrengthProgress) {
        // Update one rep max metric
        updateMetric(for: template, type: .oneRepMax, value: progress.oneRepMax)
        
        // Update max weight metric
        updateMetric(for: template, type: .maxWeight, value: progress.maxWeight)
        
        // Update max reps metric
        updateMetric(for: template, type: .maxReps, value: Double(progress.maxReps))
    }
    
    private func updateMetric(for template: ExerciseTemplate, type: MetricType, value: Double) {
        // Fetch existing metric of this type if it exists
        let request = ProgressMetric.fetchRequest()
        request.predicate = NSPredicate(format: "template == %@ AND type == %@", template, type.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ProgressMetric.value, ascending: false)]
        request.fetchLimit = 1
        
        do {
            let existingMetrics = try context.fetch(request)
            
            // Only create new metric if value is higher than existing
            if let existing = existingMetrics.first {
                if value > existing.value {
                    createNewMetric(for: template, type: type, value: value)
                }
            } else {
                createNewMetric(for: template, type: type, value: value)
            }
        } catch {
            print("Error fetching metrics: \(error)")
        }
    }
    
    private func createNewMetric(for template: ExerciseTemplate, type: MetricType, value: Double) {
        let metric = ProgressMetric.create(in: context, type: type)
        metric.value = value
        metric.template = template
    }
    
    // MARK: - Fetching Progress
    
    func fetchStrengthProgress(for exercise: Exercise) -> [StrengthProgress] {
        let request = StrengthProgress.fetchRequest()
        request.predicate = NSPredicate(format: "exercise == %@", exercise)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \StrengthProgress.date, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching strength progress: \(error)")
            return []
        }
    }
    
    func fetchCardioProgress(for workout: Workout) -> CardioProgress? {
        guard let route = workout.route else { return nil }
        
        let request = CardioProgress.fetchRequest()
        request.predicate = NSPredicate(format: "route == %@", route)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching cardio progress: \(error)")
            return nil
        }
    }
    
    func fetchProgressMetrics(for template: ExerciseTemplate, type: MetricType) -> [ProgressMetric] {
        let request = ProgressMetric.fetchRequest()
        request.predicate = NSPredicate(format: "template == %@ AND type == %@", template, type.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ProgressMetric.date, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching progress metrics: \(error)")
            return []
        }
    }
    
    // MARK: - Utilities
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving progress: \(error)")
        }
    }
} 