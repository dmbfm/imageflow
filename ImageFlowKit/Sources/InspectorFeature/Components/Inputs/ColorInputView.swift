import Controls
import Design
import Helpers
import Logging
import SharedModels
import SwiftUI
import Values

struct ColorInputView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var value: Binding<Color4> {
        .init(
            get: {
                self.vm.nodeInputValue(self.input.index)?.maybeColor4 ?? .black
            },
            set: { newValue in
                if newValue != self.value.wrappedValue {
                    self.vm.submit(.input(self.input.index, .color4(newValue), nil), registerUndo: true)
                }
            }
        )
    }

    var body: some View {
        Block {
            VStack(alignment: .leading) {
                NodeInputPropertyTitleView(vm: self.vm, input: self.input)
                HStack(spacing: 0) {
                    ColorPickerView(color: self.value)
                }
            }
        }
    }
}

#Preview {
    InspectorFeatureView.Preview([.init(kind: .valueNode(.color4))])
        .frame(width: 600, height: 500)
}
