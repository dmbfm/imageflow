import Combine
import Helpers
import XKit

public final class NumberInput: XView, Rx, WithRef {

    // MARK: - Public Properties

    public var value: Double {
        didSet {
            if self.value != oldValue {
                self.publisher.send(self.value)
                self.update()
            }
        }
    }

    public var dragConfiguration: DragConfiguration = .free(.init()) {
        didSet {
            self.update()
        }
    }

    @PublishedEx public private(set) var isDragging: Bool = false

    public let stepperConfiguration: StepperConfiguration?

    public private(set) var textField: TextField

    public private(set) var stackView: HStack

    public private(set) var stepper: Stepper

    public var cancellables: Set<AnyCancellable> = []

    public var formatter: FloatingPointFormatStyle<Double>

    public var publisher: CurrentValueSubject<Double, Never>

    public var changePublisher: PassthroughSubject<Change, Never> = .init()

    public var isEnabled: Bool {
        get { self.textField.isEnabled }
        set {
            self.textField.isEnabled = newValue
            self.window?.invalidateCursorRects(for: self)
            if !newValue {
                self.textField.resignFirstResponder()
                self.textField.isEditable = false
            }
        }
    }

    public var alignment: NSTextAlignment {
        get { self.textField.alignment }
        set { self.textField.alignment = newValue }
    }

    public var placeholderString: String? {
        get { self.textField.placeholderString }
        set { self.textField.placeholderString = newValue }
    }

    public var contentType: NSTextContentType? {
        get { self.textField.contentType }
        set { self.textField.contentType = newValue }
    }

    // MARK: - Public Types

    public struct Change: Sendable, Equatable {
        public var newValue: Double
        public var oldValue: Double
        public var commit: Bool
        public var dragging: Bool
    }

    // MARK: - Private Properties

    private var _onChange: ((Change) -> ())?
    private var dragStartLocation: CGPoint = .zero
    private var valueAtDragStart: Double = 0

    private var stepperDisabled: Bool {
        self.stepperConfiguration == nil
    }

    // MARK: - Privaet Types

    private struct DragData: Sendable, Equatable {
        public var phase: XGestureRecognizer.State
        public var modifiers: XModifierFlags
        public var region: CGRect
        public var translation: CGPoint
        public var start: CGPoint
        public var current: CGPoint
    }

    // MARK: - Initialization

    public init(
        _ value: Double,
        formatter: FloatingPointFormatStyle<Double> = .number,
        stepperConfiguration: StepperConfiguration? = nil,
        style: TextFieldStyle = .default
    ) {
        self.value = value
        self.textField = .init("", style: style)
        self.stackView = .init(alignment: .center, spacing: 4, views: [])
        self.stepper = .init(value)
        self.formatter = formatter
        self.publisher = .init(value)
        self.stepperConfiguration = stepperConfiguration

        super.init(frame: .zero)

        self.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)

        self.setupStackView()
        self.setupTextField()
        self.setupStepper()
        self.setupGestures()

        self.update()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    @discardableResult
    public func onChange(_ perform: @escaping (Change) -> ()) -> Self {
        self._onChange = perform
        return self
    }

    // MARK: - XView

    #if os(macOS)
    public override func resetCursorRects() {
        let cursor: NSCursor =
            if !self.isEnabled {
                .arrow
            } else if !self.textField.isFocused {
                .columnResize
            } else {
                .iBeam
            }

        self.addCursorRect(self.textField.frame, cursor: cursor)
    }
    #endif

    public override func setContentCompressionResistancePriority(
        _ priority: NSLayoutConstraint.Priority,
        for orientation: NSLayoutConstraint.Orientation
    ) {
        super.setContentCompressionResistancePriority(priority, for: orientation)
        self.textField.setContentCompressionResistancePriority(priority, for: orientation)
    }

    public override func setContentHuggingPriority(
        _ priority: NSLayoutConstraint.Priority,
        for orientation: NSLayoutConstraint.Orientation
    ) {
        super.setContentHuggingPriority(priority, for: orientation)
        self.textField.setContentHuggingPriority(priority, for: orientation)
    }

    // MARK: - Private Methods

    private func setupStackView() {
        if !self.stepperDisabled {
            self.addSubview(self.stackView)
            self.stackView.translatesAutoresizingMaskIntoConstraints = false
            self.stackView.constraintToFillSuperview()
        }
    }

    private func setupTextField() {
        if self.stepperDisabled {
            self.textField.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(self.textField)
            self.textField.constraintToFillSuperview()
        } else {
            self.stackView.addView(self.textField)
        }
        self.textField.alignment = .right
        self.textField.isEditable = false
        self.textField.onEndEditting { [weak self] _, _ in self?.didEndEditing() }
    }

    private func setupStepper() {
        if self.stepperDisabled { return }

        self.stackView.addView(self.stepper)
        self.stepper.onChange { value in
            let oldValue = self.value
            if value != oldValue {
                self.value = value
                self.emitChange(
                    .init(newValue: value, oldValue: oldValue, commit: true, dragging: false)
                )
            }
        }
    }

    private func emitChange(_ change: Change) {
        self._onChange?(change)
        self.changePublisher.send(change)
    }

    private func update() {
        self.textField.text = self.formatter.format(self.value)
        self.stepper.value = self.value

        if let range = self.dragConfiguration.range {
            self.textField.progress = range.progress(self.value)
        }

        if let config = self.stepperConfiguration {
            // self.stepper.isHidden = false
            self.stepper.increment = config.step
            self.stepper.componentSize = config.size
            switch self.dragConfiguration {
            case .range(.closed(let range)):
                self.stepper.range = range.range
            case .range(.partialFrom(let partial)):
                self.stepper.range = .init(uncheckedBounds: (partial.lowerBound, Double.greatestFiniteMagnitude))
            case .free:
                break
            }
        }  // else {
        //     self.stepper.isHidden = true
        // }
    }

