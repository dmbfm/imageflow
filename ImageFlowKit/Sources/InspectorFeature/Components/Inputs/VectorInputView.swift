import Controls
import Design
import Helpers
import Logging
import SharedMocking
import SharedModels
import SwiftUI
import TextInput
import Values

struct VectorInputView: View {

    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    @State private var isDragging: Bool = false

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

    func onChange(_ idx: Int, _ change: NumberInputController.Change) {
        self.vm.submit(
            .input(
                self.input.index,
                self.value(settingIndex: idx, to: change.newValue),
                self.value(settingIndex: idx, to: change.oldValue),
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
                    isDragging: self.$isDragging,
                    onChange: self.onChange(_:_:)
                )
            }
        }
        .dragStatusBarMessage(self.$isDragging, message: [.dragFaster, .dragSlower], coordinator: self.vm.coordinator)
    }
}

struct VectorControlView: View {
    var dim: Int
    var labels: [String]
    var floatValue: (Int) -> Double
    @Binding var isDragging: Bool
    var onChange: (Int, NumberInputController.Change) -> ()

    var body: some View {
        Grid(verticalSpacing: 4) {
            ForEach(0..<self.dim, id: \.self) { idx in
                GridRow {
                    Text(self.labels[idx])
                        .font(.system(size: 10))
                        .bold()
                        .foregroundStyle(.secondaryLabel)
                        .gridColumnAlignment(.trailing)
                    NumberTextInputView(
                        self.floatValue(idx),
                        isDragging: self.$isDragging,
                        dragConfiguration: .free(.init(fractionalDigits: 2)),
                        onChange: { self.onChange(idx, $0) }
                    )
                    .textInputStyle(.inspector)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
