import Controls
import Design
import Helpers
import Logging
import SharedModels
import SwiftUI
import TextInput
import Values

struct AffineTransforminputView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    @State var isDragging: Bool = false

    var value: Values::AffineTransform {
        self.vm.nodeInputValue(self.input.index)?.maybeAffineTransform ?? .identity
    }

    func matrixFloatValue(_ row: Int, _ col: Int) -> Double {
        self.value[row, col]
    }

    func valueSettingMatrix(row: Int, col: Int, toValue val: Double) -> Value {
        var m = self.value
        m[row, col] = val
        return .affineTransform(m)
    }

    func matrixOnChange(_ change: NumberInputController.Change, _ row: Int, _ col: Int) {
        self.vm.submit(
            .input(
                self.input.index,
                self.valueSettingMatrix(row: row, col: col, toValue: change.newValue),
                self.valueSettingMatrix(row: row, col: col, toValue: change.oldValue),
            ),
            registerUndo: change.commit
        )
    }

    func translationFloatValue(_ index: Int) -> Double {
        switch index {
        case 0: self.value.tX
        case 1: self.value.tY
        default: fatalError("Index out of range: \(index)")
        }
    }

    func valueSettingTranslation(index: Int, toValue val: Double) -> Value {
        var t = self.value

        switch index {
        case 0: t.tX = val
        case 1: t.tY = val
        default: fatalError("Index out of range: \(index)")
        }

        return .affineTransform(t)
    }

    func translationOnChange(_ index: Int, _ change: NumberInputController.Change) {
        self.vm.submit(
            .input(
                self.input.index,
                self.valueSettingTranslation(index: index, toValue: change.newValue),
                self.valueSettingTranslation(index: index, toValue: change.oldValue),
            ),
            registerUndo: change.commit
        )
    }

    var body: some View {
        Block {
            VStack(alignment: .leading) {
                NodeInputPropertyTitleView(vm: self.vm, input: self.input)

                Text("Matrix")
                    .font(.caption2)
                    .foregroundStyle(.secondaryLabel)
                    .padding(.top, 4)

                MatrixControlView(
                    dim: 2,
                    floatValue: self.matrixFloatValue(_:_:),
                    isDragging: self.$isDragging,
                    onChange: self.matrixOnChange(_:_:_:)
                )

                Text("Translation")
                    .font(.caption2)
                    .foregroundStyle(.secondaryLabel)
                    .padding(.top, 4)

                VectorControlView(
                    dim: 2,
                    labels: ["x", "y"],
                    floatValue: self.translationFloatValue(_:),
                    isDragging: self.$isDragging,
                    onChange: self.translationOnChange(_:_:)
                )
            }
        }
        .dragStatusBarMessage(self.$isDragging, message: [.dragFaster, .dragSlower], coordinator: self.vm.coordinator)
    }
}

#Preview {
    InspectorFeatureView.Preview([.init(kind: .coreImageFilterNode(.tileEffect(.CIAffineClamp)))])
        .frame(width: 600, height: 500)
}
