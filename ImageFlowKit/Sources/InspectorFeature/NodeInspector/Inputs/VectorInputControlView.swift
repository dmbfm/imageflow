import SwiftUI
import TextInput
import Values
import XKit

final class NodeVectorInputControlView: BaseNodeInputControlView, MultiRowNodeInputControlView {

    var vstackedMixin: MultiRowNodeInputControlViewMixin!

    var controlView: XView { self.stackView }

    var dim: Int {
        switch self.value.type {
        case .vector2: 2
        case .vector3: 3
        case .vector4: 4
        default: 0
        }
    }

    func doubleValue(_ index: Int) -> Double {
        switch self.value {
        case .vector2(let v): v[index]
        case .vector3(let v): v[index]
        case .vector4(let v): v[index]
        default: 0
        }
    }

    func value(settingIndex index: Int, to value: Double) -> Value {
        switch self.value {
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
            return self.value
        }
    }

    static func label(_ index: Int) -> String {
        switch index {
        case 0: "x"
        case 1: "y"
        case 2: "z"
        case 3: "w"
        default: ""
        }
    }

    var numberInputs: [NumberInputController] {
        self.rows.map({ $0.0 })
    }

    lazy var stackView: XStackView = {
        let view = XStackView(views: self.rows.map({ $0.1 }))
        view.orientation = .vertical
        return view
    }()

    lazy var rows: [(NumberInputController, XView)] = {
        let labels = (0..<self.dim).map({ index in
            let label = XLabel(labelWithString: Self.label(index))
            label.textColor = .system.secondaryLabel
            label.font = .preferredFont(forTextStyle: .caption1)
            label.font = .systemFont(ofSize: NSFont.systemFontSize - 3, weight: .bold)
            label.alignment = .right
            return label
        })

        let width = NSAttributedString(
            string: "w",
            attributes: [
                NSAttributedString.Key.font: NSFont.systemFont(ofSize: NSFont.systemFontSize - 3, weight: .bold) as Any
            ]
        ).size().width

        return (0..<self.dim).map({ index in
            let label = labels[index]
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.widthAnchor.constraint(equalToConstant: width)
            ])
            let controller = NumberInputController()
            controller.value = self.doubleValue(index)
            controller.view.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
            controller.view.setContentCompressionResistancePriority(.defaultLow - 1, for: .horizontal)
            controller.tag = index
            controller.delegate = self
            let stackView = XStackView(views: [label, controller.view])
            stackView.orientation = .horizontal
            stackView.distribution = .fill
            stackView.alignment = .centerY
            return (controller, stackView)
        })
    }()

    override init(label: String, value: Value, connected: Bool = false) {
        super.init(label: label, value: value, connected: connected)
        self.vstackedMixin = .init(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update() {
        for (index, input) in self.numberInputs.enumerated() {
            let newValue = self.doubleValue(index)
            if input.value != newValue {
                input.value = newValue
            }
        }
    }
}

extension NodeVectorInputControlView: NumberTextInputDelegate {
    func numberInputDidChange(_ numberInput: NumberInputController, change: NumberInputController.Change) {
        let index = numberInput.tag
        let newValue = self.value(settingIndex: index, to: change.newValue)
        let oldValue = self.value(settingIndex: index, to: change.oldValue)
        self.setValue(newValue: newValue, oldValue: oldValue, commit: change.commit)
    }
}
