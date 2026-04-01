#if os(iOS)

import Backend
import Helpers
import InspectorFeatureShared
import Logging
import SharedModels
import SwiftUI

struct IntegerInputControl: View {
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel

    var body: some View {
        switch input.semantics {
        case .integer(.picker(let options)):
            PickerIntegerInputControl(input: self.input, vm: self.vm, options: options)
        default:
            RegularIntegerInputControl(input: self.input, vm: self.vm)
        }
    }
}

struct PickerIntegerInputControl: View {
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel
    let options: [ValueSemantics.IntegerSemantics.PickerOption]

    var value: Int {
        self.vm.nodeInputValue(self.input.index)?.maybeInt ?? 0
    }

    var binding: Binding<Int> {
        .init(
            get: {
                self.value
            },
            set: { newValue in
                self.vm.submit(.input(self.input.index, .int(newValue), nil), registerUndo: true)
            }
        )
    }

    var body: some View {
        LabeledContent {
            Picker("", selection: self.binding) {
                ForEach(self.options, id: \.value) { option in
                    Text(option.label ?? "\(option.value)").tag(option.value)
                }
            }
        } label: {
            InputLabel(input: self.input, vm: self.vm)
        }
    }

}

struct RegularIntegerInputControl: View {
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel

    @State var debouncer: FirstValueDebouncer<Int> = .init(0.5)
    @State var dragState: DragState = .notDragging

    var value: Int {
        self.vm.nodeInputValue(self.input.index)?.maybeInt ?? 0
    }

    static var formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f
    }()

    func onChange(_ change: DraggableFloatInput.Change) {
        self.vm.submit(
            .input(
                self.input.index,
                .int(Int(change.value.rounded())),
                change.previous.map({ .int(Int($0.rounded())) })
            ),
            registerUndo: change.commit
        )
    }

    var body: some View {
        LabeledContent {
            HStack {
                DraggableFloatInput(value: Double(self.value), fractionalDigits: 0, onChange: self.onChange(_:))
                    .draggableFloatInputFormatter(Self.formatter)
                Stepper(
                    "",
                    value: .init(
                        get: {
                            self.value
                        },
                        set: { value in
                            self.debouncer.debounce(value: self.value) { oldValue in
                                log("submitting:oldValue:\(oldValue)newValue:\(value)...")
                                self.vm.submit(
                                    .input(self.input.index, .int(value), .int(oldValue)),
                                    registerUndo: true
                                )
                            }
                            self.vm.submit(.input(self.input.index, .int(value), nil), registerUndo: false)
                        }
                    )
                )
                .fixedSize()
            }
        } label: {
            InputLabel(input: self.input, vm: self.vm)
        }
        .dragStateStatusBarMessage(coordinator: self.vm.coordinator, dragState: self.dragState, message: StatusBarMessage.dragFloat.rawValue)
    }
}

#Preview("Int Value Node") {
    InspectorFeatureView.Preview(nodes: [
        .init(kind: .valueNode(.int))
    ])
}

#Preview("Person Segmentation Node") {
    InspectorFeatureView.Preview(nodes: [
        .init(kind: .coreImageCustomNode(.segmentation(.personSegmentation)))
    ])
}

#endif
