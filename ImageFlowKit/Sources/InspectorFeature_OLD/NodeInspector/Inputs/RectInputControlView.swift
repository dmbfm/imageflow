import SwiftUI
import TextInput
import Values
import XKit

final class NodeRectInputControlView: NodeVectorInputControlView {
    override var dim: Int { 4 }
    override func doubleValue(_ index: Int) -> Double {
        switch index {
        case 0: self.rectValue.origin.x
        case 1: self.rectValue.origin.y
        case 2: self.rectValue.width
        case 3: self.rectValue.height
        default: 0
        }
    }

    override func value(settingIndex index: Int, to value: Double) -> Value {
        var rect = self.rectValue
        switch index {
        case 0: rect.origin.x = value
        case 1: rect.origin.y = value
        case 2: rect.size.width = value
        case 3: rect.size.height = value
        default: break
        }
        return .rect(rect)
    }

    override func label(_ index: Int) -> String {
        switch index {
        case 0: "x"
        case 1: "y"
        case 2: "width"
        case 3: "height"
        default: ""
        }
    }

    override func labelColumnWidth() -> CGFloat {
        (0..<self.dim).reduce(
            0.0,
            { (acc, index) in
                let len: CGFloat =
                    NSAttributedString(
                        string: self.label(index),
                        attributes: [
                            NSAttributedString.Key.font: self.labelFont as Any
                        ]
                    ).size().width

                return max(acc, len)
            }
        )
    }

    var rectValue: CGRect {
        self.value.maybeRect ?? .zero
    }
}
