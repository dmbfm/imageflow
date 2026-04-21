import Design
import Helpers
import SwiftUI

#if os(macOS)
import AppKit
public typealias PlatformViewController = NSViewController
#endif

#if os(iOS)
import UIKit
#endif

@MainActor
public class NumberInputController {

    public let view: TextInput

    public var value: Double = 0.0 {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    public var dragConfiguration: DragConfiguration = .free(.init()) {
        didSet {
            self.didSetDragConfiguration()
        }
    }

    public var formatter: (any NumberTextInputFormatter) = DefaultNumberInputFormatter() {
        didSet {
            self.update()
        }
    }

    public var progress: Double? {
        get { self.view.progress }
        set { self.view.progress = newValue }
    }

    public var style: TextInputStyle {
        get { self.view.style }
        set { self.view.style = newValue }
    }

    public var sizingMode: TextInput.SizingMode {
        get { self.view.sizingMode }
        set { self.view.sizingMode = newValue }
    }

    public var isEnabled: Bool {
        get { self.view.isEnabled }
        set { self.view.isEnabled = newValue }
    }

    public var placeholder: String? {
        get { self.view.placeholder }
        set { self.view.placeholder = newValue }
    }

    public var alignment: NSTextAlignment {
        get { self.view.alignment }
        set { self.view.alignment = newValue }
    }

    #if os(iOS)
    public var keyboardType: UIKeyboardType {
        get { self.view.keyboardType }
        set { self.view.keyboardType = newValue }
    }
    #endif

    public weak var delegate: NumberTextInputDelegate?

    public var range: ClosedRange<Double>? {
        self.dragConfiguration.range
    }

    public var sensitivity: DragConfiguration.Sensitivity? {
        self.dragConfiguration.sensitivity
    }

    private var valueAtDragStart: Double = 0.0

    public init(_ style: TextInputStyle = .default) {
        self.view = TextInput(behaviours: .draggableTextInput)
        self.view.delegate = self
        self.view.style = style
        self.view.alignment = .right
        #if os(iOS)
        self.view.keyboardType = .numbersAndPunctuation
        #endif

        self.update()
    }

    func update() {
        self.view.text = self.formatter.numperInputFormatter(formatValue: self.value)

        if let range = self.range {
            self.view.progress = range.progress(self.value)
        }
    }

    func didSetDragConfiguration() {
        self.update()
    }

    func handleDragNoRange(
        dragData: TextInput.DragData,
        sensitivity: DragConfiguration.Sensitivity,
        snap: DragConfiguration.Snap? = nil,
        fractionalDigits: Int? = nil,
        partialRange: PartialRangeFrom<Double>? = nil,
    ) {
        let s = sensitivity.value(forKeyModifiers: dragData.modifiers)
        let snap: DragConfiguration.Snap? = snap?.resolve(dragData.modifiers)
        let newValue = snap.maybeReduce(
            fractionalDigits.maybeReduce(
                partialRange.maybeReduce(
                    self.valueAtDragStart + s * dragData.translation.x,
                    { value, range in value.clamped(to: range) }
                ),
                { value, digits in
                    value.truncateTo(fractionalDigits: digits)
                }
            ),
            { value, snap in
                value.snapping(toIncrements: snap.increments, epsilon: snap.epsilon)
            }
        )

        self.value = newValue

        switch dragData.phase {
        case .cancelled:
            let oldValue = self.value
            self.value = self.valueAtDragStart
            self.delegate?.numberInputDidChange(
                self,
                change: .init(
                    newValue: self.value,
                    oldValue: oldValue,
                    commit: false,
                    drag: true
                )
            )
        case .began, .changed, .ended:
            self.delegate?.numberInputDidChange(
                self,
                change: .init(
                    newValue: newValue,
                    oldValue: self.valueAtDragStart,
                    commit: dragData.phase == .ended,
                    drag: true
                )
            )

        }
    }

    func handleDragRange(
        dragData: TextInput.DragData,
        configuration: DragConfiguration.Range.Closed
    ) {
        let snap: DragConfiguration.Snap? = configuration.snap?.resolve(dragData.modifiers)
        let fractionalDigits = configuration.fractionalDigits
        let range = configuration.range
        let s = configuration.sensitivity.value(forKeyModifiers: dragData.modifiers)

        let current = dragData.start.x + s * dragData.translation.x
        let p = ((current - dragData.region.minX) / dragData.region.width).clamped(to: 0...1)

        let newValue = snap.maybeReduce(
            fractionalDigits.maybeReduce(
                range.lowerBound + p * (range.upperBound - range.lowerBound),
                { value, digits in value.truncateTo(fractionalDigits: digits) }
            ),
            { value, snap in
                value.snapping(toIncrements: snap.increments, epsilon: snap.epsilon)
            }
        )

        switch dragData.phase {
        case .cancelled:
            self.value = self.valueAtDragStart
            self.delegate?.numberInputDidChange(
                self,
                change: .init(
                    newValue: self.valueAtDragStart,
                    oldValue: newValue,
                    commit: false,
                    drag: true
                )
            )
        default:
            self.value = newValue
            self.delegate?.numberInputDidChange(
                self,
                change: .init(
                    newValue: newValue,
                    oldValue: self.valueAtDragStart,
                    commit: dragData.phase == .ended,
                    drag: true
                )
            )
        }

        self.update()
    }
}

extension NumberInputController: TextInputDelegate {
    public func textInputDidEndEditing(_ textInput: TextInput) {
        if let newValue = self.formatter.numperInputFormatter(parseString: textInput.text) {
            let oldValue = self.value
            if newValue != oldValue {
                self.value = newValue
                self.delegate?.numberInputDidChange(
                    self,
                    change: .init(newValue: newValue, oldValue: oldValue, commit: true, drag: false)
                )
            }
        }

        self.update()
    }

