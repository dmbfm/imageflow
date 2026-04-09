import Controls
import Design
import Helpers
import Logging
import SharedMocking
import SharedModels
import SwiftUI
import Values

struct VectorInputView: View {

    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var dim: Int {
        switch self.input.value.type {
        case .vector2: 2
        case .vector3: 3
        case .vector4: 4
        default: 0
        }
    }

    static let label: [String] = ["X", "Y", "Z", "W"]

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

    func onChange(_ idx: Int, _ change: NumberInputView.Change) {
        self.vm.submit(
            .input(
                self.input.index,
                self.value(settingIndex: idx, to: change.newValue),
                change.oldValue.map({ self.value(settingIndex: idx, to: $0) })
            ),
            registerUndo: change.commit,
        )
    }

    var body: some View {
        Block {
            VStack(alignment: .leading) {
                NodeInputPropertyTitleView(vm: self.vm, input: self.input)

                VectorControlView(
                    dim: self.dim,
                    labels: Self.label,
                    floatValue: self.floatValue(_:),
                    onChange: self.onChange(_:_:)
                )
            }
        }
    }
}

struct VectorControlView: View {
    var dim: Int
    var labels: [String]
    var floatValue: (Int) -> Double
    var onChange: (Int, NumberInputView.Change) -> ()

    var body: some View {
        Grid(verticalSpacing: 4) {
            ForEach(0..<self.dim, id: \.self) { idx in
                GridRow {
                    Text(self.labels[idx])
                        .font(.system(size: 10))
                        .bold()
                        .foregroundStyle(.secondaryLabel)
                        .gridColumnAlignment(.trailing)
                    NumberInputView(
                        value: self.floatValue(idx),
                        configuration: .free(.init()),
                        onChange: { self.onChange(idx, $0) },
                        onDragStateChange: { _ in }
                    )
                    .inspectorNumberInput()
                }
            }
        }
    }
}
