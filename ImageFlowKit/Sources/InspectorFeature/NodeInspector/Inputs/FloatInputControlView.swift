import SwiftUI
import TextInput
import Values
import XKit

final class NodeFloatInputControlView: XViewEx, NodeInputControlView {

    var label: String {
        get { self.titleView.name }
        set { self.titleView.name = newValue }
    }

    let type: Values.ValueType = .float

    var value: Values.Value = .float(0.0) {
        didSet {
            self.numberInputController.value = self.doubleValue
        }
    }

    var valueDidChange: ((ValueChange) -> ())?

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

    lazy var blockView: BlockView = {
        let view = BlockView(self.stackView)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var stackView: XStackView = {
        let view = XStackView(views: [
            self.titleView,
            self.numberInputView,
        ])
        view.orientation = .vertical
        view.alignment = .leading
        return view
    }()

    lazy var titleView: NodeInputTitleView = {
        let titleView = NodeInputTitleView()
        return titleView
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

    init(_ label: String, _ value: Value, _ range: ClosedRange<Double>? = nil) {
        self.value = value
        self.range = range

        super.init(frame: .zero)

        self.label = label

        self.setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.addSubview(self.blockView)

        NSLayoutConstraint.activateConstraint(self.blockView, toFill: self)

        NSLayoutConstraint.activate([
            self.numberInputView.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor),
            self.numberInputView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor),
        ])
    }
}

extension NodeFloatInputControlView: NumberTextInputDelegate {
    func numberInputDidChange(_ numberInput: NumberInputController, change: NumberInputController.Change) {
        logger.info("numberInputDidChange: \("\(change)")")
        self.valueDidChange?(
            .init(
                newValue: .float(change.newValue),
                oldValue: .float(change.oldValue),
                commit: change.commit
            )
        )
    }
}

#Preview {
    VStack {
        XSimpleViewRepresentable(
            {
                let view = NodeFloatInputControlView("Value", .float(5))
                return view
            }()
        )
        .fixedSize(horizontal: false, vertical: true)
        .padding(50)
    }
}
