import Helpers
import SwiftUI

public struct NumberInputView: View {

    private var value: Double
    private var configuration: Configuration
    private var onChange: (NumberInputView.Change) -> ()
    private var onDragStateChange: ((Bool) -> ())?

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

        public struct FreeConfiguration {
            public var sensitivity: Sensitiviy
            public var dragMaxDigits: Int?

            public init(sensitivity: Sensitiviy = .init(), dragMaxDigits: Int? = 2) {
                self.sensitivity = sensitivity
                self.dragMaxDigits = dragMaxDigits
            }
        }

        public struct RangeConfiguration {
            public var dragMaxDigits: Int?
            public var range: ClosedRange<Double>

            public init(
                dragMaxDigits: Int? = 2,
                range: ClosedRange<Double>
            ) {
                self.dragMaxDigits = dragMaxDigits
                self.range = range
            }

        }
    }

    public struct Change {
        public var newValue: Double
        public var commit: Bool
    }

    public struct Sensitiviy {
        public var slow: Double = 0.01
        public var regular: Double = 0.1
        public var fast: Double = 1.0

        public init(slow: Double = 0.01, regular: Double = 0.1, fast: Double = 1.0) {
            self.slow = slow
            self.regular = regular
            self.fast = fast
        }
    }

    public init(
        value: Double,
        configuration: Configuration,
        onChange: @escaping (NumberInputView.Change) -> (),
        onDragStateChange: ((Bool) -> ())? = nil
    ) {
        self.value = value
        self.configuration = configuration
        self.onChange = onChange
        self.onDragStateChange = onDragStateChange
    }

    var binding: Binding<String> {
        .init {
            "\(value)"
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
            switch self.configuration {
            case .free(let config):
                {
                    let t = value.location.x - value.startLocation.x
                    let s =
                        shiftDown
                        ? config.sensitivity.slow : (optionDown ? config.sensitivity.fast : config.sensitivity.regular)
                    let newValue = config.dragMaxDigits.maybeReduce(
                        self.valueAtDragStart + s * t,
                        { value, digits in value.truncateTo(fractionalDigits: digits) }
                    )
                    return newValue
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
        }

        let newValue = makeNewValue()
        if case .range = self.configuration {
            self.distance = value.location.x.clamped(to: 0...self.width)
        } else {
            self.distance = value.location.x
        }

        switch value.phase {
        case .began:
            self.valueAtDragStart = self.value
            self.isDragging = true
            self.onDragStateChange?(true)
        case .changed:
            self.onChange(.init(newValue: newValue, commit: false))
        case .ended:
            self.onChange(.init(newValue: newValue, commit: true))
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
