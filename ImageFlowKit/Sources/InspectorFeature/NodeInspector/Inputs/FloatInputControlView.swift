import SwiftUI
import TextInput
import Values
import XKit

final class NodeFloatInputControlView: XViewEx, NodeInputControlView {

    var label: String {
        get { self.titleView.name }
        set { self.titleView.name = newValue }
    }

    var connected: Bool {
        get { self.titleView.connected }
        set { self.titleView.connected = newValue }
    }

    let type: Values.ValueType = .float

    var value: Values.Value = .float(0.0) {
        didSet {
            self.numberInputController.value = self.doubleValue
        }
    }

    var context: NodeInputControlContext? {
        didSet {
            self.titleView.context = self.context
        }
    }

    var hasChanges: Bool {
        get { self.titleView.hasChanges }
        set { self.titleView.hasChanges = newValue }
    }

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

    init(label: String, value: Value, connected: Bool = false, range: ClosedRange<Double>? = nil) {
        self.value = value
        self.range = range

        super.init(frame: .zero)

        self.titleView.name = label
        self.titleView.connected = connected

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

        NSLayoutConstraint.activate([
            self.titleView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor)
        ])
    }
}

extension NodeFloatInputControlView: NumberTextInputDelegate {
    func numberInputDidChange(_ numberInput: NumberInputController, change: NumberInputController.Change) {
        logger.info("numberInputDidChange: \("\(change)")")
        self.context?.onEvent(
            .valueDidChange(
                .init(
                    newValue: .float(change.newValue),
                    oldValue: .float(change.oldValue),
                    commit: change.commit
                )
            )
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
