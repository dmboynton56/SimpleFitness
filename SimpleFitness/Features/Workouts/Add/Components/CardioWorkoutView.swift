import SwiftUI
import CoreLocation
import Combine

struct CardioWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    @StateObject private var locationManager = LocationManager.shared
    @State private var workoutName = ""
    @State private var showingPermissionAlert = false
    @State private var workoutState: WorkoutState = .ready
    @State private var distanceUnit: DistanceUnit = .kilometers // Default to km
    
    var onSave: (Workout) -> Void
    
    private enum WorkoutState {
        case ready
        case tracking
        case paused
        case completed
    }
    
    private enum DistanceUnit: String, CaseIterable {
        case kilometers = "km"
        case miles = "mi"
        
        func convert(_ distanceInKm: Double) -> Double {
            switch self {
            case .kilometers: return distanceInKm
            case .miles: return distanceInKm * 0.621371
            }
        }
    }
    
    private var activeDuration: TimeInterval {
        guard let startTime = locationManager.currentRoute?.startTime else { return 0 }
        let endTime = locationManager.isPaused ? (locationManager.lastPauseTime ?? Date()) : Date()
        return endTime.timeIntervalSince(startTime) - locationManager.totalPausedDuration
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Map takes up most of the space
                RouteMapView(route: locationManager.currentRoute)
                    .frame(maxHeight: .infinity)
                
                // Stats overlay
                if workoutState != .ready {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Distance", systemImage: "figure.run")
                            Spacer()
                            Text(String(format: "%.2f %@", 
                                distanceUnit.convert(locationManager.currentDistance),
                                distanceUnit.rawValue))
                            Button {
                                distanceUnit = distanceUnit == .kilometers ? .miles : .kilometers
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }
                        }
                        
                        HStack {
                            Label("Duration", systemImage: "clock")
                            Spacer()
                            if workoutState == .tracking {
                                TimelineView(.periodic(from: .now, by: 1.0)) { _ in
                                    Text(DateComponentsFormatter.timeFormatter.string(from: activeDuration) ?? "0:00")
                                }
                            } else {
                                Text(DateComponentsFormatter.timeFormatter.string(from: activeDuration) ?? "0:00")
                            }
                        }
                        
                        if workoutState == .completed {
                            TextField("Workout Name", text: $workoutName)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
                
                // Controls
                HStack {
                    switch workoutState {
                    case .ready:
                        Button {
                            startTracking()
                        } label: {
                            Text("Start Tracking")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        
                    case .tracking:
                        Button {
                            pauseTracking()
                        } label: {
                            Text("Pause")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(role: .destructive) {
                            stopTracking()
                        } label: {
                            Text("Stop")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                    case .paused:
                        Button {
                            resumeTracking()
                        } label: {
                            Text("Resume")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button(role: .destructive) {
                            stopTracking()
                        } label: {
                            Text("Stop")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                    case .completed:
                        Button(role: .destructive) {
                            locationManager.stopTracking()
                            workoutState = .ready
                        } label: {
                            Text("Discard")
                        }
                        .buttonStyle(.bordered)
                        
                        Button {
                            saveWorkout()
                        } label: {
                            Text("Save Workout")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
            .navigationTitle("Cardio Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Location Permission Required", isPresented: $showingPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable location access to track your route.")
            }
        }
    }
    
    private func startTracking() {
        guard locationManager.isAuthorized else {
            showingPermissionAlert = true
            return
        }
        
        locationManager.startTracking()
        workoutState = .tracking
    }
    
    private func stopTracking() {
        locationManager.stopTracking()
        workoutState = .completed
    }
    
    private func pauseTracking() {
        locationManager.pauseTracking()
        workoutState = .paused
    }
    
    private func resumeTracking() {
        locationManager.resumeTracking()
        workoutState = .tracking
    }
    
    private func saveWorkout() {
        guard let route = locationManager.currentRoute else {
            print("No route found to save")
            return
        }
        
        print("Found route to save")
        
        let workout = Workout(context: context)
        workout.id = UUID()
        workout.type = "Running" // TODO: Make this dynamic based on selection
        workout.name = workoutName.isEmpty ? nil : workoutName
        workout.date = Date()
        workout.duration = activeDuration
        workout.distance = locationManager.currentDistance
        workout.route = route
        
        print("Created workout with duration: \(workout.duration), distance: \(workout.distance)")
        
        do {
            try context.save()
            print("Successfully saved workout to CoreData")
            onSave(workout)
            print("Called onSave callback")
            DispatchQueue.main.async {
                dismiss()
                print("Called dismiss on main thread")
            }
        } catch {
            print("Error saving workout: \(error)")
        }
    }
}

// Add time formatter
private extension DateComponentsFormatter {
    static let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        return formatter
    }()
}

#Preview {
    CardioWorkoutView { _ in }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 