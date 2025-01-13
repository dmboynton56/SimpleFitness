import Foundation
import CoreData

@objc(ProgressMetric)
public class ProgressMetric: NSManagedObject, Identifiable {
    static func create(in context: NSManagedObjectContext, type: MetricType) -> ProgressMetric {
        let metric = ProgressMetric(context: context)
        metric.id = UUID()
        metric.date = Date()
        metric.type = type.rawValue
        return metric
    }
}

enum MetricType: String {
    case oneRepMax = "oneRepMax"
    case maxWeight = "maxWeight"
    case maxReps = "maxReps"
    case bestPace = "bestPace"
    case longestDistance = "longestDistance"
    case longestDuration = "longestDuration"
} 