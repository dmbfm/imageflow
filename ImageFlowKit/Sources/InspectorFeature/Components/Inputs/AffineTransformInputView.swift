import Controls
import Design
import Helpers
import Logging
import SharedModels
import SwiftUI
import Values

struct AffineTransforminputView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    // var value: Binding<Bool> {
    //     .init(
    //         get: {
    //             self.vm.nodeInputValue(self.input.index)?.maybeBool ?? false
    //         },
    //         set: { newValue in
    //             self.vm.submit(.input(self.input.index, .bool(newValue), nil), registerUndo: true)
    //         }
    //     )
    // }

    var body: some View {
        Block {
            HStack(spacing: 0) {
                NodeInputPropertyTitleView(vm: self.vm, input: self.input)
            }
        }
    }
}

#Preview {
    InspectorFeatureView.Preview([.init(kind: .coreImageFilterNode(.tileEffect(.CIAffineClamp)))])
        .frame(width: 600, height: 500)
}
