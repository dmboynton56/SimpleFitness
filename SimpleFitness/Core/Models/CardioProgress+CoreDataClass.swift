import Foundation
import CoreData

@objc(CardioProgress)
public class CardioProgress: NSManagedObject, Identifiable {
    static func create(in context: NSManagedObjectContext) -> CardioProgress {
        let progress = CardioProgress(context: context)
        progress.id = UUID()
        progress.date = Date()
        return progress
    }
    
    // Helper method to calculate pace (minutes per mile)
    func calculatePace(distance: Double, duration: Double) -> Double {
        guard distance > 0 else { return 0 }
        return duration / 60 / distance // Convert seconds to minutes and divide by distance
    }
    
    // Helper method to update progress from a route
    func updateFromRoute(_ route: Route) {
        self.distance = route.distance
        
        if let start = route.startTime, let end = route.endTime {
            self.duration = end.timeIntervalSince(start)
            
            // Calculate and update paces
            let pace = calculatePace(distance: route.distance, duration: self.duration)
            
            // Update average pace
            self.averagePace = pace
            
            // Update max pace if it's faster (lower number is faster)
            if self.maxPace == 0 || pace < self.maxPace {
                self.maxPace = pace
            }
        }
    }
} 