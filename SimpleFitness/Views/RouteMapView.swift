import SwiftUI
import MapKit

struct RouteMapView: View {
    let route: Route?
    @StateObject private var locationManager = LocationManager.shared
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var mapRect: MKMapRect?
    
    var body: some View {
        Map {
            // Show user location when tracking
            if locationManager.isTracking {
                UserAnnotation()
            }
            
            // Draw the route polyline
            if let route = route ?? locationManager.currentRoute,
               let points = route.points,
               !points.isEmpty {
                MapPolyline(coordinates: route.pointsArray.map { point in
                    CLLocationCoordinate2D(latitude: point.latitude,
                                         longitude: point.longitude)
                })
                .stroke(.blue, lineWidth: 4)
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .onAppear {
            updateMapRegion()
        }
        .onChange(of: locationManager.location) { _, _ in
            if locationManager.isTracking {
                updateMapRegion()
            }
        }
    }
    
    private func updateMapRegion() {
        // If we have a saved route, show its bounds
        if let route = route,
           let points = route.points,
           !points.isEmpty {
            let coordinates = route.pointsArray.map { point in
                CLLocationCoordinate2D(latitude: point.latitude,
                                     longitude: point.longitude)
            }
            
            var rect = MKMapRect.null
            for coordinate in coordinates {
                let point = MKMapPoint(coordinate)
                let pointRect = MKMapRect(x: point.x, y: point.y, width: 0, height: 0)
                rect = rect.union(pointRect)
            }
            
            // Add some padding
            rect = rect.insetBy(dx: -rect.width * 0.2, dy: -rect.height * 0.2)
            mapRect = rect
            
        // Otherwise, center on user's current location
        } else if let location = locationManager.location {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        }
    }
}

#Preview {
    RouteMapView(route: nil)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 