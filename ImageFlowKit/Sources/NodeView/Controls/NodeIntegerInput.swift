import Backend
import Helpers
import Logging
import SwiftUI
import Values

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

final class NodeIntegerInput: PlatformCommonView, NodeControl {
    var context: NodeControlContext = .init()
    var onEvent: ((NodeControlEvent) -> ())?

    var value: Value {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    var tint: PlatformColor = .systemBlue

    var range: ClosedRange<Int>? = nil {
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
        stepper.minValue = Double(self.range?.lowerBound ?? .min)
        stepper.maxValue = Double(self.range?.upperBound ?? .max)
        stepper.valueWraps = false
    }
    #else
    func updateRange(_ stepper: UIStepper? = nil) {
        let stepper = stepper ?? self.stepper
        stepper.minimumValue = Double(self.range?.lowerBound ?? .min)
        stepper.maximumValue = Double(self.range?.upperBound ?? .max)
        stepper.wraps = false
    }
    #endif

    private var style: Style = .default

    lazy var textField: NodeTextField = {
        let view = NodeTextField(
            self.value.int.formatted(.nodeInterger),
            style: .default.with(\.borderColor, self.tint)
        )
        view.onEvent = { [weak self] event in
            switch event {
            case .textDidChange(let value):
                guard let self else { return }
                if let number = Int(value) {
                    self.setValue(newValue: .int(number), registerUndo: true)
                } else {
                    if value == "" {
                        self.setValue(newValue: .int(0), registerUndo: true)
                    } else {
                        self.update()
                    }
                }
            case .sizeDidChange:
                self?.invalidateIntrinsicContentSize()
                self?.emit(.sizeDidChange)
            case .drag(let drag):
                self?.onDrag(drag)
            case .keyboardWillShow(windowVerticalOverlap: let value, let duration):
                self?.emit(.keyboardWillShow(windowVerticalOverlap: value, duration: duration))
            }
        }
        return view
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
            self.textField.isEditable
        }

        set {
            self.textField.isEditable = newValue
            self.stepper.isHidden = !newValue
        }
    }

    init(_ value: Value, range: ClosedRange<Int>? = nil, isEditable: Bool = true) {
        self.range = range
        self.value = value

        super.init(frame: .zero)

        self.clipsToBounds = false

        self.textField.isEditable = isEditable
        self.stepper.isHidden = !isEditable

        self.addSubview(self.textField)
        self.addSubview(self.stepper)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        self.textField.intrinsicContentSize.minMax(self.stepper.intrinsicContentSize, width: .sum, height: .max)
            + .init(width: self.style.textFieldStepperPadding, height: 0)
    }

    override func doLayout() {
        self.textField.frame.origin = .zero
        self.textField.frame.size = self.textField.intrinsicContentSize
        self.stepper.frame.origin = .init(x: self.textField.frame.maxX + self.style.textFieldStepperPadding, y: 0)
        self.stepper.frame.size = self.stepper.intrinsicContentSize

        Layout.align(
            views: [
                self.textField,
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
        self.textField.text = self.value.int.formatted(.nodeInterger)
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
    fileprivate struct Preview: PlatformViewRepresentable {

        @Binding var value: Value

        func makeView(context: Context) -> NodeIntegerInput {
            let view = NodeIntegerInput(self.value)
            view.onEvent = { event in
                switch event {
                case .valueDidChange(let value): self.value = value
                case .sizeDidChange: break
                case .keyboardWillShow: break
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
