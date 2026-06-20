import Combine
import Helpers
import XKit

/// A Single-lined text input field. Wraps a `NSTextField` with some
/// customizations applied to it.
public final class TextField: XView, Rx, WithRef {

    // MARK: - Public Properties

    /// The TextField's style that configures its overall look.
    public var style: TextFieldStyle {
        didSet {
            if self.style != oldValue {
                self.inner.textColor = self.isEnabled ? self.style.textColor : self.style.disabledTextColor
                self.inner.font = style.font
                self.inner.padding = style.padding
                self.inner.cornerRadius = style.cornerRadius
                self.backgroundView.style = self.style
                self.setNeedsDisplay()
            }
        }
    }

    /// When this value is non-nil, the TextField's background will work as a
    /// progress indicator, filling the background with a different color, up to
    /// a position proportional to the value of `progress` taken as a percentage
    /// (that is, as a value between 0 and 1.) The filling color is given by
    /// `TextFieldStyle.progressColor`
    public var progress: Double? = nil {
        didSet {
            self.backgroundView.progress = self.progress
        }
    }

    /// When set to `false`, the user can't edit the text in this `TextField`.
    public var isEditable: Bool {
        get { self.inner.isEditable }
        set { self.inner.isEditable = newValue }
    }

    /// When set to `false` this view will ignore any mouse events. It will also
    /// draw the view in a slightly different manner to indicate this, by
    /// drawing the text using the `disabledTextColor` property of the current
    /// `style`.
    public var isEnabled: Bool {
        get { self.inner.isEnabled }
        set {
            self.inner.isEnabled = newValue
            self.inner.textColor = self.inner.isEnabled ? self.style.textColor : self.style.disabledTextColor
        }
    }

    /// The current text being displayed by the view.
    public var text: String {
        get { self.inner.text }
        set { self.inner.text = newValue }
    }

    /// The placeholder text to be displayed when `text` is an empty string.
    public var placeholderString: String? {
        get { self.inner.placeholderString }
        set { self.inner.placeholderString = newValue }
    }

    /// The content type of the text field (see `NSTextContentType`).
    public var contentType: NSTextContentType? {
        get { self.inner.contentType }
        set { self.inner.contentType = newValue }
    }

    /// Whether the `TextField` can be focused automatically (e.g., by tab-cycle
    /// navigation). Even when set to `false` the user can still focus the text
    /// field directly, e.g, by clicking on it using the mouse.
    public var focusable: Bool {
        get { self.inner.focusable }
        set { self.inner.focusable = newValue }
    }

    /// The alignment of the text inside the view.
    public var alignment: NSTextAlignment {
        get { self.inner.alignment }
        set { self.inner.alignment = newValue }
    }

    /// When set to `true`, the text field will un-focus itself when the user
    /// commits a change, e.g., by pressing the return key.
    public var unfocusOnCommit: Bool = true

    /// It `true`, the user can cancel the current edit by pressing the escape key.
    public var cancellable: Bool = true

    /// Publishes the current `text` value.
    public var publisher: CurrentValueSubject<String, Never>

    /// Required by the `Rx` protocol.
    public var cancellables: Set<AnyCancellable> = []

    /// If true, the text field has input focus.
    public var isFocused: Bool {
        self.inner.focused
    }

    /// The type of focus ring drawn by the text field.
    public override var focusRingType: NSFocusRingType {
        get { self.inner.focusRingType }
        set { self.inner.focusRingType = newValue }
    }

    public override var intrinsicContentSize: CGSize {
        .init(
            width: Self.noIntrinsicMetric,
            height: self.inner.intrinsicContentSize.height
        )
    }

    // MARK: - Private Properties

    private var inner: InnerTextField
    private var textAtEdittingStart: String = ""
    private var _onChange: ((TextField, String) -> ())?
    private var _onBeginEditting: ((TextField, String) -> ())?
    private var _onEndEditting: ((TextField, String) -> ())?

