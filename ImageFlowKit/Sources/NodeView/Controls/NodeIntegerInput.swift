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

struct NodeIntegerInputFormat: FormatStyle {
    func format(_ value: Int) -> String {
        value.formatted(.number.grouping(.never))
    }
}

extension FormatStyle where Self == NodeIntegerInputFormat {
    static var nodeInterger: NodeIntegerInputFormat {
        .init()
    }
}

final class NodeIntegerInput: XViewEx, NodeControl {
    var context: NodeControlContext = .init()
    var onEvent: ((NodeControlEvent) -> ())?

    var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    var tint: XColor = .systemBlue

    var range: ClosedRange<Int>? = nil {
        didSet {
            self.updateRange()
        }
    }

    var lowerBound: Int? = nil {
        didSet {
            self.updateRange()
        }
    }

    var min: Int? {
        self.range?.lowerBound
    }

    var max: Int? {
        self.range?.upperBound
    }

    #if os(macOS)
    func updateRange(_ stepper: NSStepper? = nil) {
        let stepper = stepper ?? self.stepper
        stepper.minValue = Double(self.range?.lowerBound ?? self.lowerBound ?? .min)
        stepper.maxValue = Double(self.range?.upperBound ?? .max)
        stepper.valueWraps = false
    }
    #else
    func updateRange(_ stepper: UIStepper? = nil) {
        let stepper = stepper ?? self.stepper
        stepper.minimumValue = Double(self.range?.lowerBound ?? self.lowerBound ?? .min)
        stepper.maximumValue = Double(self.range?.upperBound ?? .max)
        stepper.wraps = false
    }
    #endif

