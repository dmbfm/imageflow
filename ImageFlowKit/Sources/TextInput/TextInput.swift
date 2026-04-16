import Design
import Helpers
import SwiftUI

#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
import Combine
#endif

@MainActor
public final class TextInput: PlatformCommonView {

    // MARK: - Public Properties

    /// The text that is being displayed by the text field.
    public var text: String {
        get {
            #if os(macOS)
            self.textField.text
            #else
            self.textField.text ?? ""
            #endif
        }
        set {
            if self.textField.text != newValue {
                self.textField.text = newValue
                self.setNeedsLayout()
            }
        }
    }

    /// If true, the TextInput can be interacted with by the user; if false, all
    /// user interaction is disabled, and the style of the TextInput is changed
    /// indicating that.
    public var isEnabled: Bool = true {
        didSet {
            if self.isEnabled != oldValue {
                self.updateEnabled()
            }
        }
    }

    /// The progress bar / slider percentage. When this value is not il, will
    /// fill the TextInput background vertically, from left-to-right, proportionally to
    /// this percentage.
    public var progress: Double? {
        get { self.backgroundView.progress }
        set { self.backgroundView.progress = newValue }
    }

    /// A placeholder string.
    public var placeholder: String? {
        get { self.textField.placeholder }
        set { self.textField.placeholder = newValue }
    }

    /// If true, the text field can be editted by the user directly via a
    /// keyboard (either physical or on-screen, etc.). Gestures are possibly still
    /// enabled.
    #if os(macOS)
    public var isEditable: Bool {
        get { self.textField.isEditable }
        set { self.textField.isEditable = newValue }
    }
    #else
    public var isEditable: Bool {
        get { self.textField.isUserInteractionEnabled }
        set { self.textField.isUserInteractionEnabled = newValue }
    }
    #endif

    /// The text alignment.
    #if os(macOS)
    public var alignment: NSTextAlignment {
        get { self.textField.cell?.alignment ?? .center }
        set { self.textField.cell?.alignment = newValue }
    }
    #else
    public var alignment: NSTextAlignment {
        get { self.textField.textAlignment }
        set { self.textField.textAlignment = newValue }
    }
    #endif

    /// The keyboard type (iOS only).
    #if os(iOS)
    public var keyboardType: UIKeyboardType {
        get { self.textField.keyboardType }
        set { self.textField.keyboardType = newValue }
    }
    #endif

    /// The `TextInputStyle` that determines the overall look of the TextInput.
    public var style: TextInputStyle = .default {
        didSet {
            self.updateStyle()
        }
    }

    /// The `SizingMode` of the TextInput. Determines both the
    /// `intrinsicContentSize` and how the TextInput is drawn.
    public var sizingMode: SizingMode = .fillWidth {
        didSet {
            if self.sizingMode != oldValue {
                self.invalidateIntrinsicContentSize()
                self.setNeedsLayout()
            }
        }
    }

    /// The TextInput's delegate object.
    public weak var delegate: TextInputDelegate?

    // MARK: - Private and Internal Properties

    let behaviours: Behaviors
    var textAtEditingStart: String = ""
    private var dragStartLocation: CGPoint = .zero

    // MARK: - Subviews

    lazy var backgroundView: BackgroundView = {
        let view = BackgroundView(style: self.style.background)
        return view
    }()

    // MARK: macOS

    #if os(macOS)
    lazy var textField: NSTextField = {
        let view = NSTextFieldEx()
        view.isBezeled = false
        view.isBordered = false
        view.drawsBackground = false
        view.maximumNumberOfLines = 1
        view.focusRingType = .none
        view.contentType = .password
        view.allowsExpansionToolTips = false
        view.allowsEditingTextAttributes = false
        view.allowsWritingTools = false
        view.allowsWritingToolsAffordance = false
        view.isAutomaticTextCompletionEnabled = false
        view.lineBreakMode = .byTruncatingTail
        view.cell?.lineBreakMode = .byTruncatingTail
        view.delegate = self
        view.didBecomeFirstResponder = { [weak self] in
            guard let self else { return }
            self.textAtEditingStart = self.textField.text
        }
        view.didResignFirstResponder = { [weak self] in }
        return view
    }()
    #endif

    // MARK: iOS

