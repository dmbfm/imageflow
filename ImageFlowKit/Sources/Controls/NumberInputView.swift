import Helpers
import SwiftUI

public struct NumberInputView: View {

    private var value: Double
    private var configuration: Configuration
    private var onChange: (NumberInputView.Change) -> ()
    private var onDragStateChange: ((Bool) -> ())?
    private var formatting: Formatting

    @State private var isEditable: Bool = false
    @State private var valueAtDragStart: Double = 0.0
    @State private var width: CGFloat = 0
    @State private var distance: CGFloat = 0
    @State private var isDragging: Bool = false
    @Environment(\.controlSize) private var controlSize
    @FocusState private var focused: Bool

    public enum Configuration {
        case free(FreeConfiguration)
        case range(RangeConfiguration)

        public var snapping: Snapping {
            switch self {
            case .free(let cfg): cfg.snapping
            case .range(let cfg): cfg.snapping
            }
        }

        public struct FreeConfiguration {
            public var sensitivity: Sensitiviy
            public var dragMaxDigits: Int?
            public var snapping: Snapping

            public init(sensitivity: Sensitiviy = .init(), snapping: Snapping = .init(), dragMaxDigits: Int? = 2) {
                self.sensitivity = sensitivity
                self.dragMaxDigits = dragMaxDigits
                self.snapping = snapping
            }
        }

        public struct RangeConfiguration {
            public var dragMaxDigits: Int?
            public var snapping: Snapping
            public var range: ClosedRange<Double>

            public init(
                dragMaxDigits: Int? = 2,
                snapping: Snapping = .init(),
                range: ClosedRange<Double>
            ) {
                self.dragMaxDigits = dragMaxDigits
                self.range = range
                self.snapping = snapping
            }
        }

        public struct Snapping {
            var increments: Double
            var epsilon: Double
            var enabled: Bool
            var modifier: EventModifiers?

            func isEnabled(withModifiers modifiers: EventModifiers) -> Bool {
                if let modifier = self.modifier {
                    self.enabled || modifiers.contains(modifier)
                } else {
                    self.enabled
                }
            }

            public init(
                increments: Double = 0.1,
                epsilon: Double = 0.025,
                enabled: Bool = false,
                modifier: EventModifiers? = nil
            ) {
                self.increments = increments
                self.epsilon = epsilon
                self.enabled = enabled
                self.modifier = modifier
            }

        }
    }

    public enum Formatting {
        case raw(fractionalDigits: Int? = 8)
        case integer
    }

    public struct Change {
        public var newValue: Double
        public var oldValue: Double?
        public var commit: Bool
    }

    public struct Sensitiviy {
        public var slow: Double
        public var regular: Double
        public var fast: Double

        public init(slow: Double = 0.05, regular: Double = 1.0, fast: Double = 10.0) {
            self.slow = slow
            self.regular = regular
            self.fast = fast
        }
    }

    public init(
        value: Double,
        configuration: Configuration,
        formatting: Formatting = .raw(fractionalDigits: 8),
        onChange: @escaping (NumberInputView.Change) -> (),
        onDragStateChange: ((Bool) -> ())? = nil
    ) {
        self.value = value
        self.configuration = configuration
        self.onChange = onChange
        self.onDragStateChange = onDragStateChange
        self.formatting = formatting
    }

    var binding: Binding<String> {
        .init {
            switch self.formatting {
            case .raw(fractionalDigits: .some(let digits)):
                "\(value.roundTo(fractionalDigits: digits))"
            case .raw(fractionalDigits: .none):
                "\(value)"
            case .integer:
                "\(Int(value))"
            }
        } set: { text in
            if let newValue = Double(text), newValue != self.value {
                self.onChange(.init(newValue: newValue, commit: true))
            }
        }
    }

    var dragMaxDigits: Int? {
        switch self.configuration {
        case .free(let config): config.dragMaxDigits
        case .range(let config): config.dragMaxDigits
        }
    }

    func didEndEditing(_ text: String) {
        self.focused = false
        self.isEditable = false
    }

    func didCancel() {
        self.focused = false
        self.isEditable = false
    }

