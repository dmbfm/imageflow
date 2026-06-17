import SwiftUI
import TextInput
import Values
import XKit

final class NodeFloatInputControlView: BaseNodeInputControlView, MultiRowNodeInputControlView {

    var range: ClosedRange<Double>?

    var doubleValue: Double {
        self.value.maybeFloat ?? 0.0
    }

    var dragConfiguration: NumberInputController.DragConfiguration {
        if let range = self.range {
            return .range(.closed(.init(range: range, snap: nil, fractionalDigits: 2)))
        } else {
            return .free(.init(sensitivity: .init(), fractionalDigits: 2))
        }
    }

    var vstackedMixin: MultiRowNodeInputControlViewMixin!

    var controlView: XView {
        self.numberInputView
    }

    var numberInputView: TextInput {
        self.numberInputController.view
    }

    lazy var numberInputController: NumberInputController = {
        let controller = NumberInputController()
        controller.value = self.doubleValue
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.delegate = self
        controller.dragConfiguration = self.dragConfiguration
        return controller
    }()

    init(label: String, value: Value, connected: Bool = false, range: ClosedRange<Double>? = nil) {
        self.range = range

        super.init(label: label, value: value, connected: connected)

        self.vstackedMixin = .init(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update() {
        self.numberInputController.value = self.doubleValue
    }
}

extension NodeFloatInputControlView: NumberTextInputDelegate {
    func numberInputDidChange(_ numberInput: NumberInputController, change: NumberInputController.Change) {
        self.setValue(
            newValue: .float(change.newValue),
            oldValue: .float(change.oldValue),
            commit: change.commit
        )
    }
}

#Preview {
    VStack {
        XSimpleViewRepresentable(
            {
                let view = NodeFloatInputControlView(label: "Value", value: .float(5))
                return view
            }()
        )
        .fixedSize(horizontal: false, vertical: true)
        .padding(50)
    }
}
