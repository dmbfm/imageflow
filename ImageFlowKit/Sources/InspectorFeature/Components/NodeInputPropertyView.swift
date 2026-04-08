import SharedModels
import SwiftUI

struct NodeInputPropertyView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var body: some View {
        switch input.value.type {
        case .float:
            FloatInputView(vm: self.vm, input: input)
        case .vector2, .vector3, .vector4:
            VectorInputView(vm: self.vm, input: input)
        default:
            Block {
                HStack {
//                    NodeInputPropertyTitleView(name: input.label, connected: false)
//                    Spacer()
//                    Text("TODO: \(input.value.type.displayName)")
                }
            }
        }
    }
}
