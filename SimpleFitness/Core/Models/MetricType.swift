import Foundation

enum MetricType: String, CaseIterable, Identifiable {
    case oneRepMax = "1RM"
    case maxWeight = "Max Weight"
    case maxReps = "Max Reps"
    case totalVolume = "Total Volume"
    case averageWeight = "Average Weight"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
}

enum CardioMetricType: String, CaseIterable, Identifiable {
    case distance = "Distance"
    case duration = "Duration"
    case averagePace = "Average Pace"
    case bestPace = "Best Pace"
    case totalDistance = "Total Distance"
    case elevationGain = "Elevation Gain"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
    
    var unit: String {
        switch self {
        case .distance, .totalDistance:
            return "miles"
        case .duration:
            return "minutes"
        case .averagePace, .bestPace:
            return "min/mile"
        case .elevationGain:
            return "feet"
        }
    }
} 