    #if os(iOS)
    lazy var textField: UITextField = {
        let view = UITextField()
        view.delegate = self
        view.text = "Hello, Wordl!"
        view.borderStyle = .none
        view.delegate = self
        view.returnKeyType = .done
        view.addTarget(self, action: #selector(Self.onEditingChanged), for: .editingChanged)
        return view
    }()
    #endif

    // MARK: - Initialization

    /// Create a new `TextInput` instance.
    /// - Parameters:
    ///   - behaviours: A set of `Behaviors` that determine how the TextInput
    /// will respond automatically to certain events such as the user pressing the enter
    /// key. See the `Behaviors` documentation for more information.
    ///   - style: The `TextInputStyle` for this `TextInput` instance.
    ///
    public init(behaviours: Behaviors = .default) {
        self.behaviours = behaviours

        super.init(frame: .zero)

        self.addSubview(self.backgroundView)
        self.addSubview(self.textField)

        self.initGestures()
        self.updateStyle()

        if self.behaviours.contains(.clickBecomeEditableAndFocus) {
            self.isEditable = false
        }
    }

    public required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Updates

    func updateStyle() {
        self.backgroundView.style = self.style.background
        self.textField.textColor = self.isEnabled ? self.style.textColor : self.style.textColorDisabled

        if let font = self.style.font {
            self.textField.font = font
        }
        // self.textField.font = self.style.font ?? .preferredFont(forTextStyle: .body)

        self.setNeedsDisplay()
    }

    func updateEnabled() {
        self.textField.isEnabled = self.isEnabled

        #if os(macOS)
        self.window?.invalidateCursorRects(for: self)
        #endif

        self.updateStyle()
    }

    // MARK: - Layout

    public override var intrinsicContentSize: CGSize {
        let textSize = self.textBasedSize
        let insets = self.style.insets
        let bounds = self.bounds

        let height = textSize.height + insets.verticalSum

        switch self.sizingMode {
        case .fixedWidth(let width):
            return .init(width: width, height: height)
        case .fillWidth:
            return .init(width: bounds.width, height: height)
        case .textWidth:
            return .init(width: textSize.width + insets.horizontalSum, height: height)
        }
    }

    public override func doLayout() {
        let textSize = self.textBasedSize
        let insets = self.style.insets
        let bounds = self.bounds

        let height = textSize.height + insets.verticalSum

        self.backgroundView.frame.origin = self.bounds.origin
        self.backgroundView.frame.size.width =
            switch self.sizingMode {
            case .fixedWidth(let width): width
            case .fillWidth: bounds.width
            case .textWidth: textSize.width + insets.horizontalSum
            }
        self.backgroundView.frame.size.height = height

        self.textField.frame.origin.x = self.backgroundView.frame.minX + insets.left
        self.textField.frame.origin.y = self.backgroundView.frame.minY + insets.top
        self.textField.frame.size.width = self.backgroundView.frame.width - insets.horizontalSum
        self.textField.frame.size.height = self.backgroundView.frame.height - insets.verticalSum
    }

    var textBasedSize: CGSize {
        let str = NSAttributedString(
            string: self.text,
            attributes: [
                NSAttributedString.Key.font: self.textField.font as Any
            ]
        )
        let height = NSAttributedString(
            string: "X",
            attributes: [
                NSAttributedString.Key.font: self.textField.font as Any
            ]
        ).size().height

        return .init(width: str.size().width + 6, height: height)
    }

    // MARK: - Platform-specific

    #if os(macOS)

    // MARK: macOS

    func initGestures() {
        if self.behaviours.contains(.clickBecomeEditableAndFocus) {
            let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(Self.clickGestureHandler(_:)))
            clickGesture.delegate = self
            self.addGestureRecognizer(clickGesture)
        }

        if self.behaviours.contains(.dragWhenNotEditable) {
            let panGesture = NSPanGestureRecognizer(target: self, action: #selector(Self.panGestureHandler(_:_:)))
            panGesture.delegate = self
            self.addGestureRecognizer(panGesture)
        }
    }

    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for t in self.trackingAreas {
            self.removeTrackingArea(t)
        }
        let trackingArea = NSTrackingArea(
            rect: self.bounds,
            options: [.cursorUpdate, .activeInKeyWindow, .mouseEnteredAndExited, .mouseMoved],
            owner: self,
            userInfo: nil
        )
        self.addTrackingArea(trackingArea)
    }

