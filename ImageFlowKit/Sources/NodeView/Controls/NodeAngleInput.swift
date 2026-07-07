import Backend
import Helpers
import SharedModels
import SwiftUI
import TextInput
import Values
import XKit

#if os(macOS)
import AppKit

#endif

#if os(iOS)
import UIKit
#endif

final class NodeAngleInput: XViewEx, NodeControl {

    public var onEvent: ((NodeControlEvent) -> ())?

    public var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    public var tint: XColor = .systemBlue

    var context: NodeControlContext = .init()

    var range: ClosedRange<Double>? = nil

    var dontUpdateText: Bool = false

    var snap: Bool = false {
        didSet {
            if self.snap != oldValue {
                self.updateDragConfiguration()
                self.updateSnapMenu()
            }
        }
    }

    var unit: AngleUnit = .degrees {
        didSet {
            if self.unit != oldValue {
                #if os(iOS)
                self.unitButton.setTitle(self.unit.shortLabel, for: .normal)
                if let child = self.unitButton.menu?.children[0] as? UIAction {
                    child.state = self.unit == .degrees ? .on : .off
                }
                if let child = self.unitButton.menu?.children[1] as? UIAction {
                    child.state = self.unit == .radians ? .on : .off
                }
                #endif
                self.updateSize()
                #if os(macOS)
                Task {
                    // NOTE: Hack because `NSPopupButton` is buggy as hell
                    self.updateSize()
                    try await Task.sleep(for: .milliseconds(10))
                    self.updateSize()

                }
                #endif
                self.updateDragConfiguration()
                self.update()
            }
        }
    }

    var isEditable: Bool {
        get {
            self.numberInput.isEnabled
        }
        set {
            self.numberInput.isEnabled = newValue
        }
    }

    var dragConfiguration: NumberInputController.DragConfiguration {
        let actualRange =
            if let range = self.range {
                range.lowerBound.fromRadians(to: self.unit).roundTo(
                    fractionalDigits: 6
                )...range.upperBound.fromRadians(to: self.unit).roundTo(fractionalDigits: 6)
            } else {
                -(.pi.fromRadians(to: self.unit))...(.pi.fromRadians(to: self.unit))
            }

        return .range(
            .closed(
                .init(
                    range: actualRange,
                    sensitivity: .init(),
                    snap: .init(
                        increments: 15,
                        epsilon: 15,
                        alwaysEnabled: self.snap,
                        modifier: .command
                    ),
                    fractionalDigits: self.unit == .degrees ? 1 : 2
                )
            )
        )
    }

    lazy var numberInput: NumberInputController = {
        let controller = NumberInputController()
        controller.sizingMode = .fixedWidth(84)
        controller.style = .default
            .with(\.font, .systemFont(ofSize: 12))
        controller.value = self.value.float.fromRadians(to: self.unit)
        controller.dragConfiguration = self.dragConfiguration
        controller.delegate = self
        controller.formatter = .roundingDigits(fractionalDigits: 8)
        return controller
    }()

    private lazy var dialView: AngleDialView = {
        let view = AngleDialView(angle: self.value.float, range: self.range)
        return view
    }()

    #if os(macOS)
    lazy var unitButton: NSPopUpButton = {
        let view = NSPopUpButton()
        view.addItem(withTitle: AngleUnit.degrees.shortLabel)
        if let item = view.lastItem {
            item.target = self
            item.action = #selector(Self.onPopupDegrees)
        }
        view.addItem(withTitle: AngleUnit.radians.shortLabel)
        if let item = view.lastItem {
            item.target = self
            item.action = #selector(Self.onPopupRadians)
        }
        view.isBordered = false
        view.selectItem(withTitle: self.unit.shortLabel)
        view.setTitle(self.unit.shortLabel)
        view.cell?.title = self.unit.shortLabel
        return view
    }()

    @objc func onPopupDegrees() {
        self.unit = .degrees
    }

    @objc func onPopupRadians() {
        self.unit = .radians
    }
    #endif

    #if os(iOS)
    lazy var unitButton: UIButton = {
        let view = UIButton(configuration: .plain(), primaryAction: nil)
        view.setTitle(self.unit.shortLabel, for: .normal)
        view.configuration?.buttonSize = .mini
        view.configuration?.contentInsets.leading = 1
        view.configuration?.contentInsets.trailing = 4
        view.menu = UIMenu(
            title: "Units",
            children: [
                UIAction(
                    title: AngleUnit.degrees.shortLabel,
                    state: self.unit == .degrees ? .on : .off,
                    handler: { _ in self.unit = .degrees }
                ),
                UIAction(
                    title: AngleUnit.radians.shortLabel,
                    state: self.unit == .radians ? .on : .off,
                    handler: { _ in self.unit = .radians }
                ),
                UIMenu(
                    title: "",
                    options: .displayInline,
                    children: [
                        UIAction(title: "Snap", state: self.snap ? .on : .off, handler: { _ in self.snap.toggle() })
                    ]
                ),
            ]
        )
        view.showsMenuAsPrimaryAction = true
        return view
    }()
    #endif

