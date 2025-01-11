import SwiftUI

struct WorkoutTypeSelectionView: View {
    @Binding var selectedType: WorkoutType?
    
    var body: some View {
        List(WorkoutType.allCases, id: \.self) { type in
            Button(action: {
                selectedType = type
            }) {
                HStack {
                    Text(type.rawValue)
                    Spacer()
                    if selectedType == type {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
            .foregroundColor(.primary)
        }
    }
}

struct WorkoutTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutTypeSelectionView(selectedType: .constant(.strength))
    }
} 