import SharedModels
import SwiftUI

struct NodeInputPropertyView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var body: some View {
        Group {
            switch input.value.type {
            case .float:
                FloatInputView(vm: self.vm, input: input)
            case .int:
                switch input.semantics {
                case .integer(.picker(let options)):
                    IntegerPickerInputView(vm: self.vm, input: input, options: options)
                default:
                    IntegerInputView(vm: self.vm, input: input)
                }
            case .vector2, .vector3, .vector4:
                VectorInputView(vm: self.vm, input: input)
            case .image, .lut:
                AssetInputView(vm: self.vm, input: input)
            case .bool:
                BoolInputView(vm: self.vm, input: input)
            case .color4:
                ColorInputView(vm: self.vm, input: input)
            default:
                Block {
                    HStack {
                    }
                }
            }
        }
        .disabled(self.input.connected)
    }
}
