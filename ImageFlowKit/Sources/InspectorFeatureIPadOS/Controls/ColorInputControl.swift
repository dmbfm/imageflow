#if os(iOS)

import SwiftUI
import Controls
import SharedModels
import InspectorFeatureShared
import Values
import Logging

struct ColorInputControl: View {

    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel

    var binding: Binding<Color4> {
        .init(
            get: {
                self.vm.nodeInputValue(self.input.index)?.maybeColor4 ?? .black
            },
            set: { newValue in
                self.vm.submit(.input(self.input.index, .color4(newValue), nil), registerUndo: false)
            }
        )
    }

    func onCommit(_ value: Color4, _ oldValue: Color4?) {
        self.vm.submit(.input(self.input.index, .color4(value), oldValue.map({ .color4($0) })), registerUndo: true)
    }

    var body: some View {
        LabeledContent {
            HStack {
                ColorPickerView(color: self.binding, onCommit: self.onCommit(_:_:))
                //                    .frame(width: 44)
            }
        } label: {
            InputLabel(input: self.input, vm: self.vm)
        }
    }
}

#Preview {
    InspectorFeatureView.Preview(nodes: [
        .init(kind: .valueNode(.color4))
    ])
}

#endif