    public func textInputDidDrag(_ textInput: TextInput, dragData: TextInput.DragData) {
        guard self.isEnabled else { return }

        if dragData.phase == .began {
            self.valueAtDragStart = self.value
            self.delegate?.numberInputDragStarted(self)
        }

        switch self.dragConfiguration {
        case .free(let free):
            self.handleDragNoRange(
                dragData: dragData,
                sensitivity: free.sensitivity,
                snap: free.snap,
                fractionalDigits: free.fractionalDigits
            )
        case .range(.closed(let closed)):
            self.handleDragRange(
                dragData: dragData,
                configuration: closed
            )
        case .range(.partialFrom(let partial)):
            self.handleDragNoRange(
                dragData: dragData,
                sensitivity: partial.sensitivity,
                snap: partial.snap,
                fractionalDigits: partial.fractionalDigits,
                partialRange: partial.lowerBound...
            )
        }

        if dragData.phase == .ended || dragData.phase == .cancelled {
            self.delegate?.numberInputDragEnded(self)
        }
    }

    public func textInputKeyboardWillShow(
        _ textInput: TextInput,
        windowVerticalOverlap: Double,
        animationDuration: Double
    ) {
        self.delegate?.numberInputKeyboardWillShow(
            self,
            windowVerticalOverlap: windowVerticalOverlap,
            animationDuration: animationDuration
        )
    }
}

extension NumberInputController {
    public struct Change: Sendable, Equatable {
        public var newValue: Double
        public var oldValue: Double
        public var commit: Bool
        public var drag: Bool
    }

    public enum DragConfiguration: Sendable, Equatable {
        case free(Free)
        case range(Range)

        public var range: ClosedRange<Double>? {
            switch self {
            case .range(.closed(let closed)): closed.range
            default: nil
            }
        }

        public var sensitivity: Sensitivity? {
            switch self {
            case .free(let s): s.sensitivity
            case .range(.partialFrom(let p)): p.sensitivity
            default: nil
            }
        }

        public struct Free: Sendable, Equatable {
            public var sensitivity: Sensitivity
            public var fractionalDigits: Int?
            public var snap: Snap?

            public init(
                sensitivity: DragConfiguration.Sensitivity = .init(),
                snap: Snap? = nil,
                fractionalDigits: Int? = nil
            ) {
                self.sensitivity = sensitivity
                self.fractionalDigits = fractionalDigits
                self.snap = snap
            }
        }

        public enum Range: Sendable, Equatable {
            case closed(Closed)
            case partialFrom(PartialFrom)

            public struct PartialFrom: Sendable, Equatable {
                public var lowerBound: Double
                public var sensitivity: Sensitivity
                public var snap: Snap?
                public var fractionalDigits: Int?

                public init(
                    lowerBound: Double,
                    sensitivity: DragConfiguration.Sensitivity,
                    snap: Snap? = nil,
                    fractionalDigits: Int? = nil
                ) {
                    self.lowerBound = lowerBound
                    self.sensitivity = sensitivity
                    self.fractionalDigits = fractionalDigits
                    self.snap = snap
                }
            }

            public struct Closed: Sendable, Equatable {
                public var range: ClosedRange<Double>
                public var snap: Snap?
                public var fractionalDigits: Int?
                public var sensitivity: RangeSensitivity

                public init(
                    range: ClosedRange<Double>,
                    sensitivity: RangeSensitivity = .init(),
                    snap: Snap? = nil,
                    fractionalDigits: Int? = nil
                ) {
                    self.range = range
                    self.snap = snap
                    self.fractionalDigits = fractionalDigits
                    self.sensitivity = sensitivity
                }
            }
        }

        public struct Snap: Sendable, Equatable {
            public var increments: Double
            public var epsilon: Double
            public var modifier: KeyModifiers?
            public var alwaysEnabled: Bool

