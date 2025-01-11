import Foundation
import CoreData

extension ExerciseSet {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseSet> {
        return NSFetchRequest<ExerciseSet>(entityName: "ExerciseSet")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var reps: Int16
    @NSManaged public var weight: Double
    @NSManaged public var order: Int16
    @NSManaged public var exercise: Exercise?
} 