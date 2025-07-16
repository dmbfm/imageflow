import Design
import SwiftUI

public struct NodeStringInput: View, @preconcurrency Equatable {
    public static func == (lhs: NodeStringInput, rhs: NodeStringInput) -> Bool {
        lhs.value == rhs.value
    }

    @Binding var value: String

    public var body: some View {
        TextField("", text: self.$value)
            .nodeTextField()
    }
}

#Preview {
    @Previewable @State var value: String = "Hello World!"
    VStack {
        NodeStringInput(value: $value)
    }
    .padding(80)
}
