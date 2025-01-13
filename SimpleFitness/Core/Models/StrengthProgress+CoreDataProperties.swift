import Foundation
import CoreData

extension StrengthProgress {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StrengthProgress> {
        return NSFetchRequest<StrengthProgress>(entityName: "StrengthProgress")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var maxReps: Int16
    @NSManaged public var maxWeight: Double
    @NSManaged public var oneRepMax: Double
    @NSManaged public var exercise: Exercise?
} 