    private var hasPushedCursor: Bool = false

    // public override func mouseEntered(with event: NSEvent) {
    //     if self.behaviours.contains(.dragWhenNotEditable) && !self.isEditable && self.isEnabled {
    //         if !self.hasPushedCursor {
    //             NSCursor.columnResize.push()
    //             self.hasPushedCursor = true
    //         }
    //     }
    // }

    // public override func mouseExited(with event: NSEvent) {
    //     print("--> mouseExited: \(self.hasPushedCursor)")
    //     if self.hasPushedCursor {
    //         NSCursor.pop()
    //         self.hasPushedCursor = false
    //     }
    // }

    public override func mouseMoved(with event: NSEvent) {
        if self.behaviours.contains(.dragWhenNotEditable) && !self.isEditable && self.isEnabled
            && self.window?.firstResponder != self.textField
        {
            NSCursor.columnResize.set()
            // if !self.hasPushedCursor {
            //     NSCursor.columnResize.push()
            //     self.hasPushedCursor = true
            // }
        }
    }

    @objc
    func clickGestureHandler(_ gesture: NSClickGestureRecognizer) {
        if self.behaviours.contains(.clickBecomeEditableAndFocus) {
            self.isEditable = true
            self.textField.window?.makeFirstResponder(self.textField)
        }
    }

    @objc
    func panGestureHandler(_ gesture: NSPanGestureRecognizer, _ event: NSEvent) {
        guard let delegate = self.delegate else { return }

        let location = self.backgroundView.convert(gesture.location(in: nil), from: nil)

        if gesture.state == .began {
            self.dragStartLocation = location
        }

        delegate.textInputDidDrag(
            self,
            dragData: .init(
                phase: .init(gestureRecognizerState: gesture.state),
                modifiers: .init(flags: event.modifierFlags),
                region: self.backgroundView.bounds,
                translation: gesture.translation(in: nil),
                start: self.dragStartLocation,
                current: location,
            )
        )
    }
    #endif

    // MARK: iOS

    #if os(iOS)
    func initGestures() {
        if self.behaviours.contains(.clickBecomeEditableAndFocus) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Self.tapGestureHandler(_:)))
            tapGesture.delegate = self
            self.addGestureRecognizer(tapGesture)
        }

        if self.behaviours.contains(.dragWhenNotEditable) {
            let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(self.dragGestureHandler(_:)))
            dragGesture.delegate = self
            dragGesture.maximumNumberOfTouches = 1
            dragGesture.minimumNumberOfTouches = 1
            self.addGestureRecognizer(dragGesture)

            let interaction = UIPointerInteraction(delegate: self)
            self.addInteraction(interaction)
        }
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                guard let self else { return }
                if let frameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {

                    let maybeDuration =
                        (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?
                        .doubleValue
                    let duration = maybeDuration ?? 0.4

                    let keyboardFrame = frameValue.cgRectValue
                    MainActor.assumeIsolated {
                        if !self.textField.isEditing { return }

                        let bounds = self.convert(self.bounds, to: nil)
                        let dy = bounds.maxY - keyboardFrame.minY

                        if dy > 0 {
                            self.delegate?.textInputKeyboardWillShow(
                                self,
                                windowVerticalOverlap: dy + 10,
                                animationDuration: duration
                            )
                        }
                    }
                }
            }.store(in: &self.cancellables)
    }

    var cancellables: Set<AnyCancellable> = []

    @objc
    func tapGestureHandler(_ gesture: UITapGestureRecognizer) {
        self.isEditable = true
        self.textField.becomeFirstResponder()
    }

    var isDragging: Bool = false

    @objc
    func dragGestureHandler(_ gesture: UIPanGestureRecognizer) {
        guard let delegate = self.delegate else { return }

        let location = self.backgroundView.convert(gesture.location(in: nil), from: nil)

        if gesture.state == .began {
            self.dragStartLocation = location
            self.isDragging = true
        }

        delegate.textInputDidDrag(
            self,
            dragData: .init(
                phase: .init(gestureRecognizerState: gesture.state),
                modifiers: .init(flags: gesture.modifierFlags),
                region: self.backgroundView.bounds,
                translation: gesture.translation(in: nil),
                start: self.dragStartLocation,
                current: location,
            )
        )

        if gesture.state == .ended || gesture.state == .cancelled {
            self.isDragging = false
        }
    }

    func onEndEditing() {
        if self.behaviours.contains(.submitUnfocus) {
            textField.resignFirstResponder()
        } else if self.behaviours.contains(.submitBecomeNotEditable) {
            textField.resignFirstResponder()
            self.isEditable = false
        }
    }

    @objc
    func onEditingChanged() {
        self.delegate?.textInputDidChange(self)
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
    }
    #endif
}

