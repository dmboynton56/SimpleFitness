import SwiftUI

struct CardioWorkoutForm: View {
    @ObservedObject var viewModel: AddWorkoutViewModel
    @State private var showingActiveWorkout = false
    
    var body: some View {
        Form {
            Section {
                Button(action: {
                    viewModel.isActiveWorkout = true
                    showingActiveWorkout = true
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.green)
                        Text("Start \(viewModel.workoutType?.rawValue ?? "") Workout")
                    }
                }
            }
            
            Section(header: Text("Manual Entry")) {
                HStack {
                    Text("Duration")
                    Spacer()
                    DurationPicker(hours: $viewModel.hours, minutes: $viewModel.minutes, seconds: $viewModel.seconds)
                }
                
                HStack {
                    Text("Distance (miles)")
                    Spacer()
                    TextField("0.0", text: $viewModel.distance)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
            }
            
            Section(header: Text("Notes")) {
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 100)
            }
        }
        .sheet(isPresented: $showingActiveWorkout) {
            if viewModel.isActiveWorkout {
                ActiveWorkoutView(viewModel: viewModel)
            }
        }
    }
}

struct DurationPicker: View {
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int
    
    var body: some View {
        HStack {
            Picker("Hours", selection: $hours) {
                ForEach(0..<24) { hour in
                    Text("\(hour)h").tag(hour)
                }
            }
            .frame(width: 70)
            .clipped()
            
            Picker("Minutes", selection: $minutes) {
                ForEach(0..<60) { minute in
                    Text("\(minute)m").tag(minute)
                }
            }
            .frame(width: 70)
            .clipped()
            
            Picker("Seconds", selection: $seconds) {
                ForEach(0..<60) { second in
                    Text("\(second)s").tag(second)
                }
            }
            .frame(width: 70)
            .clipped()
        }
    }
} 