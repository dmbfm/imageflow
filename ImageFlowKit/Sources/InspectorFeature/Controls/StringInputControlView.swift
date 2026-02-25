import Logging
import SharedModels
import SwiftUI

struct StringInputControlView: View {

    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var binding: Binding<String> {
        .init(
            get: {
                self.vm.nodeInputValue(self.input.index)?.maybeString ?? ""
            },
            set: { newValue in
                self.vm.submit(
                    .input(self.input.index, .string(newValue), self.initial.map({ .string($0) })),
                    registerUndo: true
                )
            }
        )
    }

    @State var initial: String?

    var body: some View {
        TextFieldEx(text: self.binding)
            .textFieldExInteractionMode(.commit)
            .textFieldExPlaceholder("Insert text...")
            .textFieldExDidEndEditing {
                self.initial = nil
            }
            .textFieldExDidBeginEditing {
                self.initial = self.input.value.maybeString
            }
    }
}
