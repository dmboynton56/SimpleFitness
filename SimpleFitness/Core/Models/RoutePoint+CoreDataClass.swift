import Foundation
import CoreData

@objc(RoutePoint)
public class RoutePoint: NSManagedObject {
    static func create(in context: NSManagedObjectContext) -> RoutePoint {
        let point = RoutePoint(context: context)
        point.id = UUID()
        return point
    }
} 