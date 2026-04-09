import Controls
import Design
import Helpers
import Logging
import SharedModels
import SwiftUI
import Values

struct MatrixInputView: View {

    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var body: some View {
        switch self.input.value.type {
        case .matrix2x2:
            MatrixInputViewInner(vm: self.vm, input: self.input)
        default:
            EmptyView()
        }
    }
}

struct MatrixInputViewInner: View {

    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var dim: Int {
        switch self.input.value.type {
        case .matrix2x2: 2
        default: 0
        }
    }

    func floatValue(row: Int, col: Int) -> Double {
        switch self.input.value {
        case .matrix2x2(let m): m[row, col]
        default: 0.0
        }
    }

    func value(value: Double, row: Int, col: Int) -> Value? {
        switch self.input.value {
        case .matrix2x2(let m):
            var result = m
            result[row, col] = value
            return .matrix2x2(result)
        default:
            return nil
        }
    }

    func onChange(_ change: NumberInputView.Change, row: Int, col: Int) {
        if let newValue = self.value(value: change.newValue, row: row, col: col) {
            self.vm.submit(
                .input(
                    self.input.index,
                    newValue,
                    change.oldValue.flatMap({
                        self.value(value: $0, row: row, col: col)
                    })
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
                    onChange: self.onChange(_:row:col:)
                )
            }
        }
    }
}

struct MatrixControlView: View {

    var dim: Int
    var floatValue: (_ row: Int, _ col: Int) -> Double
    var onChange: (_ change: NumberInputView.Change, _ row: Int, _ col: Int) -> ()

    var body: some View {
        Grid(horizontalSpacing: 4, verticalSpacing: 4) {
            ForEach(0..<self.dim, id: \.self) { row in
                GridRow {
                    ForEach(0..<dim, id: \.self) { col in
                        NumberInputView(
                            value: self.floatValue(row, col),
                            configuration: .free(.init()),
                            onChange: { self.onChange($0, row, col) }
                        )
                        .inspectorNumberInput()
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
