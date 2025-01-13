import Foundation
import CoreLocation
import CoreData
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private let context: NSManagedObjectContext
    private let progressService: ProgressCalculationService
    
    @Published var location: CLLocation?
    @Published var isTracking = false
    @Published var error: Error?
    @Published var currentRoute: Route?
    @Published var currentDistance: Double = 0
    @Published var isPaused = false
    @Published private(set) var totalPausedDuration: TimeInterval = 0
    
    private var pauseStartTime: Date?
    
    var lastPauseTime: Date? {
        pauseStartTime
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }
    
    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    override private init() {
        self.context = PersistenceController.shared.container.viewContext
        self.progressService = ProgressCalculationService.shared
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10 // Update every 10 meters
        requestPermission()
    }
    
    func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startTracking() {
        // Create a new route
        let route = Route.create(in: context)
        currentRoute = route
        currentDistance = 0
        totalPausedDuration = 0
        pauseStartTime = nil
        
        do {
            try context.save()
            locationManager.startUpdatingLocation()
            isTracking = true
        } catch {
            self.error = error
        }
    }
    
    func stopTracking() {
        isTracking = false
        isPaused = false
        
        if let route = currentRoute {
            route.endTime = Date().addingTimeInterval(-totalPausedDuration)
            
            // Update progress when route is completed
            progressService.updateCardioProgress(for: route)
            
            try? context.save()
        }
        
        // Reset state
        totalPausedDuration = 0
        pauseStartTime = nil
        currentRoute = nil
    }
    
    func pauseTracking() {
        isPaused = true
        pauseStartTime = Date()
        // Keep locationManager running but don't add points to route
    }
    
    func resumeTracking() {
        if let pauseStart = pauseStartTime {
            totalPausedDuration += Date().timeIntervalSince(pauseStart)
        }
        isPaused = false
        pauseStartTime = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking, !isPaused, let location = locations.last else { return }
        
        if currentRoute == nil {
            currentRoute = Route(context: context)
            currentRoute?.id = UUID()
            currentRoute?.startTime = Date()
        }
        
        // Add new point
        let point = RoutePoint(context: context)
        point.id = UUID()
        point.timestamp = Date()
        point.latitude = location.coordinate.latitude
        point.longitude = location.coordinate.longitude
        point.route = currentRoute
        
        // Update distance
        if let points = currentRoute?.points as? Set<RoutePoint>,
           let lastPoint = points.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }).last {
            let lastLocation = CLLocation(latitude: lastPoint.latitude, longitude: lastPoint.longitude)
            currentDistance += location.distance(from: lastLocation) / 1000 // Convert to km
        }
        
        try? context.save()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted")
            if isTracking {
                startTracking()
            }
        case .denied, .restricted:
            self.error = NSError(domain: "LocationError",
                               code: 1,
                               userInfo: [NSLocalizedDescriptionKey: "Location access denied"])
            stopTracking()
        case .notDetermined:
            print("Location status not determined")
        @unknown default:
            break
        }
    }
}
