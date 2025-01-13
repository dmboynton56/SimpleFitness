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
    
    // Helper method to calculate split times (pace for each mile)
    func calculateSplits(from points: [RoutePoint]) -> [(mile: Int, pace: Double)] {
        var splits: [(mile: Int, pace: Double)] = []
        var currentMileDistance = 0.0
        var currentMileStartTime = points.first?.timestamp
        var currentMilePoints: [RoutePoint] = []
        
        for i in 1..<points.count {
            let point = points[i]
            let prevPoint = points[i-1]
            
            // Calculate distance between points
            if let route = self.route {
                let segmentDistance = route.calculateDistance(from: prevPoint, to: point)
                currentMileDistance += segmentDistance
                currentMilePoints.append(point)
                
                // If we've completed a mile
                if currentMileDistance >= 1.0 {
                    if let startTime = currentMileStartTime,
                       let endTime = point.timestamp {
                        let duration = endTime.timeIntervalSince(startTime)
                        let pace = calculatePace(distance: currentMileDistance, duration: duration)
                        splits.append((mile: splits.count + 1, pace: pace))
                    }
                    
                    // Reset for next mile
                    currentMileDistance = 0.0
                    currentMileStartTime = point.timestamp
                    currentMilePoints = []
                }
            }
        }
        
        return splits
    }
    
    // Helper method to calculate elevation changes
    func calculateElevationChanges(from points: [RoutePoint]) -> (gain: Double, loss: Double) {
        var totalGain = 0.0
        var totalLoss = 0.0
        
        for i in 1..<points.count {
            let elevationChange = points[i].elevation - points[i-1].elevation
            if elevationChange > 0 {
                totalGain += elevationChange
            } else {
                totalLoss += abs(elevationChange)
            }
        }
        
        return (gain: totalGain, loss: totalLoss)
    }
    
    // Helper method to find best pace segment
    func findBestPaceSegment(from points: [RoutePoint], segmentDistance: Double = 0.25) -> Double? {
        var bestPace: Double?
        var currentSegmentPoints: [RoutePoint] = []
        
        for point in points {
            currentSegmentPoints.append(point)
            
            // Calculate total distance of current segment
            var segmentDistance = 0.0
            for i in 1..<currentSegmentPoints.count {
                if let route = self.route {
                    segmentDistance += route.calculateDistance(
                        from: currentSegmentPoints[i-1],
                        to: currentSegmentPoints[i]
                    )
                }
            }
            
            // If segment is long enough, calculate pace
            if segmentDistance >= segmentDistance,
               let startTime = currentSegmentPoints.first?.timestamp,
               let endTime = currentSegmentPoints.last?.timestamp {
                let duration = endTime.timeIntervalSince(startTime)
                let pace = calculatePace(distance: segmentDistance, duration: duration)
                
                if bestPace == nil || pace < bestPace! {
                    bestPace = pace
                }
                
                // Remove oldest point and recalculate
                currentSegmentPoints.removeFirst()
            }
        }
        
        return bestPace
    }
    
    // Helper method to update progress from a route
    func updateFromRoute(_ route: Route) {
        self.distance = route.distance
        
        if let start = route.startTime, let end = route.endTime {
            self.duration = end.timeIntervalSince(start)
            
            // Calculate and update paces
            let pace = calculatePace(distance: route.distance, duration: self.duration)
            self.averagePace = pace
            
            // Calculate splits and find best pace
            if let points = route.points {
                let routePoints = Array(points).sorted { $0.order < $1.order }
                
                // Update best pace from segments
                if let bestSegmentPace = findBestPaceSegment(from: routePoints) {
                    self.maxPace = bestSegmentPace
                }
                
                // Calculate elevation changes
                let elevation = calculateElevationChanges(from: routePoints)
                self.elevationGain = elevation.gain
                
                // Store split times for detailed analysis
                let splits = calculateSplits(from: routePoints)
                self.splitTimes = splits.map { "\($0.mile):\($0.pace)" }.joined(separator: ",")
            }
        }
    }
    
    // Helper method to format pace for display
    func formatPace(_ pace: Double) -> String {
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
} 