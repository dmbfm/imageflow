import CommonUtils
import Design
import Logging
import SwiftUI
import SwiftUIUtils

public struct NodeIntInput: View, @preconcurrency Equatable {
    public static func == (lhs: NodeIntInput, rhs: NodeIntInput) -> Bool {
        lhs.value == rhs.value
    }

    @Binding var value: Int

    public var body: some View {
        HStack(spacing: 0) {
            NodeNumberInput(
                value: .init {
                    Double(self.value)
                } set: { newValue in
                    self.value = Int(round(newValue))
                },
                settings: .init(formatter: .int)
            )

            Stepper("", value: self.$value)
                #if os(macOS)
            .controlSize(.small)
            .padding(.leading, -4)
                #else
            .padding(.leading, -2)
            .fixedSize()
            .scaleEffect(0.5)
            .padding(.leading, -25)
            .padding(.trailing, -15)
                #endif

        }
    }
}

public struct NodeNumberInput: View, @preconcurrency Equatable {
    public static func == (lhs: NodeNumberInput, rhs: NodeNumberInput) -> Bool {
        lhs.value == rhs.value && lhs.valueAtDragStart == rhs.valueAtDragStart
    }

    @Binding var value: Double
    @State var valueAtDragStart: Double?

    public struct Settings {
        public var dragSensitivity: DragSensitivity = .init()
        public var dragMaxFractionDigits: Int = 2
        public var formatter: Formatter = .float
        public init(
            dragSensitivity: NodeNumberInput.DragSensitivity = .init(),
            dragMaxFractionDigits: Int = 2,
            formatter: Formatter = .float
        ) {
            self.dragSensitivity = dragSensitivity
            self.dragMaxFractionDigits = dragMaxFractionDigits
            self.formatter = formatter
        }
    }

    public struct DragSensitivity: Sendable, Equatable {
        public var normal: CGFloat
        public var slow: CGFloat
        public init(normal: CGFloat = 0.01, slow: CGFloat = 0.001) {
            self.normal = normal
            self.slow = slow
        }
    }

    public enum Formatter {
        case int
        case float
    }

    let settings: Settings

    public init(value: Binding<Double>, settings: Settings = .init()) {
        self._value = value
        self.settings = settings
    }

    static let intFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal  // or .none, depending on whether you want grouping separators
        formatter.allowsFloats = false  // disallow any decimal input
        formatter.minimumFractionDigits = 0  // no fractional digits
        formatter.maximumFractionDigits = 0  // no fractional digits
        return formatter
    }()

    static let floatFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        #if os(macOS)
        formatter.roundingBehavior = .init(
            roundingMode: .plain,
            scale: 8,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        formatter.localizesFormat = false
        #endif
        #if os(iOS)
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 6
        #endif
        formatter.minimumFractionDigits = 1
        return formatter
    }()

    var formatter: NumberFormatter {
        switch self.settings.formatter {
        case .int:
            Self.intFormatter
        case .float:
            Self.floatFormatter
        }
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged(self.onDragChanged(_:))
            .onEnded(self.onDragEnded(_:))
    }

    func onDragChanged(_ gesture: DragGesture.Value) {
        self.dragIncrement(gesture)
    }

    func onDragEnded(_ gesture: DragGesture.Value) {
        self.dragIncrement(gesture)
        self.valueAtDragStart = nil
    }

    func dragIncrement(_ gesture: DragGesture.Value) {
        if self.valueAtDragStart == nil {
            self.valueAtDragStart = self.value
        }

        #if os(macOS)
        let sensitivity =
            if NSEvent.modifierFlags.contains(.shift) {
                self.settings.dragSensitivity.slow
            } else {
                self.settings.dragSensitivity.normal
            }
        #else
        let sensitivity = self.settings.dragSensitivity.normal
        #endif

        self.value = (self.valueAtDragStart! + gesture.translation.width * sensitivity).roundTo(
            fractionalDigits: self.settings.dragMaxFractionDigits
        )
    }

    public var body: some View {
        TextField("", value: self.$value, formatter: self.formatter)
            .nodeTextField(onDragChanged: self.onDragChanged(_:), onDragEnded: self.onDragEnded(_:))
            #if os(iOS)
        .keyboardType(.decimalPad)
            #endif
    }
}

#Preview {
    @Previewable @State var value: Double = 0.0
    @Previewable @State var intValue: Int = 0
    VStack {
        NodeNumberInput(value: $value)
            .tint(.orange)
        Text("value = \(value)")
        NodeIntInput(value: $intValue)
            .tint(.purple)
    }
    .frame(width: 500, height: 200)
    .background(Colors.cardBackground.color)
    .onChange(of: value) {
        print("value: \(value)")
    }
}
