import Controls
import Design
import Helpers
import Logging
import SharedModels
import SwiftUI
import TextInput
import Values

struct FloatInputView: View {

    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var body: some View {
        switch input.semantics {
        case .float(.angle(.none)):
            AngleInput(vm: self.vm, input: self.input)
        case .float(.angle(.some(let range))):
            if abs(range.span - 2.0 * .pi) < 0.001 {
                AngleInput(vm: self.vm, input: self.input)
            } else {
                AngleInput(vm: self.vm, input: self.input, range: range)
            }
        case .float(.range(let range)):
            DefaultInput(vm: self.vm, input: self.input, range: range)
        default:
            DefaultInput(vm: self.vm, input: self.input)
        }
    }
}

private struct AngleInput: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input
    var range: ClosedRange<Double>?

    @State private var unit: AngleUnit = .degrees
    @State private var isDragging: Bool = false
    @State var snap: Bool = false

    var effectiveUnit: AngleUnit {
        if self.input.connected {
            .radians
        } else {
            self.unit
        }
    }

    var value: Double {
        self.vm.nodeInputValue(self.input.index)?.maybeFloat ?? 0.0
    }

    var transformedValue: Double {
        self.value.fromRadians(to: self.unit)
    }

    var transformedRange: ClosedRange<Double> {

        let range: ClosedRange<Double> = self.range ?? -.pi...(.pi)

        switch self.unit {
        case .degrees:
            let lower = range.lowerBound.fromRadians(to: .degrees).roundTo(fractionalDigits: 6)
            let upper = range.upperBound.fromRadians(to: .degrees).roundTo(fractionalDigits: 6)
            return lower...upper
        case .radians:
            return range
        }
    }

    func onChange(_ change: NumberInputController.Change) {
        self.vm.submit(
            .input(
                self.input.index,
                .float(change.newValue.toRadians(from: self.unit)),
                .float(change.oldValue.toRadians(from: self.unit))
            ),
            registerUndo: change.commit
        )
    }

    var dragConfiguration: NumberInputController.DragConfiguration {
        .range(
            .closed(
                .init(
                    range: self.transformedRange,
                    sensitivity: .init(),
                    snap: .init(
                        increments: 15,
                        epsilon: 15,
                        alwaysEnabled: self.snap,
                        modifier: .command
                    ),
                    fractionalDigits: self.unit == .degrees ? 1 : 2
                )
            )
        )
    }

    var body: some View {
        Block {
            VStack(alignment: .leading) {
                HStack(spacing: 2) {
                    NodeInputPropertyTitleView(vm: self.vm, input: self.input)
                    Picker("", selection: self.$unit) {
                        Text("Degrees").tag(AngleUnit.degrees)
                        Text("Radians").tag(AngleUnit.radians)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .pickerStyle(.menu)
                    .buttonStyle(.borderless)
                    .controlSize(.small)
                    #if os(iOS)
                    .tint(.secondary)
                    #endif

                    Toggle(isOn: self.$snap) {
                        Image(systemName: "lines.measurement.horizontal.aligned.bottom")
                    }
                    .toggleStyle(.button)
                    .controlSize(.small)
                    #if os(iOS)
                    .tint(.primary)
                    #endif
                }
                HStack {
                    AngleDial(angle: self.value, range: self.range)
                        .angleDialRangeStrokeStyle(.dimmed)
                    NumberTextInputView(
                        self.transformedValue,
                        isDragging: self.$isDragging,
                        dragConfiguration: self.dragConfiguration,
                        onChange: self.onChange(_:),
                    )
                    .textInputStyle(.inspector)
                    .numberTextInputFormatter(.roundingDigits(fractionalDigits: 8))
                }
            }
        }
        .dragStatusBarMessage(
            self.$isDragging,
            message: [.dragSlower, .dragSnap],
            coordinator: self.vm.coordinator
        )
    }
}

private struct DefaultInput: View {

    @State var isDragging: Bool = false

    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input
    var range: ClosedRange<Double>?

    var value: Double {
        self.vm.nodeInputValue(self.input.index)?.maybeFloat ?? 0.0
    }

    func onChange(_ change: NumberInputController.Change) {
        self.vm.submit(
            .input(
                self.input.index,
                .float(change.newValue),
                .float(change.oldValue),
            ),
            registerUndo: change.commit
        )
    }

    var configuration: NumberInputController.DragConfiguration {
        if let range = self.range {
            return .range(.closed(.init(range: range, snap: nil, fractionalDigits: 2)))
        } else {
            return .free(.init(sensitivity: .init(), fractionalDigits: 2))
        }
    }

    var dragStatusMessage: [StatusBarMessageBuilder.Item] {
        [
            .dragSlower,
            self.range == nil ? .dragFaster : .empty,
        ]
    }

    var body: some View {
        Block {
            VStack(alignment: .leading) {
                NodeInputPropertyTitleView(vm: self.vm, input: self.input)
                VStack {
                    NumberTextInputView(
                        self.value,
                        isDragging: self.$isDragging,
                        dragConfiguration: self.configuration,
                        onChange: self.onChange(_:),
                    )
                    .textInputStyle(.inspector)
                }
            }
        }
        .dragStatusBarMessage(self.$isDragging, message: self.dragStatusMessage, coordinator: self.vm.coordinator)
    }
}

#Preview {
    InspectorFeatureView.Preview([.init(kind: .coreImageFilterNode(.geometryAdjustment(.CIPerspectiveRotate)))])
        .frame(width: 600, height: 500)
}
#Preview("Float") {
    InspectorFeatureView.Preview([.init(kind: .valueNode(.float))])
        .frame(width: 600, height: 500)
}
