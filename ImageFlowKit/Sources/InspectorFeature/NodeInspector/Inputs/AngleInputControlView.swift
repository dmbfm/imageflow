import Controls
import SharedModels
import SwiftUI
import TextInput
import Values
import XKit

// TODO: - Snap button

final class NodeAngleInputControlView: XViewEx, NodeInputControlView {

    var value: Values.Value = .float(0.0) {
        didSet {
            self.didSetValue()
        }
    }

    let type: Values.ValueType = .float

    var context: NodeInputControlContext? {
        didSet {
            self.titleView.context = self.context
        }
    }

    var hasChanges: Bool {
        get { self.titleView.hasChanges }
        set { self.titleView.hasChanges = newValue }
    }

    let range: ClosedRange<Double>?

    var unit: AngleUnit = .degrees {
        didSet {
            self.didSetUnit()
        }
    }

    var snapEnabled: Bool = false {
        didSet {
            self.didSetSnap()
        }
    }

    var label: String {
        get { self.titleView.name }
        set { self.titleView.name = newValue }
    }

    var connected: Bool {
        get { self.titleView.connected }
        set {
            self.titleView.connected = newValue
        }
    }

    var doubleValue: Double {
        self.value.maybeFloat ?? 0.0
    }

    var transformedDoubleValue: Double {
        self.doubleValue.fromRadians(to: self.unit)
    }

    var selectedUnitItemIndex: Int {
        switch self.unit {
        case .degrees: 0
        case .radians: 1
        }
    }

    var transformedRange: ClosedRange<Double> {

        let range: ClosedRange<Double> = self.range ?? -.pi...(.pi)

        switch self.unit {
        case .degrees:
            let lower = range.lowerBound.fromRadians(to: .degrees).roundTo(fractionalDigits: 6)
            let upper = range.upperBound.fromRadians(to: .degrees).roundTo(fractionalDigits: 6)
            return lower...upper
        case .radians:
            return range
        }
    }

    var dragConfiguration: NumberInputController.DragConfiguration {
        .range(
            .closed(
                .init(
                    range: self.transformedRange,
                    sensitivity: .init(),
                    snap: .init(
                        increments: 15,
                        epsilon: 15,
                        alwaysEnabled: self.snapEnabled,
                        modifier: .command
                    ),
                    fractionalDigits: self.unit == .degrees ? 1 : 2
                )
            )
        )
    }

