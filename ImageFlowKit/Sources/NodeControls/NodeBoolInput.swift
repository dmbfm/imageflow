import SwiftUI

public struct NodeBoolInput: View {
    @Binding var value: Bool

    init(value: Binding<Bool>) {
        self._value = value
    }

    public var body: some View {
        Toggle("", isOn: self.$value)
            .toggleStyle(.switch)
            .frame(height: 25)
            .fixedSize()
    }
}

#Preview {
    @Previewable @State var value: Bool = false
    VStack {
        NodeBoolInput(value: $value)
            .tint(.purple)
            .border(.red)
    }
    .padding(100)
}