// MARK: - NSTextFieldEx

#if os(macOS)
final class NSTextFieldEx: NSTextField {
    var didBecomeFirstResponder: (() -> ())?
    var didResignFirstResponder: (() -> ())?

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            self.didBecomeFirstResponder?()
        }
        return result
    }

    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            self.didResignFirstResponder?()
        }
        return result
    }
}

#endif

// MARK: - TextInput + Types

extension TextInput {
    public enum SizingMode: Sendable, Equatable {
        /// The TextInput is drawn with the given fixed width. The `intrinsicContentSize`
        /// will also have this same width.
        case fixedWidth(CGFloat)
        /// The content is drawn with the width filling the bounds of the view. The view's
        /// `intrinsicContentSize` will be the same as with the `textWidth` option.
        case fillWidth
        /// The content will be drawn as to fill the text's width; the `intrinsicContentSize`
        /// will be the size needed for drawing.
        case textWidth
    }

    public struct Behaviors: Sendable, OptionSet {
        public let rawValue: Int

        public static let cancelAbort = Behaviors(rawValue: 1 << 0)
        public static let cancelBecomeNotEditable = Behaviors(rawValue: 1 << 5)
        public static let submitUnfocus = Behaviors(rawValue: 1 << 1)
        public static let submitBecomeNotEditable = Behaviors(rawValue: 1 << 2)
        public static let clickBecomeEditableAndFocus = Behaviors(rawValue: 1 << 3)
        public static let dragWhenNotEditable = Behaviors(rawValue: 1 << 4)

        public static let draggableTextInput: Self = [
            .cancelAbort,
            .cancelBecomeNotEditable,
            .submitBecomeNotEditable,
            .clickBecomeEditableAndFocus,
            .dragWhenNotEditable,
        ]

        public static let `default`: Self = [
            .cancelAbort
        ]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

// MARK: NSGestureRecognizerDelegate
#if os(macOS)
extension TextInput: NSGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: NSGestureRecognizer) -> Bool {
        // if gestureRecognizer is NSClickGestureRecognizer {
        return !self.isEditable
        // } else if gestureRecognizer is NSPanGestureRecognizer {
        //     return self.behaviours.contains(.dragWhenNotEditable) && !self.isEditable
        // }

        // return false
    }

    public func gestureRecognizer(
        _ gestureRecognizer: NSGestureRecognizer,
        shouldAttemptToRecognizeWith event: NSEvent
    ) -> Bool {
        let loc = self.convert(event.locationInWindow, from: nil)
        return self.backgroundView.frame.contains(loc)
    }
}
#endif

// MARK: NSTextFieldDelegate

#if os(macOS)
extension TextInput: NSTextFieldDelegate {
    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            if self.behaviours.contains(.cancelAbort) {
                self.textField.abortEditing()
                // NOTE: This is necessary because it seems there is a bug when
                // using this view inside a NSViewRepresentable, where the text is not correctly
                // restored by `abortEditing`
                self.textField.stringValue = self.textAtEditingStart
            }

            if self.behaviours.contains(.cancelBecomeNotEditable) {
                self.textField.isEditable = false
            }

            self.delegate?.textInputDidCancel(self)

            return true
        }

        return false
    }

    public func controlTextDidChange(_ obj: Notification) {
        self.delegate?.textInputDidChange(self)
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
    }

    public func controlTextDidEndEditing(_ obj: Notification) {
        if self.behaviours.contains(.submitBecomeNotEditable) {
            self.textField.window?.makeFirstResponder(nil)
            self.textField.isEditable = false
        } else if self.behaviours.contains(.submitUnfocus) {
            self.textField.window?.makeFirstResponder(nil)
        }
        Task { @MainActor in

            if self.behaviours.contains(.submitBecomeNotEditable) {
                self.textField.window?.makeFirstResponder(nil)
                self.textField.isEditable = false
            } else if self.behaviours.contains(.submitUnfocus) {
                self.textField.window?.makeFirstResponder(nil)
            }

            self.delegate?.textInputDidEndEditing(self)
        }
    }

    public func controlTextDidBeginEditing(_ obj: Notification) {
        self.textAtEditingStart = self.textField.stringValue
        self.delegate?.textInputDidBeginEditing(self)
    }
}
#endif