    private var style: Style = .default

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
        } else if let lowerBound = self.lowerBound {
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

    lazy var textField: NumberInputController = {
        let controller = NumberInputController()
        controller.sizingMode = .fixedWidth(60)
        controller.value = Double(self.value.int)
        controller.dragConfiguration = self.dragConfiguration
        controller.style = .default
            .with(\.font, .systemFont(ofSize: 12))
        controller.delegate = self
        controller.formatter = Formatter()
        return controller
    }()

    #if os(macOS)
    lazy var stepper: NSStepper = {
        let view = NSStepper()
        // view.minValue = self.min.map { Double($0) } ?? -.infinity
        // view.maxValue = self.max.map { Double($0) } ?? .infinity
        view.increment = 1
        view.autorepeat = true
        view.isContinuous = true
        view.target = self
        view.action = #selector(Self.stepperHandler)
        view.value = Double(self.value.int)
        self.updateRange(view)
        return view
    }()
    #endif

    #if os(iOS)
    lazy var stepper: UIStepper = {
        let view = UIStepper()
        view.value = Double(self.value.int)
        view.minimumValue = -.infinity
        view.maximumValue = .infinity
        view.stepValue = 1
        view.autorepeat = true
        view.isContinuous = true
        view.addTarget(self, action: #selector(Self.stepperHandler), for: .valueChanged)
        self.updateRange(view)
        return view
    }()

    #endif

    lazy var debouncer: UndoDebouncer = {
        .init(0.2)
    }()

    @objc func stepperHandler() {
        let newValue: Value = .int(Int(self.stepper.value))

        if newValue != self.value {
            let oldValue = self.value
            if let undo = self.context.undo {
                self.debouncer.debounce(
                    oldValue: oldValue,
                    { oldValue in
                        undo.register(oldValue, newValue)
                    }
                )
            }
            self.value = .int(Int(self.stepper.value))
            self.emit(.valueDidChange(self.value))
        }
    }

    var isEditable: Bool {
        get {
            self.textField.isEnabled
        }

        set {
            self.textField.isEnabled = newValue
            self.stepper.isHidden = !newValue
        }
    }

    init(_ value: Value, range: ClosedRange<Int>? = nil, lowerBound: Int? = nil, isEditable: Bool = true) {
        self.range = range
        self.value = value
        self.lowerBound = lowerBound

        super.init(frame: .zero)

        self.clipsToBounds = false

        self.textField.isEnabled = isEditable
        self.stepper.isHidden = !isEditable

        self.addSubview(self.textField.view)
        self.addSubview(self.stepper)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        self.textField.view.intrinsicContentSize.minMax(self.stepper.intrinsicContentSize, width: .sum, height: .max)
            + .init(width: self.style.textFieldStepperPadding, height: 0)
    }

    override func layout() {
        super.layout()
        self.textField.view.frame.origin = .zero
        self.textField.view.frame.size = self.textField.view.intrinsicContentSize
        self.stepper.frame.origin = .init(x: self.textField.view.frame.maxX + self.style.textFieldStepperPadding, y: 0)
        self.stepper.frame.size = self.stepper.intrinsicContentSize

        Layout.align(
            views: [
                self.textField.view,
                self.stepper,
            ],
            alignment: .verticalCenter,
            guide: .constant(self.bounds.midY)
        )
    }

    func setValue(_ value: Int) {
        self.value.int = value
        self.emit(.valueDidChange(self.value))
    }

    func update() {
        // self.textField.text = self.value.int.formatted(.nodeInterger)
        self.textField.value = Double(self.value.int)
        self.stepper.value = Double(self.value.int)
        self.invalidateIntrinsicContentSize()
        self.emit(.sizeDidChange)
    }

    @State var valueAtDragStart: Int = 0

    func onDrag(_ value: NodeTextFieldEvent.Drag) {
        let phase = value.phase
        let optionDown = value.optionDown
        let shiftDown = value.shiftDown
        let dx = value.dx

        self.updateStatusBarMessage(phase)

        switch phase {
        case .began:
            self.valueAtDragStart = self.value.int
        default:
            break
        }

        let sensitivity = shiftDown ? 0.01 : (optionDown ? 1.0 : 0.1)
        let t = dx * sensitivity
        let newValue = Int(round(Double(self.valueAtDragStart) + t).truncateTo(fractionalDigits: 2))

        if phase == .ended {
            self.setValue(newValue: .int(newValue), oldValue: .int(self.valueAtDragStart), registerUndo: true)
        } else {
            self.setValue(newValue: .int(newValue))
        }
    }

    func updateStatusBarMessage(_ phase: XGestureRecognizer.State) {
        switch phase {
        case .began:
            self.onEvent?(.statusBarMessage(StatusBarMessage.dragFloat.rawValue))
        case .ended, .cancelled:
            self.onEvent?(.statusBarMessage(nil))
        default: break
        }
    }
}

extension NodeIntegerInput: NumberTextInputDelegate {

    func numberInputDidChange(_ numberInput: NumberInputController, change: NumberInputController.Change) {
        self.setValue(
            newValue: .int(Int(change.newValue)),
            oldValue: .int(Int(change.oldValue)),
            registerUndo: change.commit
        )
    }

    func numberInputDragStarted(_ numberInput: NumberInputController) {
        let message: String? =
            if self.range != nil {
                StatusBarMessage.dragFloatRange.rawValue
            } else {
                StatusBarMessage.dragFloat.rawValue
            }

        self.onEvent?(.statusBarMessage(message))
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

extension NodeIntegerInput {
    struct Formatter: NumberTextInputFormatter {
        func numperInputFormatter(formatValue value: Double) -> String {
            "\(Int(value.rounded()))"
        }

        func numperInputFormatter(parseString string: String) -> Double? {
            Int(string).map({ Double($0) })
        }
    }
}

#if os(macOS)
extension NSStepper {
    var value: Double {
        get {
            self.doubleValue
        }
        set {
            self.doubleValue = newValue
        }
    }
}
#endif

extension NodeIntegerInput {
    struct Style: Sendable, Equatable, With {
        var textFieldStepperPadding: CGFloat

        static var iOS: Self {
            .init(textFieldStepperPadding: 4)
        }

        static var macOS: Self {
            Self.iOS.with(\.textFieldStepperPadding, 4)
        }

        static var `default`: Self {
            #if os(macOS)
            .macOS
            #else
            .iOS
            #endif
        }
    }

}

extension NodeIntegerInput {
    fileprivate struct Preview: XViewRepresentable {

        @Binding var value: Value

        func makeView(context: Context) -> NodeIntegerInput {
            let view = NodeIntegerInput(self.value)
            view.onEvent = { event in
                switch event {
                case .valueDidChange(let value): self.value = value
                case .sizeDidChange: break
                case .keyboardWillShow: break
                case .statusBarMessage: break
                }
            }
            return view
        }

        func updateView(_ view: NodeIntegerInput, context: Context) {
            if self.value != view.value {
                view.value = self.value
            }
        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview {
    @Previewable @State var value: Value = .int(1234)
    VStack {
        NodeIntegerInput.Preview(value: $value)
        Text("\(value.description)")
            .font(.caption2)
            .fontDesign(.monospaced)

        NodeView.Preview(node: .init(kind: .valueNode(.int)))

    }
    .frame(minWidth: 500)
    .frame(minHeight: 500)
    .background(.white)
}
