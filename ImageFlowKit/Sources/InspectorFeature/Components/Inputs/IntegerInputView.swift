import Controls
import Design
import Helpers
import Logging
import SharedModels
import SwiftUI
import TextInput
import Values

struct IntegerInputView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    @State private var debouncer: FirstValueDebouncer<Value> = .init(0.5)
    @State var valueAtStepperStart: Int = 0

    var range: ClosedRange<Int>? {
        if case let .integer(.range(range)) = self.input.semantics {
            range
        } else {
            nil
        }
    }

    var minValue: Int? {
        if case let .integer(.partialRangeFrom(minValue)) = self.input.semantics {
            minValue
        } else {
            nil
        }
    }

    var doubleRange: ClosedRange<Double>? {
        self.range.map({ Double($0.lowerBound)...Double($0.upperBound) })
    }

    var value: Int {
        self.vm.nodeInputValue(self.input.index)?.maybeInt ?? 0
    }

    func onChange(_ change: NumberInputController.Change) {
        self.setValue(
            newValue: Int(change.newValue),
            oldValue: Int(change.oldValue),
            commit: change.commit
        )
    }

    func inc() {
        self.setValue(newValue: self.transform(value: self.value + 1), oldValue: nil, commit: false)
    }

    func dec() {
        self.setValue(newValue: self.transform(value: self.value - 1), oldValue: nil, commit: false)
    }

    func transform(value: Int) -> Int {
        switch input.semantics {
        case .integer(.range(let range)): value.clamped(to: range)
        case .integer(.partialRangeFrom(let minValue)): value.clamped(to: minValue...)
        default: value
        }
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

    @State private var isDragging: Bool = false

    var dragConfiguration: NumberInputController.DragConfiguration {
        if let range = self.range {
            return .range(
                .closed(
                    .init(
                        range: .init(uncheckedBounds: (Double(range.lowerBound), Double(range.upperBound))),
                        sensitivity: .init(slow: 0.1, modifier: .shift),
                        snap: .init(increments: 1.0),
                        fractionalDigits: 0
                    )
                )
            )
        } else if let lowerBound = self.minValue {
            return .range(
                .partialFrom(
                    .init(
                        lowerBound: Double(lowerBound),
                        sensitivity: .init(shiftDown: 0.1),
                        fractionalDigits: 0
                    )
                )
            )
        } else {
            return .free(
                .init(
                    sensitivity: .init(shiftDown: 0.1),
                    fractionalDigits: 0
                )
            )
        }
    }

    var statusMessage: [StatusBarMessageBuilder.Item] {
        [
            .dragSlower,
            self.range == nil ? .dragFaster : .empty,
        ]
    }

    var body: some View {
        Block {
            VStack(alignment: .leading) {
                NodeInputPropertyTitleView(vm: self.vm, input: self.input)
                HStack(spacing: 0) {
                    NumberTextInputView(
                        Double(self.value),
                        isDragging: self.$isDragging,
                        dragConfiguration: self.dragConfiguration,
                        onChange: self.onChange(_:)
                    )
                    .textInputStyle(.inspector)
                    Stepper(
                        "",
                        onIncrement: self.inc,
                        onDecrement: self.dec,
                        onEditingChanged: self.stepperEditingChanged(_:)
                    )
                }
            }
        }
        .dragStatusBarMessage(self.$isDragging, message: self.statusMessage, coordinator: self.vm.coordinator)
    }
}
