import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var isTracking = false
    @Published var error: Error?
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .fitness
        locationManager.distanceFilter = kCLDistanceFilterNone
        requestPermission()
    }
    
    func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
        isTracking = true
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        isTracking = false
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
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