    private func onDrag(_ value: DragGestureEx.Value) {
        let shiftDown = value.modifiers.contains(.shift)
        let optionDown = value.modifiers.contains(.option)

        func makeNewValue() -> Double {
            let newValue =
                switch self.configuration {
                case .free(let config):
                    {
                        let t = value.location.x - value.startLocation.x
                        let s =
                            shiftDown
                            ? config.sensitivity.slow
                            : (optionDown ? config.sensitivity.fast : config.sensitivity.regular)
                        let newValue = config.dragMaxDigits.maybeReduce(
                            self.valueAtDragStart + s * t,
                            { value, digits in value.truncateTo(fractionalDigits: digits) }
                        )

                        // if config.snapping.isEnabled(withModifiers: value.modifiers) {
                        //     return newValue.snapping(
                        //         toIncrements: config.snapping.increments,
                        //         epsilon: config.snapping.epsilon
                        //     )
                        // } else {
                        return newValue
                        // }
                    }()
                case .range(let config):
                    {
                        if self.width != 0.00 {
                            config.dragMaxDigits.maybeReduce(
                                (config.range.lowerBound + config.range.span * (value.location.x / self.width)).clamped(
                                    to: config.range
                                ),
                                { value, digits in
                                    value.truncateTo(fractionalDigits: digits)
                                }
                            )
                        } else {
                            config.range.lowerBound
                        }
                    }()
                }

            if self.configuration.snapping.isEnabled(withModifiers: value.modifiers) {
                return newValue.snapping(
                    toIncrements: self.configuration.snapping.increments,
                    epsilon: self.configuration.snapping.epsilon
                )
            } else {
                return newValue
            }
        }

        let newValue = makeNewValue()
        if case .range = self.configuration {
            self.distance = value.location.x.clamped(to: 0...self.width)
        } else {
            self.distance = value.location.x
        }

        // if self.configuration.snapping.isEnabled(withModifiers: value.modifiers) {

        // }

        switch value.phase {
        case .began:
            self.valueAtDragStart = self.value
            self.isDragging = true
            self.onDragStateChange?(true)
        case .changed:
            self.onChange(.init(newValue: newValue, commit: false))
        case .ended:
            self.onChange(.init(newValue: newValue, oldValue: self.valueAtDragStart, commit: true))
            self.onDragStateChange?(false)
            self.isDragging = false
        case .cancelled:
            self.onChange(.init(newValue: self.valueAtDragStart, commit: false))
            self.onDragStateChange?(false)
            self.isDragging = false
        }
    }

    var progress: Double? {
        if case let .range(config) = self.configuration {
            config.range.progress(self.value)
        } else {
            nil
        }
    }

    public var body: some View {
        BetterTextField(text: self.binding, progress: self.progress, onWidthChange: { self.width = $0 })
            .betterTextFieldInteractionMode(.commit)
            .betterTextFieldDidEndEditing(self.didEndEditing(_:))
            .betterTextFieldIsEditable(self.isEditable)
            .betterTextFieldCancelAction(self.didCancel)
            .focused(self.$focused)
            .gesture(DragGestureEx(self.isEditable, self.onDrag(_:)))
            .onTapGesture {
                if !self.isEditable {
                    self.isEditable = true
                    self.focused = true
                }
            }
            #if os(macOS)
        .pointerStyle(self.isEditable ? .default : .columnResize)
            #endif
    }
}

#Preview {
    @Previewable @State var value: Double = 0.0
    @Previewable @State var isDragging: Bool = false

    VStack {
        NumberInputView(value: value, configuration: .free(.init())) { change in
            value = change.newValue
        } onDragStateChange: {
            isDragging = $0
        }
        .multilineTextAlignment(.trailing)

        NumberInputView(value: value, configuration: .range(.init(range: 0...10))) { change in
            value = change.newValue
            print("change: \(change)")
        } onDragStateChange: { value in
            isDragging = value
        }
        .multilineTextAlignment(.trailing)
        .betterTextFieldBorderShapeStyle(.secondaryFill)

        Text("\(isDragging, default: "") - \(value)")
    }
    .padding()
    .frame(width: 500, height: 200)

}