    lazy var blockView: BlockView = {
        let view = BlockView(self.stackView)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var stackView: XStackView = {
        let view = XStackView(views: [
            // self.titleView,
            self.titleHStackView,
            self.hstackView,
        ])
        view.orientation = .vertical
        view.alignment = .leading
        return view
    }()

    lazy var titleHStackView: XStackView = {
        let view = XStackView(views: [
            self.titleView,
            self.unitsPopupView,
            self.snapButtonView,
        ])
        view.setCustomSpacing(0, after: self.unitsPopupView)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.orientation = .horizontal
        view.alignment = .centerY
        view.distribution = .fill
        return view
    }()

    lazy var hstackView: XStackView = {
        let view = XStackView(views: [
            self.angleDialView,
            self.numberInputView,
        ])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.orientation = .horizontal
        view.alignment = .centerY
        return view
    }()

    lazy var titleView: NodeInputTitleView = {
        let titleView = NodeInputTitleView()
        titleView.setContentHuggingPriority(.defaultLow - 10, for: .horizontal)
        titleView.setContentCompressionResistancePriority(.defaultLow - 10, for: .horizontal)
        return titleView
    }()

    lazy var numberInputController: NumberInputController = {
        let controller = NumberInputController()
        controller.value = self.transformedDoubleValue
        controller.view.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        controller.delegate = self
        controller.dragConfiguration = self.dragConfiguration
        controller.formatter = .roundingDigits(fractionalDigits: 8)
        return controller
    }()

    lazy var angleDialView: AngleDialView = {
        let view = AngleDialView(
            angle: self.doubleValue,
            range: self.range,
            style: .default
                .with(\.fillColor, .init(XColor.system.quaternaryFill))
                .with(\.flushToLeadingEdge, true)
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }()

    lazy var unitsPopupView: NSPopUpButton = {
        let view = NSPopUpButton()
        view.addItem(withTitle: AngleUnit.degrees.shortLabel)
        view.addItem(withTitle: AngleUnit.radians.shortLabel)
        view.setContentCompressionResistancePriority(.defaultLow - 10, for: .horizontal)
        view.isBordered = false
        view.alignment = .right
        view.font = .preferredFont(forTextStyle: .caption1)
        view.contentTintColor = .system.secondaryLabel
        view.target = self
        view.selectItem(at: self.selectedUnitItemIndex)
        view.action = #selector(Self.unitsPopupHandler)
        return view
    }()

    lazy var snapButtonView: XButton = {
        let view = XButton(
            image: NSImage(
                systemSymbolName: "lines.measurement.horizontal",
                accessibilityDescription: nil
            ) ?? .init(),
            target: self,
            action: #selector(Self.snapButtonHandler)
        )
        view.controlSize = .mini
        view.setButtonType(.onOff)
        view.imagePosition = .imageOnly
        view.toolTip = "Toggle Snapping"
        return view
    }()

    var numberInputView: TextInput {
        self.numberInputController.view
    }

    init(label: String, value: Value, connected: Bool, range: ClosedRange<Double>? = nil) {
        self.value = value
        self.range = range

        super.init(frame: .zero)

        self.titleView.connected = connected
        self.titleView.name = label

        self.setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.addSubview(self.blockView)

        NSLayoutConstraint.activateConstraint(self.blockView, toFill: self)

        NSLayoutConstraint.activate([
            self.hstackView.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor),
            self.hstackView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor),
        ])

        NSLayoutConstraint.activate([
            self.angleDialView.widthAnchor.constraint(equalTo: self.angleDialView.heightAnchor)
        ])

        NSLayoutConstraint.activate([
            self.titleHStackView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor)
        ])
    }

    // MARK: - User Interaction

    @objc func unitsPopupHandler() {
        if let item = self.unitsPopupView.selectedItem, let index = self.unitsPopupView.itemArray.firstIndex(of: item) {
            if index == 0 {
                self.unit = .degrees
            } else {
                self.unit = .radians
            }
        }
    }

    @objc func snapButtonHandler() {
        self.snapEnabled.toggle()
    }

    // MARK: - DidSets

    func didSetValue() {
        self.updateNumberTextInput()
        self.updateAngleDial()
    }

    func didSetUnit() {
        self.updateNumberTextInputConfiguration()
        self.updateNumberTextInput()
        self.updatesUnitsPopup()
    }

    func didSetSnap() {
        self.updateNumberTextInputConfiguration()
    }

    // MARK: - Updates

    func updateNumberTextInput() {
        self.numberInputController.value = self.transformedDoubleValue
    }

    func updateNumberTextInputConfiguration() {
        self.numberInputController.dragConfiguration = self.dragConfiguration
    }

    func updateAngleDial() {
        self.angleDialView.angle = self.doubleValue
    }

    func updatesUnitsPopup() {
        self.unitsPopupView.selectItem(at: self.selectedUnitItemIndex)
    }
}

extension NodeAngleInputControlView: NumberTextInputDelegate {
    func numberInputDidChange(_ numberInput: NumberInputController, change: NumberInputController.Change) {
        self.context?.onEvent(
            .valueDidChange(
                .init(
                    newValue: .float(change.newValue.toRadians(from: self.unit)),
                    oldValue: .float(change.oldValue.toRadians(from: self.unit)),
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
                let view = NodeAngleInputControlView(label: "Value", value: .float(5), connected: false)
                return view
            }()
        )
        .fixedSize(horizontal: false, vertical: true)
        .padding(50)
    }
}
