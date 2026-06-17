import SwiftUI
import TextInput
import Values
import XKit

final class NodeIntegerInputControlView: BaseNodeInputControlView {

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
    lazy var stackView: XStackView = {
        let view = XStackView(views: [
            self.titleView,
            self.numberStackView,
        ])
        view.orientation = .vertical
        view.alignment = .leading
        return view
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
        self.range = range
        self.minValue = minValue

        super.init(label: label, value: value, connected: connected)

        self.setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.blockView.view = self.stackView

        NSLayoutConstraint.activate([
            self.numberStackView.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor),
            self.numberStackView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor),
        ])

        NSLayoutConstraint.activate([
            self.titleView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor)
        ])
    }

    override func update() {
        self.numberInputController.value = Double(self.intValue)
        self.stepperView.doubleValue = Double(self.intValue)
    }

    @objc func stepperHandler() {
        self.setValue(
            newValue: .int(Int(self.stepperView.doubleValue)),
            oldValue: .int(self.intValue),
            commit: true
        )
    }
}

extension NodeIntegerInputControlView: NumberTextInputDelegate {
    func numberInputDidChange(_ numberInput: NumberInputController, change: NumberInputController.Change) {
        self.delegate?.nodeInputControl(
            self,
            valueDidChange:
                .init(
                    newValue: .int(Int(change.newValue)),
                    oldValue: .int(Int(change.oldValue)),
                    commit: change.commit
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
