import Combine
import ComponentKit
import Helpers
import SwiftUI
import TextInput
import XKit

typealias DragConfiguration = NumberInputController.DragConfiguration

final class NumberInput: XView, Rx, WithRef {

    public var value: Double {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    public var dragConfiguration: DragConfiguration = .free(.init()) {
        didSet {
            self.dragConfigurationDidChange()
        }
    }

    public var formatter: (any NumberTextInputFormatter) = DefaultNumberInputFormatter() {
        didSet {
            self.update()
        }
    }

    public var textInputView: TextInput

    public var onChange: ((Change) -> ())?
    public var onDragStarted: (() -> ())?
    public var onDragEnded: (() -> ())?
    public var onInsertTab: (() -> ())?

    public var valuePublisher: CurrentValueSubject<Double, Never>
    public var changePublisher: PassthroughSubject<Change, Never>

    public var wantsInsertTab: Bool = false

    public var progress: Double? {
        get { self.textInputView.progress }
        set { self.textInputView.progress = newValue }
    }

    public var style: TextInputStyle {
        get { self.textInputView.style }
        set { self.textInputView.style = newValue }
    }

    public var sizingMode: TextInput.SizingMode {
        get { self.textInputView.sizingMode }
        set { self.textInputView.sizingMode = newValue }
    }

    public var isEnabled: Bool {
        get { self.textInputView.isEnabled }
        set { self.textInputView.isEnabled = newValue }
    }

    public var isEditable: Bool {
        get { self.textInputView.isEditable }
        set { self.textInputView.isEditable = newValue }
    }

    public var placeholder: String? {
        get { self.textInputView.placeholder }
        set { self.textInputView.placeholder = newValue }
    }

    public var alignment: NSTextAlignment {
        get { self.textInputView.alignment }
        set { self.textInputView.alignment = newValue }
    }

    public var range: ClosedRange<Double>? {
        self.dragConfiguration.range
    }

    public var sensitivity: DragConfiguration.Sensitivity? {
        self.dragConfiguration.sensitivity
    }

    var cancellables: Set<AnyCancellable> = []

    private var valueAtDragStart: Double = 0.0

    override var intrinsicContentSize: NSSize {
        .init(width: Self.noIntrinsicMetric, height: Self.noIntrinsicMetric)
    }

    init(_ value: Double, onChange: ((Change) -> ())? = nil) {
        self.value = value
        self.onChange = onChange
        self.valuePublisher = .init(value)
        self.changePublisher = .init()
        self.textInputView = .init(behaviours: .draggableTextInput)

        super.init(frame: .zero)

        self.textInputView.delegate = self
        self.textInputView.style = style
        self.textInputView.alignment = .right

        self.textInputView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.textInputView)
        NSLayoutConstraint.activateConstraint(self.textInputView, toFill: self)

        self.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)

        self.update()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func withRef(_ action: (NumberInput) -> ()) {
        action(self)
    }

    func update() {
        self.textInputView.text = self.formatter.numperInputFormatter(formatValue: self.value)

        if let range = self.range {
            self.textInputView.progress = range.progress(self.value)
        }
    }

    func dragConfigurationDidChange() {
        self.update()
    }

    func sendChange(_ change: Change) {
        self.onChange?(change)
        self.changePublisher.send(change)
        self.valuePublisher.send(change.newValue)
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
            self.sendChange(
                .init(
                    newValue: self.value,
                    oldValue: oldValue,
                    commit: false,
                    drag: true
                )
            )
        case .began, .changed, .ended:
            self.sendChange(
                .init(
                    newValue: newValue,
                    oldValue: self.valueAtDragStart,
                    commit: dragData.phase == .ended,
                    drag: true
                )
            )
        case .failed, .possible, .recognized:
            break
        @unknown default:
            break
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
            self.sendChange(
                .init(
                    newValue: self.valueAtDragStart,
                    oldValue: newValue,
                    commit: false,
                    drag: true
                )
            )
        default:
            self.value = newValue
            self.sendChange(
                .init(
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

extension NumberInput: TextInputDelegate {

    public func textInputDidEndEditing(_ textInput: TextInput) {
        if let newValue = self.formatter.numperInputFormatter(parseString: textInput.text) {
            let oldValue = self.value
            if newValue != oldValue {
                self.value = newValue
                self.onChange?(
                    .init(newValue: newValue, oldValue: oldValue, commit: true, drag: false)
                )
            }
        }

        self.update()
    }

    public func textInputDidDrag(_ textInput: TextInput, dragData: TextInput.DragData) {
        guard self.isEnabled else { return }

        if dragData.phase == .began {
            self.valueAtDragStart = self.value
            self.onDragStarted?()
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
            self.onDragEnded?()
        }
    }

    public func textInputKeyboardWillShow(
        _ textInput: TextInput,
        windowVerticalOverlap: Double,
        animationDuration: Double
    ) {
        // self.delegate?.numberInputKeyboardWillShow(
        //     self,
        //     windowVerticalOverlap: windowVerticalOverlap,
        //     animationDuration: animationDuration
        // )
    }

    public func textInputRespondsToInsertTab(_ textInput: TextInput) -> Bool {
        self.wantsInsertTab
    }

    public func textInputDidInsertTab(_ textInput: TextInput) {
        self.onInsertTab?()
    }
}

extension NumberInput {
    public struct Change: Sendable, Equatable {
        public var newValue: Double
        public var oldValue: Double
        public var commit: Bool
        public var drag: Bool
    }
}

extension XView {
    func constrainingWidth(toConstant value: CGFloat) -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: value).isActive = true
        return self
    }
    func constrainingHeight(toConstant value: CGFloat) -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: value).isActive = true
        return self
    }

    func withConsentHuggingPriority(
        _ priority: NSLayoutConstraint.Priority,
        for orientation: NSLayoutConstraint.Orientation
    ) -> Self {
        self.setContentHuggingPriority(priority, for: orientation)
        return self
    }
}

fileprivate struct PreviewView: XViewRepresentable {
    func makeView(context: Context) -> some NSView {
        NumberInput(5.0, onChange: { change in print("\(change)") })
            .with(\.formatter, .roundingDigits(fractionalDigits: 2))
    }

    func updateView(_ view: ViewType, context: Context) {

    }
}

#Preview {
    VStack {
        PreviewView()
            .padding()
    }
}