// MARK: - UIGestureRecognizerDelegate

#if os(iOS)
extension TextInput: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let loc = self.convert(touch.location(in: nil), from: nil)
        return self.backgroundView.frame.contains(loc)
    }
}
#endif

// MARK: - UITextFieldDelegate

#if os(iOS)
extension TextInput: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.behaviours.contains(.submitUnfocus) || self.behaviours.contains(.submitBecomeNotEditable) {
            textField.endEditing(true)
        }
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.onEndEditing()
        self.delegate?.textInputDidEndEditing(self)
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.textInputDidBeginEditing(self)
    }
}
#endif

#if os(iOS)
extension TextInput: UIPointerInteractionDelegate {

    public func pointerInteraction(
        _ interaction: UIPointerInteraction,
        regionFor request: UIPointerRegionRequest,
        defaultRegion: UIPointerRegion
    ) -> UIPointerRegion? {
        .init(rect: self.backgroundView.frame)
    }

    public func pointerInteraction(
        _ interaction: UIPointerInteraction,
        styleFor region: UIPointerRegion
    ) -> UIPointerStyle? {
        let p = UIBezierPath()

        p.append(.init(roundedRect: .init(x: 0, y: 0, width: 16, height: 4), cornerRadius: 2))
        p.append(.init(ovalIn: .init(x: 14, y: -4, width: 4, height: 4)))
        p.append(.init(ovalIn: .init(x: 14, y: 4, width: 4, height: 4)))
        p.append(.init(ovalIn: .init(x: 18, y: 0, width: 4, height: 4)))

        p.append(.init(ovalIn: .init(x: -2, y: -4, width: 4, height: 4)))
        p.append(.init(ovalIn: .init(x: -2, y: 4, width: 4, height: 4)))
        p.append(.init(ovalIn: .init(x: -6, y: 0, width: 4, height: 4)))

        let points: [CGPoint] = [
            .init(x: 14, y: -2),
            .init(x: 17.4, y: -3.4),
            .init(x: 21.42, y: 0.59),
            .init(x: 21.438, y: 3.388),
            .init(x: 17.422, y: 7.405),
            .init(x: 14, y: 6),
            .init(x: 14, y: 4),
            .init(x: 14, y: 0),
        ]

        let points2: [CGPoint] = points.map({ point in
            CGPoint(x: 16 - point.x, y: point.y)
        })

        let fill = UIBezierPath()
        fill.move(to: points.last!)
        for p in points {
            fill.addLine(to: p)
        }

        let fill2 = UIBezierPath()
        fill2.move(to: points2.last!)
        for p in points2.reversed() {
            fill2.addLine(to: p)
        }

        p.append(fill)
        p.append(fill2)

        return .init(shape: .path(p))
    }

}

#endif

// MARK: - TextInputDelegate

public protocol TextInputDelegate: AnyObject {
    func textInputDidChange(_ textInput: TextInput)
    func textInputDidBeginEditing(_ textInput: TextInput)
    func textInputDidEndEditing(_ textInput: TextInput)
    func textInputDidCancel(_ textInput: TextInput)
    func textInputDidDrag(_ textInput: TextInput, dragData: TextInput.DragData)
    func textInputKeyboardWillShow(_ textInput: TextInput, windowVerticalOverlap: Double, animationDuration: Double)
}

extension TextInput {
    public struct DragData: Sendable, Equatable {
        public var phase: GesturePhase
        public var modifiers: KeyModifiers
        public var region: CGRect
        public var translation: CGPoint
        public var start: CGPoint
        public var current: CGPoint
    }
}

