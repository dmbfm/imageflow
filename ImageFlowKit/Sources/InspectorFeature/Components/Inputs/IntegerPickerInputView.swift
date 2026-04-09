import Backend
import Controls
import Design
import Helpers
import Logging
import SharedModels
import SwiftUI
import Values

struct IntegerPickerInputView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input
    let options: [ValueSemantics.IntegerSemantics.PickerOption]

    var value: Binding<Int> {
        .init {
            self.vm.nodeInputValue(self.input.index)?.maybeInt ?? 0
        } set: { newValue in
            self.vm.submit(.input(self.input.index, .int(newValue), nil), registerUndo: true)
        }
    }

    var body: some View {
        Block {
            HStack {
                NodeInputPropertyTitleView(vm: self.vm, input: self.input)
                Spacer()
                Picker("", selection: self.value) {
                    ForEach(self.options, id: \.value) { option in
                        Text(option.label ?? "\(option.value)").tag(option.value)
                    }
                }
                .controlSize(.small)
            }
        }
    }
}