            public init(
                increments: Double,
                epsilon: Double? = nil,
                alwaysEnabled: Bool = false,
                modifier: KeyModifiers? = nil
            ) {
                self.increments = increments
                self.epsilon = epsilon ?? increments
                self.alwaysEnabled = alwaysEnabled
                self.modifier = modifier
            }

            public func resolve(_ modifiers: KeyModifiers) -> Self? {
                if self.alwaysEnabled {
                    return self
                }

                if let modifier = self.modifier, modifiers.contains(modifier) {
                    return self
                }

                return nil
            }
        }

        public struct Sensitivity: Sendable, Equatable {
            public var normal: Double
            public var optionDown: Double?
            public var shiftDown: Double?

            public init(normal: Double = 0.5, optionDown: Double? = 2.0, shiftDown: Double? = 0.001) {
                self.normal = normal
                self.optionDown = optionDown
                self.shiftDown = shiftDown
            }

            public func value(forKeyModifiers modifiers: KeyModifiers) -> Double {
                if modifiers.contains(.shift) {
                    return self.shiftDown ?? self.normal
                } else if modifiers.contains(.option) {
                    return self.optionDown ?? self.normal
                } else {
                    return self.normal
                }
            }
        }

        public struct RangeSensitivity: Sendable, Equatable {
            public var slow: Double
            public var modifier: KeyModifiers

            public init(slow: Double = 0.1, modifier: KeyModifiers = .shift) {
                self.slow = slow
                self.modifier = modifier
            }

            public func value(forKeyModifiers modifiers: KeyModifiers) -> Double {
                if modifiers.contains(self.modifier) {
                    self.slow
                } else {
                    1.0
                }
            }
        }
    }

}

public protocol NumberTextInputDelegate: AnyObject {
    func numberInputDidChange(_ numberInput: NumberInputController, change: NumberInputController.Change)
    func numberInputDragStarted(_ numberInput: NumberInputController)
    func numberInputDragEnded(_ numberInput: NumberInputController)
    func numberInputKeyboardWillShow(
        _ numberInput: NumberInputController,
        windowVerticalOverlap: Double,
        animationDuration: Double
    )
}

extension NumberTextInputDelegate {
    public func numberInputDidChange(_ numberInput: NumberInputController, change: NumberInputController.Change) {}
    public func numberInputDragStarted(_ numberInput: NumberInputController) {}
    public func numberInputDragEnded(_ numberInput: NumberInputController) {}
    public func numberInputKeyboardWillShow(
        _ numberInput: NumberInputController,
        windowVerticalOverlap: Double,
        animationDuration: Double
    ) {}
}

public protocol NumberTextInputFormatter: Sendable, Equatable {
    func numperInputFormatter(formatValue value: Double) -> String
    func numperInputFormatter(parseString string: String) -> Double?
}

public struct DefaultNumberInputFormatter: NumberTextInputFormatter {
    public func numperInputFormatter(formatValue value: Double) -> String {
        "\(value)"
    }

    public func numperInputFormatter(parseString string: String) -> Double? {
        Double(string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

extension NumberTextInputFormatter where Self == DefaultNumberInputFormatter {
    public static var `default`: Self {
        DefaultNumberInputFormatter()
    }
}

public struct RoundingDigitsNumberInputFormatter: NumberTextInputFormatter {
    var digits: Int

    public init(digits: Int) {
        self.digits = digits
    }

    public func numperInputFormatter(formatValue value: Double) -> String {
        "\(value.roundTo(fractionalDigits: self.digits))"
    }

    public func numperInputFormatter(parseString string: String) -> Double? {
        Double(string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

extension NumberTextInputFormatter where Self == RoundingDigitsNumberInputFormatter {
    public static func roundingDigits(fractionalDigits digits: Int) -> Self {
        .init(digits: digits)
    }
}

extension NumberInputController {
    public struct Preview: View {
        public init() {}
        public var body: some View {
            VStack {
                Representable()
            }
            .padding()
            .frame(minWidth: 300)
        }
    }

    struct Representable: PlatformViewRepresentable {

        func makeView(context: Context) -> TextInput {
            context.coordinator.controller = .init()
            context.coordinator.controller.delegate = context.coordinator
            context.coordinator.controller.dragConfiguration = .range(
                .closed(.init(range: 0...200, snap: .init(increments: 10), fractionalDigits: 2))
            )
            return context.coordinator.controller.view
        }

        func updateView(_ view: TextInput, context: Context) {
        }

        func makeCoordinator() -> Coordinator {
            .init()
        }

        class Coordinator: NumberTextInputDelegate {
            var controller: NumberInputController!

            func numberInputDidChange(_ numberInput: NumberInputController, change: NumberInputController.Change) {
                print("change: \(change)")
            }

            func numberInputDragStarted(_ numberInput: NumberInputController) {
                print("numberInputDragStarted")
            }

            func numberInputDragEnded(_ numberInput: NumberInputController) {
                print("numberInputDragEnded")
            }
        }
    }
}

#Preview {
    NumberInputController.Preview()
}
