import SwiftUI

struct ProgressView: View {
    @State private var selectedSection = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Progress Type", selection: $selectedSection) {
                    Text("Strength").tag(0)
                    Text("Cardio").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedSection == 0 {
                    StrengthProgressView()
                } else {
                    CardioProgressView()
                }
            }
            .navigationTitle("Progress")
        }
    }
}

// Temporary placeholder views until we implement them fully
private struct StrengthProgressView: View {
    var body: some View {
        List {
            Text("Strength Progress Coming Soon")
                .foregroundStyle(.secondary)
        }
    }
}

private struct CardioProgressView: View {
    var body: some View {
        List {
            Text("Cardio Progress Coming Soon")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ProgressView()
} 