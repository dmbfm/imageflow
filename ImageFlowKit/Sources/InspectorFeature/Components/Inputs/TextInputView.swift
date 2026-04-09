import Controls
import Design
import Helpers
import Logging
import SharedModels
import SwiftUI
import Values

struct TextInputView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    @FocusState var focused

    var value: Binding<String> {
        .init(
            get: {
                self.vm.nodeInputValue(self.input.index)?.maybeString ?? ""
            },
            set: { newValue in
                if newValue != self.value.wrappedValue {
                    self.vm.submit(.input(self.input.index, .string(newValue), nil), registerUndo: true)
                }
            }
        )
    }

    var body: some View {
        Block {
            HStack(spacing: 0) {
                NodeInputPropertyTitleView(vm: self.vm, input: self.input)
                Spacer()
                BetterTextField(text: self.value)
                    .betterTextFieldInteractionMode(.commit)
                    .betterTextFieldDidEndEditing({ value in
                        self.value.wrappedValue = value
                        self.focused = false
                    })
                    .betterTextFieldPlaceholder("Enter text...")
                    .betterTextFieldBorderShapeStyle(.secondaryFill)
                    .focused(self.$focused)
            }
        }
    }
}

#Preview {
    InspectorFeatureView.Preview([.init(kind: .valueNode(.string))])
        .frame(width: 600, height: 500)
}
