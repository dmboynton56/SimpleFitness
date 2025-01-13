import Foundation
import CoreData

extension CardioProgress {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardioProgress> {
        return NSFetchRequest<CardioProgress>(entityName: "CardioProgress")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var distance: Double
    @NSManaged public var duration: Double
    @NSManaged public var averagePace: Double
    @NSManaged public var maxPace: Double
    @NSManaged public var route: Route?
} 