    private func updateValue(fromText text: String) {
        do {
            let newValue = try self.formatter.parseStrategy.parse(text)
            let oldValue = self.value
            if newValue != oldValue {
                self.value = newValue
                self.emitChange(
                    .init(
                        newValue: newValue,
                        oldValue: oldValue,
                        commit: true,
                        dragging: false
                    )
                )
            }
        } catch {
            logger.warning("Failed to parse text: \(text)")
            self.update()
        }
    }

    // MARK: - Text Field

    public func beginEditting() {
        self.disableGestures()
        if !self.textField.isEditable {
            self.textField.isEditable = true
        }
        if !self.textField.isFocused {
            self.textField.focus()
        }
    }

    private func didEndEditing() {
        self.enableGestures()
        self.textField.isEditable = false
        self.updateValue(fromText: self.textField.text)
    }

    // MARK: - Gestures

    private func setupGestures() {
        let clickGR = NSClickGestureRecognizer(target: self, action: #selector(Self.clickHandler(_:)))
        clickGR.delegate = self
        self.textField.addGestureRecognizer(clickGR)

        let panGR = NSPanGestureRecognizer(target: self, action: #selector(Self.dragHandler(_:)))
        panGR.delegate = self
        self.textField.addGestureRecognizer(panGR)
    }

    private func enableGestures() {
        self.gestureRecognizers.forEach({ $0.isEnabled = true })
    }

    private func disableGestures() {
        self.gestureRecognizers.forEach({ $0.isEnabled = false })
    }

    @objc func clickHandler(_ gesture: NSClickGestureRecognizer) {
        if !self.isEnabled { return }
        Task {
            self.beginEditting()
        }
    }

    @objc func dragHandler(_ gesture: NSPanGestureRecognizer) {
        guard self.isEnabled else { return }

        if gesture.state == .began {
            self.dragStartLocation = self.convert(gesture.location(in: nil), from: nil)
        }

        let currentLocation = self.convert(gesture.location(in: nil), from: nil)

        let dragData = DragData(
            phase: gesture.state,
            modifiers: .init(rawValue: gesture.modifierFlags.rawValue),
            region: self.bounds,
            translation: currentLocation - self.dragStartLocation,
            start: self.dragStartLocation,
            current: currentLocation
        )

        if dragData.phase == .began {
            self.valueAtDragStart = self.value
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

        switch dragData.phase {
        case .began: self.isDragging = true
        case .changed: break
        default: self.isDragging = false
        }
    }

    private func handleDragNoRange(
        dragData: DragData,
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
            self.emitChange(
                .init(
                    newValue: self.value,
                    oldValue: oldValue,
                    commit: false,
                    dragging: true
                )
            )
        case .began, .changed, .ended:
            self.emitChange(
                .init(
                    newValue: newValue,
                    oldValue: self.valueAtDragStart,
                    commit: dragData.phase == .ended,
                    dragging: true
                )
            )
        case .failed, .possible, .recognized:
            break
        @unknown default:
            break
        }
    }

    private func handleDragRange(
        dragData: DragData,
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
            self.emitChange(
                .init(
                    newValue: self.valueAtDragStart,
                    oldValue: newValue,
                    commit: false,
                    dragging: true
                )
            )
        default:
            self.value = newValue
            self.emitChange(
                .init(
                    newValue: newValue,
                    oldValue: self.valueAtDragStart,
                    commit: dragData.phase == .ended,
                    dragging: true
                )
            )
        }

        self.update()
    }
}

extension NumberInput: NSGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: NSGestureRecognizer) -> Bool {
        !self.textField.isEditable
    }
}

extension NumberInput {
    public struct StepperConfiguration: Sendable, Equatable, With {
        public var step: Double = 1.0
        public var size: ComponentSize = .small

        public init(step: Double = 1.0, size: ComponentSize = .small) {
            self.step = step
            self.size = size
        }
    }
}

extension NumberInput {
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
            public var modifier: XModifierFlags?
            public var alwaysEnabled: Bool

            public init(
                increments: Double,
                epsilon: Double? = nil,
                alwaysEnabled: Bool = false,
                modifier: XModifierFlags? = nil
            ) {
                self.increments = increments
                self.epsilon = epsilon ?? increments
                self.alwaysEnabled = alwaysEnabled
                self.modifier = modifier
            }

            public func resolve(_ modifiers: XModifierFlags) -> Self? {
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

            public func value(forKeyModifiers modifiers: XModifierFlags) -> Double {
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
            public var modifier: XModifierFlags

            public init(slow: Double = 0.1, modifier: XModifierFlags = .shift) {
                self.slow = slow
                self.modifier = modifier
            }

            public func value(forKeyModifiers modifiers: XModifierFlags) -> Double {
                if modifiers.contains(self.modifier) {
                    self.slow
                } else {
                    1.0
                }
            }
        }
    }
}

#Preview {
    VStack(
        alignment: .fill,
        views: [
            NumberInput(0.5)
                .onChange({ print("change: \($0)") }),
            NumberInput(0.5, stepperConfiguration: .init())
                .with(\.alignment, .center)
                .onChange({ print("change: \($0)") }),
        ]
    )
    .constrainingWidth(toConstant: 120)
}
