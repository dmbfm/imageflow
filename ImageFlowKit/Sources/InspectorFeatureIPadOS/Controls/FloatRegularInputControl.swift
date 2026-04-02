#if os(iOS)

import SwiftUI
import SharedModels
import InspectorFeatureShared
import Logging
import Helpers

struct FloatRegularInputControl: View {
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel
    @Binding var dragState: DragState

    var value: Double {
        self.vm.nodeInputValue(self.input.index)?.maybeFloat ?? 0.0
    }

    var body: some View {
        DraggableFloatInput(value: self.value, fractionalDigits: 2, dragState: self.$dragState) { change in
            self.vm.submit(
                .input(self.input.index, .float(change.value), change.previous.map({ .float($0) })),
                registerUndo: change.commit
            )
        }
        .disabled(self.input.connected)
    }
}

#endif
