import Backend
import Helpers
import Logging
import SharedModels
import SwiftUI
import Values

#if os(macOS)
import AppKit

#endif

#if os(iOS)
import UIKit
#endif

final class NodeAngleInput: PlatformCommonView, NodeControl {

    public var onEvent: ((NodeControlEvent) -> ())?

    public var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            } else if self.numberInput.value != self.value.float {
                self.numberInput.value = self.value.float.fromRadians(to: self.unit)
            }
        }
    }

    public var tint: PlatformColor = .systemBlue

    var context: NodeControlContext = .init()

    var range: ClosedRange<Double>? = nil

    var snap: Bool = false {
        didSet {
            if self.snap != oldValue {
                self.updateSnap()
            }
        }
    }

    func updateSnap() {
        self.numberInput.forceSnap = self.snap
        self.numberInput.snap = .init(
            increments: 45.0.fromDegrees(to: self.unit),
            epsilon: 3.0.fromDegrees(to: self.unit)
        )
        #if os(iOS)
        if let child = (self.unitButton.menu?.children[2] as? UIMenu)?.children[0] as? UIAction {
            child.state = self.snap ? .on : .off
        }
        #endif
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
                self.updateSnap()
                self.update()
            }
        }
    }

    var isEditable: Bool {
        get {
            self.numberInput.isEditable
        }
        set {
            self.numberInput.isEditable = newValue
        }
    }

    private var valueAtDragStart: CGFloat = 0.0

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

    lazy var numberInput: NodeNumberTextField = {
        let view = NodeNumberTextField(self.value.float.fromRadians(to: self.unit), isEditable: true)
        view.forceSnap = false
        view.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .sizeDidChange:
                self.updateSize()
            case .valueDidChange(let change):
                let newValue = self.transformValue(change.newValue, change.drag)
                self.numberInput.value = newValue.fromRadians(to: self.unit)
                self.setValue(
                    newValue: .float(newValue),
                    oldValue: change.oldValue.map({ .float(self.transformValue($0)) }),
                    registerUndo: change.commit
                )
                self.updateSize()
                self.updateProgress()
            case .keyboardWillShow(let windowVerticalOverlap, let duration):
                self.emit(.keyboardWillShow(windowVerticalOverlap: windowVerticalOverlap, duration: duration))
            case .dragStateChanged(let dragState):
                switch dragState {
                case .dragging:
                    self.onEvent?(.statusBarMessage(StatusBarMessage.dragFloatSnap.rawValue))
                case .notDragging:
                    self.onEvent?(.statusBarMessage(nil))
                }
            }
        }

        self.updateProgress(view)
        return view
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

    func updateSize() {
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
        self.emit(.sizeDidChange)
    }

    public init(_ value: Value, range: ClosedRange<Double>? = nil, isEditable: Bool = true) {
        self.value = value
        self.range = range

        super.init(frame: .zero)

        self.clipsToBounds = false
        self.numberInput.isEditable = isEditable

        self.addSubview(self.numberInput)
        self.addSubview(self.unitButton)
        self.addSubview(self.dialView)

        self.updateSnap()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func update() {
        log("update: \(self.unit), \(self.value), \(self.value.float.fromRadians(to: self.unit))")
        self.dialView.angle = self.value.float
        self.numberInput.value = self.value.float.fromRadians(to: self.unit)
        self.updateProgress()
    }

    func updateProgress(_ input: NodeNumberTextField? = nil) {
        let input = input ?? self.numberInput

        if let range = self.range {
            input.progress = range.progress(self.value.float)
        } else {
            input.progress = nil
        }
    }

    // MARK: - Layout

    override var intrinsicContentSize: CGSize {
        let text = self.numberInput.intrinsicContentSize
        let buttonSize = self.unitButton.intrinsicContentSize

        return .init(
            width: text.width + buttonSize.width + Style.dialSize,
            height: max(text.height, buttonSize.height, Style.dialSize)
        )
    }

    override func doLayout() {
        self.numberInput.frame.origin = .init(x: 0, y: 0)
        self.numberInput.frame.size = .init(
            width: self.bounds.width - self.unitButton.intrinsicContentSize.width - Style.dialSize,
            height: self.bounds.height
        )
        self.unitButton.frame.origin = .init(x: self.numberInput.frame.maxX, y: 0)
        self.unitButton.frame.size = self.unitButton.intrinsicContentSize
        self.dialView.frame.origin = .init(x: self.unitButton.frame.maxX, y: 0)
        self.dialView.frame.size = .init(width: Style.dialSize, height: Style.dialSize)
        Layout.align(
            views: [
                self.numberInput,
                self.unitButton,
                self.dialView,
            ],
            alignment: .verticalCenter,
            guide: .constant(self.bounds.midY)
        )
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
    }
}

extension NodeAngleInput {
    struct Preview: PlatformViewRepresentable {
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
