#if os(iOS)

import Helpers
import InspectorFeatureShared
import Logging
import SharedModels
import SwiftUI
import Values
import Design

struct MatrixInputControl: View {
    let input: FlowNode.Input
    let vm: InspectorFeatureViewModel
    
    @State var dragState: DragState = .notDragging

    var emptyValue: Value {
        switch self.input.value.type {
        case .matrix3x3: .matrix3x3(.zero)
        case .matrix5x5: .matrix5x5(.zero)
        case .matrix7x7: .matrix7x7(.zero)
        default: .matrix3x3(.zero)
        }
    }

    var value: Value {
        self.vm.nodeInputValue(self.input.index) ?? self.emptyValue
    }

    func value(row: Int, col: Int) -> Double {
        switch self.input.value.type {
        case .matrix3x3: self.value.maybeMatrix3x3?[row, col] ?? 0.0
        case .matrix5x5: self.value.maybeMatrix5x5?[row, col] ?? 0.0
        case .matrix7x7: self.value.maybeMatrix7x7?[row, col] ?? 0.0
        default: 0.0
        }
    }

    func value(settingRow row: Int, col: Int, to newValue: Double) -> Value {
        switch self.input.value.type {
        case .matrix3x3:
            var value = self.value.matrix3x3
            value[row, col] = newValue
            return .matrix3x3(value)
        case .matrix5x5:
            var value = self.value.matrix5x5
            value[row, col] = newValue
            return .matrix5x5(value)
        case .matrix7x7:
            var value = self.value.matrix7x7
            value[row, col] = newValue
            return .matrix7x7(value)
        default:
            return self.emptyValue
        }
    }

    func onChange(_ row: Int, col: Int, _ change: DraggableFloatInput.Change) {
        let value = self.value(settingRow: row, col: col, to: change.value)

        let prev = change.previous.map({ x in
            self.value(settingRow: row, col: col, to: x)
        })

        self.vm.submit(
            .input(self.input.index, value, prev),
            registerUndo: change.commit
        )
    }

    var dim: Int {
        switch self.input.value.type {
        case .matrix3x3: 3
        case .matrix5x5: 5
        case .matrix7x7: 7
        default: 0
        }
    }

    var font: UIFont? {
        switch self.input.value.type {
        case .matrix5x5: UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .body), size: 10)
        case .matrix7x7: UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .body), size: 6)
        default: nil
        }
    }
    
    func onDragStateChange() {
        switch self.dragState {
        case .dragging:
            self.vm.coordinator.statusBar(StatusBarMessage.dragFloat.rawValue)
        case .notDragging:
            self.vm.coordinator.statusBar(nil)
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            InputLabel(input: self.input, vm: self.vm)
            Grid {
                ForEach(0..<self.dim, id: \.self) { row in
                    GridRow {
                        ForEach(0..<self.dim, id: \.self) { col in
                            VStack {
                                DraggableFloatInput(
                                    value: self.value(row: row, col: col),
                                    fractionalDigits: 2,
                                    dragState: self.$dragState,
                                    onChange: { self.onChange(row, col: col, $0) },
                                )
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background {
                                    Colors.inspectorControlBgIOS.color
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .uiFont(self.font)
            }
        }
        .onChange(of: self.dragState, initial: false, self.onDragStateChange)
    }
}

#Preview {
    InspectorFeatureView.Preview(nodes: [
        .init(kind: .valueNode(.matrix3x3))
    ])
}

#endif
