import SwiftUI
import TextInput
import Values
import XKit

final class NodeFloatInputControlView: BaseNodeInputControlView {

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

    lazy var stackView: XStackView = {
        let view = XStackView(views: [
            self.titleView,
            self.numberInputView,
        ])
        view.orientation = .vertical
        view.alignment = .leading
        return view
    }()

    lazy var numberInputController: NumberInputController = {
        let controller = NumberInputController()
        controller.value = self.doubleValue
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.delegate = self
        controller.dragConfiguration = self.dragConfiguration
        return controller
    }()

    var numberInputView: TextInput {
        self.numberInputController.view
    }

    init(label: String, value: Value, connected: Bool = false, range: ClosedRange<Double>? = nil) {
        self.range = range

        super.init(label: label, value: value, connected: connected)

        self.setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.blockView.content = self.stackView

        NSLayoutConstraint.activate([
            self.numberInputView.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor),
            self.numberInputView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor),
        ])

        NSLayoutConstraint.activate([
            self.titleView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor)
        ])
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
