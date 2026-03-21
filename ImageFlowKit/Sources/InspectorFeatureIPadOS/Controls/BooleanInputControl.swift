#if os(iOS)

import InspectorFeatureShared
import SharedModels
import SwiftUI

struct BooleanInputControl: View {

    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel

    var binding: Binding<Bool> {
        .init(
            get: {
                self.vm.nodeInputValue(input.index)?.maybeBool ?? false
            },
            set: { newValue in
                self.vm.submit(.input(input.index, .bool(newValue), nil), registerUndo: true)
            }
        )
    }

    var body: some View {
        LabeledContent {
            Toggle("", isOn: self.binding)
        } label: {
            InputLabel(input: self.input, vm: self.vm)
        }
    }
}

#Preview {
    InspectorFeatureView.Preview(nodes: [.init(kind: .valueNode(.bool))])
}

#endif
