import Controls
import Design
import Helpers
import Logging
import SharedModels
import SwiftUI
import Values

struct IntegerInputView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    @State private var debouncer: FirstValueDebouncer<Value> = .init(0.5)
    @State var valueAtStepperStart: Int = 0

    var value: Int {
        self.vm.nodeInputValue(self.input.index)?.maybeInt ?? 0
    }

    var numberInputConfiguration: NumberInputView.Configuration {
        .free(
            .init(
                sensitivity: .init(),
                snapping: .init(increments: 1.0, epsilon: 1.0, enabled: true, modifier: nil),
                dragMaxDigits: 0
            )
        )
    }

    func onChange(_ change: NumberInputView.Change) {
        self.setValue(
            newValue: Int(change.newValue),
            oldValue: change.oldValue.map({ Int($0) }),
            commit: change.commit
        )
    }

    func inc() {
        self.setValue(newValue: self.value + 1, oldValue: nil, commit: false)
    }

    func dec() {
        self.setValue(newValue: self.value - 1, oldValue: nil, commit: false)
    }

    func setValue(newValue: Int, oldValue: Int?, commit: Bool) {
        self.vm.submit(
            .input(
                self.input.index,
                .int(Int(newValue)),
                oldValue.map({ .int(Int($0)) })
            ),
            registerUndo: commit
        )
    }

    func stepperEditingChanged(_ state: Bool) {
        if state {
            self.valueAtStepperStart = self.value
        } else {
            self.setValue(newValue: self.value, oldValue: self.valueAtStepperStart, commit: true)
        }
    }

    var body: some View {
        Block {
            VStack(alignment: .leading) {
                NodeInputPropertyTitleView(vm: self.vm, input: self.input)
                HStack(spacing: 0) {
                    NumberInputView(
                        value: Double(self.value),
                        configuration: self.numberInputConfiguration,
                        formatting: .integer,
                        onChange: self.onChange(_:),
                        onDragStateChange: { _ in }
                    )
                    .inspectorNumberInput()
                    Stepper(
                        "",
                        onIncrement: self.inc,
                        onDecrement: self.dec,
                        onEditingChanged: self.stepperEditingChanged(_:)
                    )
                }
            }
        }
    }
}
