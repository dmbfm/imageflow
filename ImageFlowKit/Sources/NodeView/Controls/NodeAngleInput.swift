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
            }
        }
    }

    public var tint: PlatformColor = .systemBlue

    var context: NodeControlContext = .init() {
        didSet {
            self.numberInput.context = context
        }
    }

    var unit: AngleUnit = .degrees {
        didSet {
            Task {
                // NOTE: Hack because `NSPopupButton` is buggy as hell
                self.updateSize()
                try await Task.sleep(for: .milliseconds(10))
                self.updateSize()
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

    lazy var numberInput: NodeNumberInput = {
        let view = NodeNumberInput(self.value, isEditable: true)
        view.context = self.context
        view.onEvent = { [weak self] event in
            switch event {
            case .sizeDidChange:
                self?.updateSize()
            case .valueDidChange(let value):
                self?.value = value
                self?.dialView.angle = value.float
                self?.emit(.valueDidChange(value))
            case .keyboardWillShow:
                break
            }
        }
        view.snap = .init(increments: 45.0.radians, epsilon: 3.radians)
        return view
    }()

    private lazy var dialView: AngleDial = {
        let view = AngleDial()
        view.angle = self.value.float
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
    #endif

    @objc func onPopupDegrees() {
        self.unit = .degrees
    }

    @objc func onPopupRadians() {
        self.unit = .radians
    }

    func updateSize() {
        self.invalidateIntrinsicContentSize()
        self.needsLayout = true
        self.emit(.sizeDidChange)
    }

    public init(_ value: Value, isEditable: Bool = true) {
        self.value = value

        super.init(frame: .zero)

        self.clipsToBounds = false
        self.numberInput.isEditable = isEditable

        self.addSubview(self.numberInput)
        self.addSubview(self.unitButton)
        self.addSubview(self.dialView)

    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func update() {
        self.dialView.angle = self.value.float
        self.numberInput.value = self.value
    }

    func onDrag(_ phase: GesturePhase, _ dx: CGFloat, _ dy: CGFloat, _ shiftDown: Bool, _ controlDown: Bool) {
        switch phase {
        case .began:
            self.valueAtDragStart = self.value.float
        default:
            break
        }

        let sensitivity = shiftDown ? 0.01 : (controlDown ? 1.0 : 0.1)
        let t = dx * sensitivity
        let newValue = (self.valueAtDragStart + t).truncateTo(fractionalDigits: 2)

        if phase == .ended {
            self.setValue(newValue: .float(newValue), oldValue: .float(self.valueAtDragStart), registerUndo: true)
        } else {
            self.setValue(newValue: .float(newValue))
        }
    }

    // MARK: - Layout

    override var intrinsicContentSize: NSSize {
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
        self.dialView.frame.origin = .init(x: self.unitButton.frame.maxX, y: 0)
        self.dialView.frame.size = .init(width: Style.dialSize, height: Style.dialSize)
        self.unitButton.frame.size = self.unitButton.intrinsicContentSize
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

private struct Style {
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

private class AngleDial: PlatformCommonView {

    var angle: Double = 15.0.radians {
        didSet {
            self.needsDisplay = true
        }
    }

    var smallRadiusRatio: Double = 0.25 {
        didSet {
            self.needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        let boundsMinSide = min(self.bounds.width - 2, self.bounds.height - 2)
        let alpha = self.smallRadiusRatio

        let largeRadius = boundsMinSide / (2 * (1.0 + alpha))
        let smallRadius = largeRadius * alpha
        let bounds = self.bounds.insetBy(dx: smallRadius + 2, dy: smallRadius + 2)

        let square = CGRect(origin: bounds.origin, size: .init(width: 2 * largeRadius, height: 2 * largeRadius))
        let center = square.center
        let x = center.x + largeRadius * cos(self.angle) - smallRadius
        let y = center.y - largeRadius * sin(self.angle) - smallRadius
        let smallCircleRect = CGRect(x: x, y: y, width: 2 * smallRadius, height: 2 * smallRadius)

        Style.dialStrokeColor.platformColor.setStroke()
        Style.dialFillColor.platformColor.setFill()

        NSBezierPath(ovalIn: square).stroke()
        NSBezierPath(ovalIn: smallCircleRect).fill()
    }

    struct Preview: PlatformViewRepresentable {
        var angle: Double = 0.0
        func makeView(context: Context) -> AngleDial {
            let view = AngleDial()
            view.angle = self.angle
            return view
        }

        func updateView(_ view: AngleDial, context: Context) {
            view.angle = self.angle
        }
    }
}

#Preview {
    @Previewable @State var value: Value = .float(75.0.radians)
    VStack {
        NodeAngleInput.Preview(value: $value)
            .fixedSize()
            .border(.red)

        AngleDial.Preview(angle: value.float)
            .frame(width: 25, height: 25)

        AngleDial.Preview(angle: value.float)
            .frame(width: 50, height: 50)
    }

    .frame(minWidth: 200, minHeight: 200)
}
