import SwiftUI

struct ProgressView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Progress Type", selection: $selectedTab) {
                    Text("Strength").tag(0)
                    Text("Cardio").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                TabView(selection: $selectedTab) {
                    StrengthProgressView()
                        .tag(0)
                    
                    Text("Cardio Progress Coming Soon")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Progress")
        }
    }
}

#Preview {
    ProgressView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 