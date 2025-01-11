import SwiftUI
import CoreLocation

struct ActiveWorkoutView: View {
    @ObservedObject var viewModel: AddWorkoutViewModel
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
                if let distance = viewModel.activeDistance {
                    Text(String(format: "%.2f miles", distance))
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
                        // Transfer the elapsed time to the view model
                        viewModel.hours = elapsedSeconds / 3600
                        viewModel.minutes = (elapsedSeconds % 3600) / 60
                        viewModel.seconds = elapsedSeconds % 60
                        if let distance = viewModel.activeDistance {
                            viewModel.distance = String(format: "%.2f", distance)
                        }
                        dismiss()
                    }
                    .padding()
                }
            }
            .navigationTitle("\(viewModel.workoutType?.rawValue ?? "") Workout")
            .navigationBarItems(leading: Button("Cancel") {
                stopWorkout()
                dismiss()
            })
        }
    }
    
    private func startWorkout() {
        viewModel.startLocationTracking()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }
    
    private func stopWorkout() {
        timer?.invalidate()
        timer = nil
        viewModel.stopLocationTracking()
    }
    
    private func timeString(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct ActiveWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveWorkoutView(viewModel: AddWorkoutViewModel())
    }
} 