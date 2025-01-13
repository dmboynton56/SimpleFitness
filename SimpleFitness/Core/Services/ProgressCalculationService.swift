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
            progress.id = UUID()
            progress.date = lastExercise.workout?.date
            progress.exercise = lastExercise
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
            
            try viewContext.save()
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
                    metric.id = UUID()
                    metric.date = date
                    metric.type = MetricType.maxWeight.rawValue
                    metric.value = maxWeight
                    metric.template = template
                    metrics.append(metric)
                }
                
                // Max reps metric
                if let maxReps = sortedSets.map({ Double($0.reps) }).max() {
                    let metric = ProgressMetric(context: viewContext)
                    metric.id = UUID()
                    metric.date = date
                    metric.type = MetricType.maxReps.rawValue
                    metric.value = maxReps
                    metric.template = template
                    metrics.append(metric)
                }
                
                // One rep max metric
                if let bestSet = sortedSets.max(by: { $0.weight * Double($0.reps) < $1.weight * Double($1.reps) }) {
                    let metric = ProgressMetric(context: viewContext)
                    metric.id = UUID()
                    metric.date = date
                    metric.type = MetricType.oneRepMax.rawValue
                    metric.value = bestSet.weight * (36 / (37 - Double(bestSet.reps)))
                    metric.template = template
                    metrics.append(metric)
                }
                
                // Total volume metric
                let totalVolume = sortedSets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
                let volumeMetric = ProgressMetric(context: viewContext)
                volumeMetric.id = UUID()
                volumeMetric.date = date
                volumeMetric.type = MetricType.totalVolume.rawValue
                volumeMetric.value = totalVolume
                volumeMetric.template = template
                metrics.append(volumeMetric)
                
                // Average weight metric
                let avgWeight = sortedSets.map { $0.weight }.reduce(0, +) / Double(sets.count)
                let avgMetric = ProgressMetric(context: viewContext)
                avgMetric.id = UUID()
                avgMetric.date = date
                avgMetric.type = MetricType.averageWeight.rawValue
                avgMetric.value = avgWeight
                avgMetric.template = template
                metrics.append(avgMetric)
            }
            
            try viewContext.save()
            return metrics
        } catch {
            print("Error fetching progress metrics: \(error)")
            return []
        }
    }
    
    func updateCardioProgress(for route: Route) {
        guard let workout = route.workout,
              let points = route.points as? Set<RoutePoint>,
              points.count > 1 else {
            return
        }
        
        let progress = CardioProgress(context: viewContext)
        progress.id = UUID()
        progress.date = workout.date
        progress.route = route
        progress.distance = route.distance
        
        // Calculate duration from route points
        let sortedPoints = points.sorted { $0.order < $1.order }
        if let startTime = sortedPoints.first?.timestamp,
           let endTime = sortedPoints.last?.timestamp {
            progress.duration = endTime.timeIntervalSince(startTime)
        }
        
        // Calculate pace (minutes per kilometer)
        if progress.distance > 0 {
            progress.averagePace = (progress.duration / 60) / (progress.distance / 1000)
            
            // Calculate max pace from route segments
            var maxPace: Double = 0
            for i in 0..<(sortedPoints.count - 1) {
                let point1 = sortedPoints[i]
                let point2 = sortedPoints[i + 1]
                
                let segmentDistance = calculateDistance(from: point1, to: point2)
                let segmentDuration = point2.timestamp?.timeIntervalSince(point1.timestamp ?? Date()) ?? 0
                
                if segmentDistance > 0 {
                    let segmentPace = (segmentDuration / 60) / (segmentDistance / 1000)
                    maxPace = max(maxPace, segmentPace)
                }
            }
            progress.maxPace = maxPace
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving cardio progress: \(error)")
        }
    }
    
    private func calculateDistance(from point1: RoutePoint, to point2: RoutePoint) -> Double {
        let lat1 = point1.latitude
        let lon1 = point1.longitude
        let lat2 = point2.latitude
        let lon2 = point2.longitude
        
        let R = 6371e3 // Earth's radius in meters
        let φ1 = lat1 * .pi / 180
        let φ2 = lat2 * .pi / 180
        let Δφ = (lat2 - lat1) * .pi / 180
        let Δλ = (lon2 - lon1) * .pi / 180
        
        let a = sin(Δφ/2) * sin(Δφ/2) +
                cos(φ1) * cos(φ2) *
                sin(Δλ/2) * sin(Δλ/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return R * c // Distance in meters
    }
} 