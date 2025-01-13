import Foundation
import CoreData

extension ProgressMetric {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProgressMetric> {
        return NSFetchRequest<ProgressMetric>(entityName: "ProgressMetric")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var type: String?
    @NSManaged public var value: Double
    @NSManaged public var template: ExerciseTemplate?
} 