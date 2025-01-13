import SwiftUI
import CoreLocation

struct ActiveWorkoutView: View {
    @ObservedObject var locationManager = LocationManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var elapsedSeconds: Int = 0
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            VStack {
                // Timer Display
                Text(timeString(from: elapsedSeconds))
                    .font(.system(size: 54, weight: .bold, design: .monospaced))
                    .padding()
                
                // Distance (if available)
                if locationManager.isTracking {
                    Text(String(format: "%.2f miles", locationManager.currentDistance))
                        .font(.title2)
                        .padding()
                }
                
                // Start/Stop Button
                Button(action: {
                    if timer == nil {
                        startWorkout()
                    } else {
                        stopWorkout()
                    }
                }) {
                    Text(timer == nil ? "Start" : "Stop")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 60)
                        .background(timer == nil ? Color.green : Color.red)
                        .cornerRadius(10)
                }
                
                if timer != nil {
                    Button("End Workout") {
                        stopWorkout()
                    }
                }
            }
        }
    }
    
    private func startWorkout() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
        }
        locationManager.startTracking()
    }
    
    private func stopWorkout() {
        timer?.invalidate()
        timer = nil
        locationManager.stopTracking()
        // Transfer the elapsed time to the view model
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
    }
    
    private func timeString(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    ActiveWorkoutView()
} 