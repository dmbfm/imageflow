import SwiftUI

public struct NodeBoolInput: View {

    @Binding var value: Bool

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
            // .foregroundStyle(.purple)
            .border(.red)
    }
    .padding(100)
}
