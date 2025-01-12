import SwiftUI

struct NumberField: View {
    let label: String
    @Binding var value: String
    let range: ClosedRange<Double>
    let onUpdate: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField(label, text: $value)
            .keyboardType(.decimalPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($isFocused)
            .onChange(of: value) { oldValue, newValue in
                if let number = Double(newValue), range.contains(number) {
                    onUpdate()
                }
            }
    }
} 