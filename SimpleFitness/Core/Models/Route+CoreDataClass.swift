import Foundation
import CoreData

@objc(Route)
public class Route: NSManagedObject {
    static func create(in context: NSManagedObjectContext) -> Route {
        let route = Route(context: context)
        route.id = UUID()
        route.startTime = Date()
        return route
    }
} 