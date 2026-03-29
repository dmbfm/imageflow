import InspectorFeatureShared
import SharedMocking
import SharedModels
import SwiftUI
import Values

struct MultiRowControlView<ControlView: View>: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input
    let rowCount: Int

    var row: (Int) -> Row

    struct Row {
        var label: String
        var control: ControlView
    }

    var body: some View {
        InspectorPropertyLabel(label: input.label)

        ForEach(0..<self.rowCount, id: \.self) { n in
            let row = self.row(n)
            Text(row.label)
                //                    .foregroundStyle(.secondary)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.trailing, 4)
                .gridColumnAlignment(.trailing)

            HStack(alignment: .center, spacing: 0) {
                row.control
                    .disabled(input.connected)

                Spacer(minLength: 0)
            }
        }

        InputConnectedNodeButton(vm: self.vm, input: self.input)
    }
}

struct Matrix3x3InputControlView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    func floatValue(_ row: Int, _ column: Int) -> Double {
        self.input.value.maybeMatrix3x3?[row, column] ?? 0.0
    }

    func onChange(_ row: Int, _ column: Int, _ change: FloatInputView.Change) {
        if var value = self.input.value.maybeMatrix3x3 {
            let oldValue = change.oldValue.map({
                var oldValue = value
                oldValue[row, column] = $0
                return oldValue
            })
            value[row, column] = change.newValue
            self.vm.submit(
                .input(self.input.index, .matrix3x3(value), oldValue.map({ .matrix3x3($0) })),
                registerUndo: change.commit
            )
        }
    }

    var body: some View {
        MultiRowControlView(vm: self.vm, input: self.input, rowCount: 3) { row in
            .init(
                label: "",
                control: HStack(spacing: 2) {
                    FloatInputView(value: self.floatValue(row, 0)) { change in self.onChange(row, 0, change) }
                    FloatInputView(value: self.floatValue(row, 1)) { change in self.onChange(row, 1, change) }
                    FloatInputView(value: self.floatValue(row, 2)) { change in self.onChange(row, 2, change) }
                }
            )
        }
    }
}

struct Matrix5x5InputControlView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    func floatValue(_ row: Int, _ column: Int) -> Double {
        self.input.value.maybeMatrix5x5?[row, column] ?? 0.0
    }

    func onChange(_ row: Int, _ column: Int, _ change: FloatInputView.Change) {
        if var value = self.input.value.maybeMatrix5x5 {
            let oldValue = change.oldValue.map({
                var oldValue = value
                oldValue[row, column] = $0
                return oldValue
            })
            value[row, column] = change.newValue
            self.vm.submit(
                .input(self.input.index, .matrix5x5(value), oldValue.map({ .matrix5x5($0) })),
                registerUndo: change.commit
            )
        }
    }

    var body: some View {
        MultiRowControlView(vm: self.vm, input: self.input, rowCount: 5) { row in
            .init(
                label: "",
                control: HStack(spacing: 2) {
                    FloatInputView(value: self.floatValue(row, 0)) { change in self.onChange(row, 0, change) }
                    FloatInputView(value: self.floatValue(row, 1)) { change in self.onChange(row, 1, change) }
                    FloatInputView(value: self.floatValue(row, 2)) { change in self.onChange(row, 2, change) }
                    FloatInputView(value: self.floatValue(row, 3)) { change in self.onChange(row, 3, change) }
                    FloatInputView(value: self.floatValue(row, 4)) { change in self.onChange(row, 4, change) }
                }
            )
        }
    }
}

struct Matrix7x7InputControlView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    func floatValue(_ row: Int, _ column: Int) -> Double {
        self.input.value.maybeMatrix7x7?[row, column] ?? 0.0
    }

    func onChange(_ row: Int, _ column: Int, _ change: FloatInputView.Change) {
        if var value = self.input.value.maybeMatrix7x7 {
            let oldValue = change.oldValue.map({
                var oldValue = value
                oldValue[row, column] = $0
                return oldValue
            })
            value[row, column] = change.newValue
            self.vm.submit(
                .input(self.input.index, .matrix7x7(value), oldValue.map({ .matrix7x7($0) })),
                registerUndo: change.commit
            )
        }
    }

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<7, id: \.self) { row in
                HStack(spacing: 2) {
                    FloatInputView(value: self.floatValue(row, 0)) { change in self.onChange(row, 0, change) }
                    FloatInputView(value: self.floatValue(row, 1)) { change in self.onChange(row, 1, change) }
                    FloatInputView(value: self.floatValue(row, 2)) { change in self.onChange(row, 2, change) }
                    FloatInputView(value: self.floatValue(row, 3)) { change in self.onChange(row, 3, change) }
                    FloatInputView(value: self.floatValue(row, 4)) { change in self.onChange(row, 4, change) }
                    FloatInputView(value: self.floatValue(row, 5)) { change in self.onChange(row, 5, change) }
                    FloatInputView(value: self.floatValue(row, 6)) { change in self.onChange(row, 6, change) }
                }
            }
        }
    }
}

