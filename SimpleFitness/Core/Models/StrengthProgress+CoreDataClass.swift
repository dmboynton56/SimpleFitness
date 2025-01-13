import Foundation
import CoreData

@objc(StrengthProgress)
public class StrengthProgress: NSManagedObject, Identifiable {
    static func create(in context: NSManagedObjectContext) -> StrengthProgress {
        let progress = StrengthProgress(context: context)
        progress.id = UUID()
        progress.date = Date()
        return progress
    }
    
    // Helper method to calculate one rep max using Brzycki formula
    func calculateOneRepMax(weight: Double, reps: Int16) -> Double {
        // Brzycki Formula: 1RM = weight × (36 / (37 - reps))
        return weight * (36.0 / (37.0 - Double(reps)))
    }
    
    // Helper method to update progress from a set
    func updateFromSet(_ set: ExerciseSet) {
        // Update max weight if this set has a higher weight
        if set.weight > maxWeight {
            maxWeight = set.weight
        }
        
        // Update max reps if this set has more reps
        if set.reps > maxReps {
            maxReps = set.reps
        }
        
        // Calculate and update one rep max if it's higher than current
        let calculatedOneRepMax = calculateOneRepMax(weight: set.weight, reps: set.reps)
        if calculatedOneRepMax > oneRepMax {
            oneRepMax = calculatedOneRepMax
        }
    }
} 