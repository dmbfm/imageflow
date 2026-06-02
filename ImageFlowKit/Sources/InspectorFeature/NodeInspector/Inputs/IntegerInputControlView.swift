import SwiftUI
import TextInput
import Values
import XKit

final class NodeIntegerInputControlView: XViewEx, NodeInputControlView {

    var label: String {
        get { self.titleView.name }
        set { self.titleView.name = newValue }
    }

    var connected: Bool {
        get { self.titleView.connected }
        set { self.titleView.connected = newValue }
    }

    let type: Values.ValueType = .int

    var value: Values.Value = .int(0) {
        didSet {
            self.numberInputController.value = Double(self.intValue)
            self.stepperView.doubleValue = Double(self.intValue)
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

    var range: ClosedRange<Int>?

    var minValue: Int?

    var intValue: Int {
        self.value.maybeInt ?? 0
    }

    var dragConfiguration: NumberInputController.DragConfiguration {
        if let range = self.range {
            return .range(
                .closed(
                    .init(
                        range: .init(uncheckedBounds: (Double(range.lowerBound), Double(range.upperBound))),
                        sensitivity: .init(slow: 0.1, modifier: .shift),
                        snap: .init(increments: 1.0),
                        fractionalDigits: 0
                    )
                )
            )
        } else if let lowerBound = self.minValue {
            return .range(
                .partialFrom(
                    .init(
                        lowerBound: Double(lowerBound),
                        sensitivity: .init(shiftDown: 0.1),
                        fractionalDigits: 0
                    )
                )
            )
        } else {
            return .free(
                .init(
                    sensitivity: .init(shiftDown: 0.1),
                    fractionalDigits: 0
                )
            )
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
            self.numberStackView,
        ])
        view.orientation = .vertical
        view.alignment = .leading
        return view
    }()

    lazy var titleView: NodeInputTitleView = {
        let titleView = NodeInputTitleView()
        return titleView
    }()

    lazy var numberStackView: XStackView = {
        let view = XStackView(views: [self.numberInputView, self.stepperView])
        view.translatesAutoresizingMaskIntoConstraints = true
        view.orientation = .horizontal
        view.distribution = .fill
        return view
    }()

    lazy var numberInputController: NumberInputController = {
        let controller = NumberInputController()
        controller.value = Double(self.intValue)
        controller.delegate = self
        controller.dragConfiguration = self.dragConfiguration
        controller.formatter = .integer
        return controller
    }()

    lazy var stepperView: XStepper = {
        let view = XStepper()
        view.controlSize = .small
        view.maxValue = Double(self.range?.upperBound ?? .max)
        view.minValue = Double(self.range?.lowerBound ?? self.minValue ?? .min)
        view.valueWraps = false
        view.autorepeat = true
        view.target = self
        view.action = #selector(Self.stepperHandler)
        view.increment = 1.0
        view.doubleValue = Double(self.intValue)
        return view
    }()

    var numberInputView: TextInput {
        self.numberInputController.view
    }

    init(label: String, value: Value, connected: Bool = false, range: ClosedRange<Int>? = nil, minValue: Int? = nil) {
        self.value = value
        self.range = range
        self.minValue = minValue

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
            self.numberStackView.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor),
            self.numberStackView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor),
        ])

        NSLayoutConstraint.activate([
            self.titleView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor)
        ])
    }

    @objc func stepperHandler() {
        logger.info("stepper value: \(self.stepperView.doubleValue)")
        self.context?.onEvent(
            .valueDidChange(
                .init(
                    newValue: .int(Int(self.stepperView.doubleValue)),
                    oldValue: .int(self.intValue),
                    commit: true
                )
            )
        )
    }
}

extension NodeIntegerInputControlView: NumberTextInputDelegate {
    func numberInputDidChange(_ numberInput: NumberInputController, change: NumberInputController.Change) {
        logger.info("numberInputDidChange: \("\(change)")")
        self.context?.onEvent(
            .valueDidChange(
                .init(
                    newValue: .int(Int(change.newValue)),
                    oldValue: .int(Int(change.oldValue)),
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
                let view = NodeIntegerInputControlView(label: "Value", value: .int(5))
                return view
            }()
        )
        .fixedSize(horizontal: false, vertical: true)
        .padding(50)
    }
}