    public init(_ value: Value, range: ClosedRange<Double>? = nil, isEditable: Bool = true) {
        self.value = value
        self.range = range

        super.init(frame: .zero)

        self.clipsToBounds = false
        self.numberInput.isEnabled = isEditable

        self.addSubview(self.numberInput.view)
        self.addSubview(self.unitButton)
        self.addSubview(self.dialView)

        self.updateSnapMenu()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func updateSize() {
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
        self.emit(.sizeDidChange)
    }

    func transformValue(_ value: Double, _ drag: Bool = false) -> Double {
        if drag {
            self.range.maybeReduce(
                self.unit.radians(value),
                { value, range in value.clamped(to: range) }
            )
        } else {
            self.unit.radians(value)
        }
    }

    func update() {
        self.dialView.angle = self.value.float
        if !self.dontUpdateText {
            self.numberInput.value = self.value.float.fromRadians(to: self.unit)
        }
        self.updateProgress()
    }

    func updateProgress() {
        if let range = self.range {
            self.numberInput.progress = range.progress(self.value.float)
        } else {
            self.numberInput.progress = nil
        }
    }

    func updateDragConfiguration() {
        self.numberInput.dragConfiguration = self.dragConfiguration
    }

    func updateSnapMenu() {
        #if os(iOS)
        if let child = (self.unitButton.menu?.children[2] as? UIMenu)?.children[0] as? UIAction {
            child.state = self.snap ? .on : .off
        }
        #endif
    }

    // MARK: - Layout

    override var intrinsicContentSize: CGSize {
        let text = self.numberInput.view.intrinsicContentSize
        let buttonSize = self.unitButton.intrinsicContentSize

        return .init(
            width: text.width + buttonSize.width + Style.dialSize + Style.dialInputSpacing,
            height: max(text.height, buttonSize.height, Style.dialSize)
        )
    }

    override func layout() {
        super.layout()

        let numberInputSize = self.numberInput.view.intrinsicContentSize

        self.dialView.frame.origin = .init(x: 0, y: 0)
        self.dialView.frame.size = .init(width: Style.dialSize, height: Style.dialSize)
        self.numberInput.view.frame.origin = .init(x: self.dialView.frame.maxX + Style.dialInputSpacing, y: 0)
        self.numberInput.view.frame.size = .init(
            width: numberInputSize.width,
            height: numberInputSize.height
        )
        self.unitButton.frame.origin = .init(x: self.numberInput.view.frame.maxX, y: 0)
        self.unitButton.frame.size = self.unitButton.intrinsicContentSize
        Layout.align(
            views: [
                self.numberInput.view,
                self.unitButton,
                self.dialView,
            ],
            alignment: .verticalCenter,
            guide: .constant(self.bounds.midY)
        )
    }
}

extension NodeAngleInput: NumberTextInputDelegate {
    func numberInputDidChange(_ numberInput: NumberInputController, change: NumberInputController.Change) {
        let newValue = self.transformValue(change.newValue, change.drag)
        let oldValue = self.transformValue(change.oldValue, change.drag)

        self.dontUpdateText = true
        self.setValue(newValue: .float(newValue), oldValue: .float(oldValue), registerUndo: change.commit)
        self.dontUpdateText = false
    }

    func numberInputDragStarted(_ numberInput: NumberInputController) {
        self.onEvent?(.statusBarMessage(.statusMessageNumberSnapDrag))
    }

    func numberInputDragEnded(_ numberInput: NumberInputController) {
        self.onEvent?(.statusBarMessage(nil))
    }

    func numberInputKeyboardWillShow(
        _ numberInput: NumberInputController,
        windowVerticalOverlap: Double,
        animationDuration: Double
    ) {
        self.emit(.keyboardWillShow(windowVerticalOverlap: windowVerticalOverlap, duration: animationDuration))
    }
}

extension NodeAngleInput {
    struct Style {
        static let dialSize: CGFloat = 25.0
        static let dialStrokeColor: DynamicColor = .init(
            light: .init(white: 0.45, alpha: 1.0),
            dark: .init(white: 0.45, alpha: 1.0)
        )
        static let dialFillColor: DynamicColor = .init(
            light: .init(white: 0.45, alpha: 1.0),
            dark: .init(white: 0.45, alpha: 1.0)
        )
        static let dialInputSpacing: CGFloat = 4
    }
}

extension NodeAngleInput {
    struct Preview: XViewRepresentable {
        @Binding var value: Value
        func makeView(context: Context) -> NodeAngleInput {
            let view = NodeAngleInput(self.value, isEditable: true)
            view.onEvent = { event in
                switch event {
                case .valueDidChange(let newValue):
                    self.value = newValue
                default:
                    break
                }
            }
            return view
        }

        func updateView(_ view: NodeAngleInput, context: Context) {

        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: NodeAngleInput, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview {
    @Previewable @State var value: Value = .float(75.0.radians)
    VStack {
        NodeAngleInput.Preview(value: $value)
            .fixedSize()
            .border(.red)
    }

    .frame(minWidth: 200, minHeight: 200)
}
