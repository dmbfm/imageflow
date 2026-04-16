import Controls
import Design
import Helpers
import Logging
import SharedModels
import SwiftUI
import TextInput
import Values

struct TextInputView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    @FocusState var focused

    var value: String {
        self.vm.nodeInputValue(self.input.index)?.maybeString ?? ""
    }

    var body: some View {
        Block {
            HStack(spacing: 0) {
                NodeInputPropertyTitleView(vm: self.vm, input: self.input)
                Spacer()
                TextInput::TextInputView(
                    self.value,
                    placeholder: "Enter text here...",
                    behaviours: [.cancelAbort, .submitUnfocus],
                    onChangeAction: { change in
                        if change.commit {
                            self.vm.submit(
                                .input(
                                    self.input.index,
                                    .string(change.newValue),
                                    change.oldValue.map({ .string($0) })
                                ),
                                registerUndo: change.commit
                            )
                        }
                    },
                    cancelAction: {},
                    dragAction: { _ in }
                )
                .textInputStyle(.inspector)
            }
        }
    }
}

#Preview {
    InspectorFeatureView.Preview([.init(kind: .valueNode(.string))])
        .frame(width: 600, height: 500)
}