    private lazy var backgroundView: BackgroundView = {
        let view = BackgroundView(style: self.style, progress: self.progress)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Initialization

    public init(_ text: String, style: TextFieldStyle = .default) {
        self.inner = InnerTextField()
        self.style = style
        self.publisher = .init(text)

        super.init(frame: .zero)

        self.wantsLayer = true
        self.clipsToBounds = false

        self.inner.text = text
        self.inner.clipsToBounds = false
        self.inner.isBordered = false
        self.inner.isBezeled = false
        self.inner.drawsBackground = false
        self.inner.translatesAutoresizingMaskIntoConstraints = false
        self.inner.padding = self.style.padding
        self.inner.cornerRadius = self.style.cornerRadius
        self.inner.wantsLayer = true
        self.inner.focusRingType = .none
        self.inner.usesSingleLineMode = true
        self.inner.lineBreakMode = .byTruncatingTail
        self.inner.delegate = self
        self.inner.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        self.inner.textColor = self.style.textColor

        self.addSubview(self.backgroundView)
        self.backgroundView.constraintToFillSuperview()
        self.addSubview(self.inner)
        self.inner.constraintToFillSuperview()

        self.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .vertical)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Sets a closure to be called wheneve the user changes the value of the
    /// text field by editing it.
    /// - Parameter perform: The closure, whose parameters are the sending
    /// `TextField` and the text `String` value.
    /// - Returns: A `Self` reference for chaining.
    @discardableResult
    public func onChange(_ perform: @escaping (TextField, String) -> ()) -> Self {
        self._onChange = perform
        return self
    }

    /// Sets a closure to be called wheneve the user finished editing the text field.
    /// - Parameter perform: The closure to be called whose parameters are the
    /// sending `TextField` the text `String` value.
    /// - Returns: A `Self` reference for chaining.
    @discardableResult
    public func onEndEditting(_ perform: @escaping (TextField, String) -> ()) -> Self {
        self._onEndEditting = perform
        return self
    }

    /// Sets a closure to be called wheneve the user begins editing the text field.
    /// - Parameter perform: The closure to be called whose parameters are the
    /// sending `TextField` the text `String` value.
    /// - Returns: A `Self` reference for chaining.
    @discardableResult
    public func onBeginEditting(_ perform: @escaping (TextField, String) -> ()) -> Self {
        self._onBeginEditting = perform
        return self
    }

    /// Sets the font used to draw the text.
    /// - Parameter font: The font
    /// - Returns: A `Self` reference for chaining.
    @discardableResult
    public func withFont(_ font: XFont) -> Self {
        self.style = self.style.with(\.font, font)
        return self
    }

    /// Makes this text field become focused. Works even if `focusable` is `false`.
    public func focus() {
        self.inner.window?.makeFirstResponder(self.inner)
    }
}

class BackgroundView: XView {

    var style: TextFieldStyle {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var progress: Double? {
        didSet {
            self.setNeedsDisplay()
        }
    }

    lazy var fillLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = CGPath(rect: .init(origin: .zero, size: .init(width: 100, height: 30)), transform: nil)
        layer.isHidden = true
        return layer
    }()

    public override func draw(_ dirtyRect: NSRect) {
        self.withLayer({ layer in

            if self.fillLayer.superlayer != layer {
                layer.addSublayer(self.fillLayer)
            }

            layer.backgroundColor = self.style.backgroundColor.cgColor
            layer.borderWidth = 1
            layer.borderColor = self.style.borderColor?.cgColor
            layer.cornerRadius = self.style.cornerRadius
            layer.cornerCurve = self.style.cornerCurve

            if let progress = self.progress {
                self.fillLayer.isHidden = false
                self.fillLayer.path = .init(
                    rect: .init(x: 0, y: 0, width: self.bounds.width * progress, height: self.bounds.height),
                    transform: nil
                )
                self.fillLayer.fillColor = self.style.progressColor.cgColor
            } else {
                self.fillLayer.isHidden = true
            }

        })
    }

    init(style: TextFieldStyle, progress: Double? = nil) {
        self.style = style
        self.progress = progress

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TextField: NSTextFieldDelegate {

    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.cancelOperation(_:)) && self.cancellable {
            self.inner.abortEditing()
            self._onEndEditting?(self, self.text)
            return true
        }

        return false
    }

    public func controlTextDidChange(_ obj: Notification) {
        print("first? \(self.inner.focused)")
        self._onChange?(self, self.text)
        self.publisher.send(self.text)
    }

    public func controlTextDidEndEditing(_ obj: Notification) {
        if self.unfocusOnCommit {
            let wasEditable = self.inner.isEditable
            self.inner.isEditable = false
            Task {
                self.window?.makeFirstResponder(nil)
                self.inner.isEditable = wasEditable
                self._onEndEditting?(self, self.text)
            }
        } else {
            self._onEndEditting?(self, self.text)
        }
    }

    public func controlTextDidBeginEditing(_ obj: Notification) {
        print("!!!!!!!!!!!! begin")
        self._onBeginEditting?(self, self.text)
    }

    public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        return true
    }
}

class InnerTextField: NSTextField {

    public var padding: CGSize {
        get { self.customCell.padding }
        set {
            self.customCell.padding = newValue
            self.needsDisplay = true
        }
    }

    public var cornerRadius: CGFloat {
        get { self.customCell.cornerRadius }
        set { self.customCell.cornerRadius = newValue }
    }

    public var focusable: Bool = true {
        didSet {
            print("!!!!!!!!!! \(self.focused)")
            if !self.focusable && self.focused {
                Task {
                    self.window?.makeFirstResponder(nil)
                }
            }
        }
    }