extension TextInputDelegate {
    public func textInputDidChange(_ textInput: TextInput) {}
    public func textInputDidBeginEditing(_ textInput: TextInput) {}
    public func textInputDidEndEditing(_ textInput: TextInput) {}
    public func textInputDidCancel(_ textInput: TextInput) {}
    public func textInputDidDrag(_ textInput: TextInput, dragData: TextInput.DragData) {}
    public func textInputKeyboardWillShow(
        _ textInput: TextInput,
        windowVerticalOverlap: Double,
        animationDuration: Double
    ) {}
}

// MARK: - Style

public struct TextInputStyle: Sendable, Equatable, With {
    public var background: TextInputBackgroundStyle
    public var textColor: PlatformColor?
    public var textColorDisabled: PlatformColor?
    public var insets: Insets
    public var font: PlatformFont?

    public struct Insets: Sendable, Equatable, With {
        public var left: CGFloat
        public var right: CGFloat
        public var top: CGFloat
        public var bottom: CGFloat

        public var horizontalSum: CGFloat { self.left + self.right }
        public var verticalSum: CGFloat { self.top + self.bottom }

        public init(_ value: CGFloat) {
            self.left = value
            self.right = value
            self.top = value
            self.bottom = value
        }

        public init(horizontal: CGFloat, vertical: CGFloat) {
            self.left = horizontal
            self.right = horizontal
            self.top = vertical
            self.bottom = vertical
        }

        public init(
            left: CGFloat = 0.0,
            right: CGFloat = 0.0,
            top: CGFloat = 0.0,
            bottom: CGFloat = 0.0
        ) {
            self.left = left
            self.right = right
            self.top = top
            self.bottom = bottom
        }
    }

    public init(
        background: TextInputBackgroundStyle,
        font: PlatformFont? = nil,
        textColor: PlatformColor? = .primaryLabel,
        textColorDisabled: PlatformColor? = .secondaryLabel,
        insets: Insets
    ) {
        self.background = background
        self.insets = insets
        self.font = font
        self.textColor = textColor
        self.textColorDisabled = textColorDisabled
    }

    public static let `default`: Self = .init(
        background: .default,
        insets: .init(horizontal: 6, vertical: 4)
    )
}

// MARK: - Utils

#if os(macOS)
extension NSTextField {
    public var placeholder: String? {
        get { self.placeholderString }
        set { self.placeholderString = newValue }
    }
}
extension NSFont: @unchecked @retroactive Sendable {}
#endif

// MARK: - Previews

extension TextInput {
    public struct Preview: View {

        @State var text: String = "Hello!!"

        public init() {}

        public var body: some View {
            VStack {
                Representable(behaviours: .draggableTextInput, sizingMode: .fillWidth, text: self.$text)

                Representable(
                    behaviours: [
                        .cancelAbort,
                        .submitUnfocus,
                    ],
                    sizingMode: .fixedWidth(250),
                    text: self.$text
                )

                Representable(behaviours: [], sizingMode: .textWidth, text: self.$text)
                    .disabled(true)

                Text(self.text)
            }
            .padding()
        }
    }

    private struct Representable: PlatformViewRepresentable {

        let behaviours: Behaviors
        let sizingMode: SizingMode
        @Binding var text: String

        func makeView(context: Context) -> TextInput {
            let view = TextInput(behaviours: self.behaviours)
            view.text = "Hello!"
            view.sizingMode = self.sizingMode
            view.placeholder = "Enter text..."
            view.delegate = context.coordinator
            return view
        }

        func updateView(_ view: TextInput, context: Context) {
            if view.sizingMode != self.sizingMode {
                view.sizingMode = self.sizingMode
            }

            if view.text != self.text {
                view.text = self.text
            }

            view.isEnabled = context.environment.isEnabled

            context.coordinator.binding = self.$text
        }

        func makeCoordinator() -> Coordinator {
            .init()
        }

        @MainActor
        class Coordinator: TextInputDelegate {
            func textInputDidDrag(_ textInput: TextInput, dragData: TextInput.DragData) {

            }

            var binding: Binding<String>?

            func textInputDidChange(_ textInput: TextInput) {
                self.binding?.wrappedValue = textInput.text
            }

            func textInputDidEndEditing(_ textInput: TextInput) {
                // self.binding?.wrappedValue = textInput.text
            }

            func textInputDidCancel(_ textInput: TextInput) {
                self.binding?.wrappedValue = textInput.text
            }
        }
    }
}

#Preview {
    TextInput.Preview()
        .padding()
}
