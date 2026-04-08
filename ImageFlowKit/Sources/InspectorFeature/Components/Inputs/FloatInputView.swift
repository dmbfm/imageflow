import Controls
import Design
import Helpers
import Logging
import SharedModels
import SwiftUI
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

    @State var unit: AngleUnit = .degrees

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

    var transformedRange: ClosedRange<Double>? {

        let range: ClosedRange<Double>? = self.range ?? -.pi...(.pi)

        return switch self.unit {
        case .degrees:
            range.map({ range in
                let lower = range.lowerBound.fromRadians(to: .degrees).roundTo(fractionalDigits: 6)
                let upper = range.upperBound.fromRadians(to: .degrees).roundTo(fractionalDigits: 6)
                return lower...upper
            })
        case .radians:
            range
        }
    }

    func onChange(_ change: NumberInputView.Change) {
        log("change: \(change)")
        self.vm.submit(
            .input(
                self.input.index,
                .float(change.newValue.toRadians(from: self.unit)),
                change.oldValue.map({ .float($0.toRadians(from: self.unit)) })
            ),
            registerUndo: change.commit
        )
    }

    var snapping: NumberInputView.Configuration.Snapping {
        switch self.unit {
        case .degrees: .init(increments: 45.0, epsilon: 10.0, enabled: self.snap, modifier: [.option])
        case .radians:
            .init(increments: 45.0.radians, epsilon: 10.0.radians, enabled: self.snap, modifier: [.option])
        }
    }

    var numberInputConfiguration: NumberInputView.Configuration {
        if let range = self.transformedRange {
            .range(.init(snapping: self.snapping, range: range))
        } else {
            .free(.init(snapping: self.snapping))
        }
    }

    @State var snap: Bool = false

    var body: some View {
        Block {
            VStack(alignment: .leading) {
                HStack(spacing: 2) {
                    NodeInputPropertyTitleView(vm: self.vm, input: self.input)
                    Spacer()
                    Picker("", selection: self.$unit) {
                        Text("Degrees").tag(AngleUnit.degrees)
                        Text("Radians").tag(AngleUnit.radians)
                    }
                    .pickerStyle(.menu)
                    .buttonStyle(.borderless)
                    .controlSize(.small)

                    Toggle(isOn: self.$snap) {
                        Image(systemName: "lines.measurement.horizontal.aligned.bottom")
                    }
                    .toggleStyle(.button)
                    .controlSize(.small)
                }
                HStack {
                    AngleDial(angle: self.value, range: self.range)
                        .angleDialRangeStrokeStyle(.dimmed)
                    NumberInputView(
                        value: self.transformedValue,
                        configuration: self.numberInputConfiguration,
                        onChange: self.onChange(_:),
                        onDragStateChange: { _ in }
                    )
                    .inspectorNumberInput()
                }
            }
        }
    }
}

private struct DefaultInput: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input
    var range: ClosedRange<Double>?

    var value: Double {
        self.vm.nodeInputValue(self.input.index)?.maybeFloat ?? 0.0
    }

    func onChange(_ change: NumberInputView.Change) {
        self.vm.submit(
            .input(
                self.input.index,
                .float(change.newValue),
                change.oldValue.map({ .float($0) })
            ),
            registerUndo: change.commit
        )
    }

    var numberInputConfiguration: NumberInputView.Configuration {
        if let range = self.range {
            .range(.init(range: range))
        } else {
            .free(.init())
        }
    }

    var body: some View {
        Block {
            VStack(alignment: .leading) {
                NodeInputPropertyTitleView(vm: self.vm, input: self.input)
                NumberInputView(
                    value: self.value,
                    configuration: self.numberInputConfiguration,
                    onChange: self.onChange(_:),
                    onDragStateChange: { _ in }
                )
                .inspectorNumberInput()
            }
        }
    }
}