    public var focused: Bool {
        if let currentEditor = self.currentEditor() {
            currentEditor == self.window?.firstResponder
        } else {
            false
        }
    }

    var customCell: CustomTextFieldCell {
        self.cell! as! CustomTextFieldCell
    }

    override var acceptsFirstResponder: Bool {
        self.focusable
    }

    override class var cellClass: AnyClass? {
        get { CustomTextFieldCell.self }
        set {}
    }
}

class CustomTextFieldCell: NSTextFieldCell {

    public var padding = CGSize(
        width: 4.0,
        height: 4.0
    )

    public var cornerRadius: CGFloat = 10

    private var dx: CGFloat { self.padding.width }
    private var dy: CGFloat { self.padding.height }

    override func cellSize(forBounds rect: NSRect) -> NSSize {
        var size = super.cellSize(forBounds: rect)
        size.height += (self.padding.height * 2)
        return size
    }

    override func titleRect(forBounds rect: NSRect) -> NSRect {
        rect.insetBy(dx: self.padding.width, dy: self.padding.height)
    }

    override func drawFocusRingMask(withFrame cellFrame: NSRect, in controlView: NSView) {
        NSBezierPath(
            roundedRect: cellFrame.insetBy(dx: 2, dy: 0),
            xRadius: self.cornerRadius,
            yRadius: self.cornerRadius
        ).fill()
    }

    override func edit(
        withFrame rect: NSRect,
        in controlView: NSView,
        editor textObj: NSText,
        delegate: Any?,
        event: NSEvent?
    ) {
        let insetRect = rect.insetBy(dx: self.padding.width, dy: self.padding.height)
        super.edit(withFrame: insetRect, in: controlView, editor: textObj, delegate: delegate, event: event)
    }

    override func select(
        withFrame rect: NSRect,
        in controlView: NSView,
        editor textObj: NSText,
        delegate: Any?,
        start selStart: Int,
        length selLength: Int
    ) {
        let insetRect = rect.insetBy(dx: self.padding.width, dy: self.padding.height)
        super.select(
            withFrame: insetRect,
            in: controlView,
            editor: textObj,
            delegate: delegate,
            start: selStart,
            length: selLength
        )
    }

    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        let insetRect = cellFrame.insetBy(dx: self.padding.width, dy: self.padding.height)
        super.drawInterior(withFrame: insetRect, in: controlView)
    }
}

public struct TextFieldStyle: Sendable, Equatable, With {
    public var textColor: XColor
    public var disabledTextColor: XColor
    public var backgroundColor: XColor
    public var progressColor: XColor
    public var borderColor: XColor?
    public var cornerRadius: CGFloat
    public var cornerCurve: CALayerCornerCurve
    public var padding: CGSize
    public var font: XFont

    public static let `default`: Self = .init()

    public init(
        textColor: XColor = .system.label,
        disabledTextColor: XColor = .system.secondaryLabel,
        backgroundColor: XColor = .system.secondaryFill,
        borderColor: XColor? = .system.fill,
        progressColor: XColor = .system.fill,
        cornerRadius: CGFloat = 6,
        cornerCurve: CALayerCornerCurve = .continuous,
        padding: CGSize = .init(width: 6, height: 4),
        font: XFont = .preferredFont(forTextStyle: .body)
    ) {
        self.textColor = textColor
        self.disabledTextColor = disabledTextColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
        self.cornerCurve = cornerCurve
        self.padding = padding
        self.progressColor = progressColor
        self.font = font
    }
}

#if os(macOS)
extension NSFont: @unchecked @retroactive Sendable {}
#endif

#Preview {
    {
        TextField("Hello!")
            .onChange({ print("change: \($1)") })
            .onBeginEditting({ print("begin: \($1)") })
            .onEndEditting({
                print("end: \($1)")
            })
            .with(\.placeholderString, "Insert text...")
            .constrainingWidth(toConstant: 120)
    }()
}

#Preview("Disabled") {
    {
        TextField("Hello!")
            .onChange({ print("change: \($1)") })
            .onBeginEditting({ print("begin: \($1)") })
            .onEndEditting({
                print("end: \($1)")
            })
            .with(\.placeholderString, "Insert text...")
            .with(\.isEnabled, false)
            .constrainingWidth(toConstant: 120)
    }()
}

#Preview("Progress") {
    {
        TextField("Hello!")
            .onChange({ print("change: \($1)") })
            .onBeginEditting({ print("begin: \($1)") })
            .onEndEditting({
                print("end: \($1)")
            })
            .with(\.placeholderString, "Insert text...")
            .with(\.progress, 0.45)
            .constrainingWidth(toConstant: 120)
    }()
}
