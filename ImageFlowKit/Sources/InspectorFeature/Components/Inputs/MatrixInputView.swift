import Controls
import Design
import Helpers
import Logging
import SharedModels
import SwiftUI
import TextInput
import Values

struct MatrixInputView: View {

    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var body: some View {
        switch self.input.value.type {
        case .matrix2x2, .matrix3x3, .matrix5x5, .matrix7x7:
            MatrixInputViewInner(vm: self.vm, input: self.input)
        default:
            EmptyView()
        }
    }
}

struct MatrixInputViewInner: View {

    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    @State var isDragging: Bool = false

    var dim: Int {
        switch self.input.value.type {
        case .matrix2x2: 2
        case .matrix3x3: 3
        case .matrix5x5: 5
        case .matrix7x7: 7
        default: 0
        }
    }

    func floatValue(row: Int, col: Int) -> Double {
        switch self.input.value {
        case .matrix2x2(let m): m[row, col]
        case .matrix3x3(let m): m[row, col]
        case .matrix5x5(let m): m[row, col]
        case .matrix7x7(let m): m[row, col]
        default: 0.0
        }
    }

    func value(value: Double, row: Int, col: Int) -> Value? {
        switch self.input.value {
        case .matrix2x2(let m):
            var result = m
            result[row, col] = value
            return .matrix2x2(result)
        case .matrix3x3(let m):
            var result = m
            result[row, col] = value
            return .matrix3x3(result)
        case .matrix5x5(let m):
            var result = m
            result[row, col] = value
            return .matrix5x5(result)
        case .matrix7x7(let m):
            var result = m
            result[row, col] = value
            return .matrix7x7(result)
        default:
            return nil
        }
    }

    func onChange(_ change: NumberInputController.Change, row: Int, col: Int) {
        if let newValue = self.value(value: change.newValue, row: row, col: col) {
            self.vm.submit(
                .input(
                    self.input.index,
                    newValue,
                    self.value(value: change.oldValue, row: row, col: col)
                ),
                registerUndo: change.commit
            )
        }
    }

    var body: some View {
        Block {
            VStack(alignment: .leading) {
                NodeInputPropertyTitleView(vm: self.vm, input: self.input)

                MatrixControlView(
                    dim: self.dim,
                    floatValue: self.floatValue(row:col:),
                    isDragging: self.$isDragging,
                    onChange: self.onChange(_:row:col:)
                )
            }
        }
        .dragStatusBarMessage(self.$isDragging, message: [.dragFaster, .dragSlower], coordinator: self.vm.coordinator)
    }
}

struct MatrixControlView: View {

    var dim: Int
    var floatValue: (_ row: Int, _ col: Int) -> Double
    @Binding var isDragging: Bool
    var onChange: (_ change: NumberInputController.Change, _ row: Int, _ col: Int) -> ()

    var body: some View {
        Grid(horizontalSpacing: 4, verticalSpacing: 4) {
            ForEach(0..<self.dim, id: \.self) { row in
                GridRow {
                    ForEach(0..<dim, id: \.self) { col in
                        NumberTextInputView(
                            self.floatValue(row, col),
                            isDragging: self.$isDragging,
                            dragConfiguration: .free(.init(fractionalDigits: 2)),
                            onChange: { self.onChange($0, row, col) }
                        )
                        .textInputStyle(.inspector)
                    }
                }
            }
        }
    }
}

#Preview {
    InspectorFeatureView.Preview([.init(kind: .valueNode(.matrix2x2))])
        .frame(width: 600, height: 500)
}
