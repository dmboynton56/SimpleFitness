import SwiftUI

struct CardioWorkoutForm: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var showingActiveWorkout = false
    
    var body: some View {
        VStack {
            // Notes section
            Section(header: Text("Notes")) {
                TextEditor(text: .constant(""))
                    .frame(minHeight: 100)
            }
            
            Button("Start Workout") {
                showingActiveWorkout = true
            }
            .sheet(isPresented: $showingActiveWorkout) {
                ActiveWorkoutView()
            }
        }
    }
}

#Preview {
    CardioWorkoutForm()
} 