struct RectInputControlView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    func floatValue(_ n: Int) -> Double {
        switch n {
        case 0: Double(self.input.value.maybeRect?.origin.x ?? 0)
        case 1: Double(self.input.value.maybeRect?.origin.x ?? 0)
        case 2: Double(self.input.value.maybeRect?.origin.x ?? 0)
        case 3: Double(self.input.value.maybeRect?.origin.x ?? 0)
        default: 0
        }
    }

    func value(settingIndex index: Int, to value: Double) -> Value {
        if case var .rect(rect) = self.input.value {

            switch index {
            case 0: rect.origin.x = CGFloat(value)
            case 1: rect.origin.y = CGFloat(value)
            case 2: rect.size.width = CGFloat(value)
            case 3: rect.size.height = CGFloat(value)
            default: break
            }

            return .rect(rect)
        }
        return .rect(.zero)
    }

    func label(_ n: Int) -> String {
        switch n {
        case 0: "x"
        case 1: "y"
        case 2: "width"
        case 3: "height"
        default: ""
        }
    }

    var body: some View {
        MultiRowControlView(vm: self.vm, input: self.input, rowCount: 4) { row in
            .init(
                label: self.label(row),
                control:
                    FloatInputView(
                        value: self.floatValue(row),
                        onChange: { change in
                            self.vm.submit(
                                .input(
                                    self.input.index,
                                    self.value(settingIndex: row, to: change.newValue),
                                    change.oldValue.map({ self.value(settingIndex: row, to: $0) })
                                ),
                                registerUndo: change.commit
                            )
                        }
                    )
            )
        }
    }
}

struct VectorControlView: View {

    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var rowCount: Int {
        switch input.value.type {
        case .vector2: 2
        case .vector3: 3
        case .vector4: 4
        default: 0
        }
    }

    func floatValue(_ index: Int) -> Double {
        switch self.input.value {
        case .vector2(let v): v[index]
        case .vector3(let v): v[index]
        case .vector4(let v): v[index]
        default: 0.0
        }
    }

    func value(settingIndex index: Int, to value: Double) -> Value {
        switch self.input.value {
        case .vector2(var v):
            v[index] = value
            return .vector2(v)
        case .vector3(var v):
            v[index] = value
            return .vector3(v)
        case .vector4(var v):
            v[index] = value
            return .vector4(v)
        default:
            return .vector2(.zero)
        }
    }

    func componentLabel(_ index: Int) -> String {
        switch index {
        case 0: "x"
        case 1: "y"
        case 2: "z"
        case 3: "w"
        default: ""
        }
    }

    var body: some View {
        MultiRowControlView(
            vm: self.vm,
            input: input,
            rowCount: self.rowCount,
            row: { row in
                .init(
                    label: self.componentLabel(row),
                    control:
                        FloatInputView(value: self.floatValue(row)) { change in
                            self.vm.submit(
                                .input(
                                    self.input.index,
                                    self.value(settingIndex: row, to: change.newValue),
                                    change.oldValue.map({ self.value(settingIndex: row, to: $0) })
                                ),
                                registerUndo: change.commit,
                            )
                        }
                )
            }
        )
    }
}

#Preview("Zoom Blur") {
    @Previewable @State var flow: Flow = .preview(.coreImageFilterNode(.blur(.CIZoomBlur)))
    InspectorFeatureView.Preview(flow)
        .frame(width: 350)
}

#Preview("Slit") {
    @Previewable @State var flow: Flow = .preview(.splitValue(.vector4))
    InspectorFeatureView.Preview(flow)
        .frame(width: 350)
}
