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