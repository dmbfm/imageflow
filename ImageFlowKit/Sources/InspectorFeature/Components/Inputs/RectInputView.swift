import Controls
import Design
import Helpers
import Logging
import SharedMocking
import SharedModels
import SwiftUI
import Values

struct RectInputView: View {

    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    static let label: [String] = ["X", "Y", "Width", "Height"]

    var value: CGRect {
        self.vm.nodeInputValue(self.input.index)?.maybeRect ?? .zero
    }

    func floatValue(_ index: Int) -> Double {
        self.value[index]
    }

    func value(settingIndex index: Int, to value: Double) -> Value {
        var rect = self.value
        rect[index] = value
        return .rect(rect)
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
                    dim: 4,
                    labels: Self.label,
                    floatValue: self.floatValue(_:),
                    onChange: self.onChange(_:_:)
                )
            }
        }
    }
}

extension CGRect {
    subscript(_ index: Int) -> CGFloat {
        get {
            switch index {
            case 0: self.origin.x
            case 1: self.origin.y
            case 2: self.size.width
            case 3: self.size.height
            default:
                fatalError("Index out of bounds")
            }
        }
        set {
            switch index {
            case 0: self.origin.x = newValue
            case 1: self.origin.y = newValue
            case 2: self.size.width = newValue
            case 3: self.size.height = newValue
            default:
                fatalError("Index out of bounds")
            }
        }
    }
}

#Preview {
    InspectorFeatureView.Preview([.init(kind: .splitValue(.rect))])
        .frame(width: 600, height: 500)
}
