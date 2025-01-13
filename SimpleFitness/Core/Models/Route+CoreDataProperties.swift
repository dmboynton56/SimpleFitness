import Foundation
import CoreData

extension Route {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Route> {
        return NSFetchRequest<Route>(entityName: "Route")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var distance: Double
    @NSManaged public var points: Set<RoutePoint>?
    @NSManaged public var workout: Workout?
    
    public var pointsArray: [RoutePoint] {
        let set = points ?? []
        return Array(set).sorted { $0.order < $1.order }
    }
    
    public func addPoint(latitude: Double, longitude: Double) {
        let context = self.managedObjectContext!
        let point = RoutePoint.create(in: context)
        point.latitude = latitude
        point.longitude = longitude
        point.timestamp = Date()
        point.order = Int16(pointsArray.count)
        point.route = self
        
        // Update distance if we have at least two points
        if let previousPoint = pointsArray.last {
            let newDistance = calculateDistance(from: previousPoint, to: point)
            distance += newDistance
        }
    }
    
    private func calculateDistance(from point1: RoutePoint, to point2: RoutePoint) -> Double {
        // Simple Haversine formula for distance calculation
        let lat1 = point1.latitude * .pi / 180
        let lat2 = point2.latitude * .pi / 180
        let lon1 = point1.longitude * .pi / 180
        let lon2 = point2.longitude * .pi / 180
        
        let dLat = lat2 - lat1
        let dLon = lon2 - lon1
        
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(lat1) * cos(lat2) *
                sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        // Earth's radius in kilometers
        let r = 6371.0
        
        // Return distance in kilometers
        return r * c
    }
} 