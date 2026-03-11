import Controls
import Logging
import SharedModels
import SwiftUI
import Values
import InspectorFeatureShared

struct ColorControlView: View {

    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var color: Color4 {
        input.value.maybeColor4 ?? .black
    }

    var binding: Binding<Color4> {
        .init(
            get: {
                self.vm.nodeInputValue(input.index)?.maybeColor4 ?? .black
            },
            set: { color in
                if color != self.binding.wrappedValue {
                    self.vm.submit(.input(input.index, .color4(color), nil), registerUndo: true)
                }
            }
        )
    }

    var body: some View {
        ColorPickerView(color: self.binding)
    }
}
