import InspectorFeatureShared
import SharedModels
import SwiftUI

struct BoolInputControlView: View {

    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    // var binding

    var binding: Binding<Bool> {
        .init(
            get: {
                self.vm.nodeInputValueBinding(self.input.index).wrappedValue?.maybeBool ?? false
            },
            set: { newValue in
                self.vm.submit(.input(self.input.index, .bool(newValue), nil), registerUndo: true)
            }
        )
    }

    var body: some View {
        BoolInputView(isOn: self.binding)
    }
}
