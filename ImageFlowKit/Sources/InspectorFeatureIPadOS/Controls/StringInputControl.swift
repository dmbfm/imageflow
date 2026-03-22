#if os(iOS)

import Helpers
import InspectorFeatureShared
import Logging
import SharedModels
import SwiftUI

struct StringInputControl: View {
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel

    var value: String {
        self.vm.nodeInputValue(self.input.index)?.maybeString ?? ""
    }

    var binding: Binding<String> {
        .init(
            get: {
                self.value
            },
            set: { _ in }
        )
    }

    var body: some View {
        LabeledContent {
            TextFieldEx(text: self.binding)
                .textFieldExPlaceholder("Enter text...")
                .textFieldExDidEndEditing { newValue in
                    self.vm.submit(.input(self.input.index, .string(newValue), .string(self.value)), registerUndo: true)
                }
                .textFieldExUpdatesBinding(false)
        } label: {
            InputLabel(input: self.input, vm: self.vm)
        }
    }
}

#Preview {
    InspectorFeatureView.Preview(nodes: [
        .init(kind: .valueNode(.string))
    ])
}

#endif
