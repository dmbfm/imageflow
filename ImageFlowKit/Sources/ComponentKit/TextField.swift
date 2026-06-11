import Combine
import Helpers
import XKit

extension NSFont: @unchecked @retroactive Sendable {}

public final class TextField: XView, Rx, WithRef {
    public var style: TextFieldStyle {
        didSet {
            if self.style != oldValue {
                self.inner.font = style.font
                self.inner.padding = style.padding
                self.inner.cornerRadius = style.cornerRadius
                self.setNeedsDisplay()
            }
        }
    }

    public var progress: Double? = nil {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var isEditable: Bool {
        get { self.inner.isEditable }
        set { self.inner.isEditable = newValue }
    }

    public var isEnabled: Bool {
        get { self.inner.isEnabled }
        set { self.inner.isEnabled = newValue }
    }

    public var text: String {
        get { self.inner.text }
        set { self.inner.text = newValue }
    }

    public var placeholderString: String? {
        get { self.inner.placeholderString }
        set { self.inner.placeholderString = newValue }
    }

    public var contentType: NSTextContentType? {
        get { self.inner.contentType }
        set { self.inner.contentType = newValue }
    }

    public var focusable: Bool {
        get { self.inner.focusable }
        set { self.inner.focusable = newValue }
    }

    public var alignment: NSTextAlignment {
        get { self.inner.alignment }
        set { self.inner.alignment = newValue }
    }

    public var unfocusOnCommit: Bool = true

    public var cancellable: Bool = true

    public var publisher: CurrentValueSubject<String, Never>

    public var cancellables: Set<AnyCancellable> = []

    public var isFocused: Bool {
        self.inner.focused
    }

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

    private var inner: InnerTextField

    private var textAtEdittingStart: String = ""

    var _onChange: ((TextField, String) -> ())?
    var _onBeginEditting: ((TextField, String) -> ())?
    var _onEndEditting: ((TextField, String) -> ())?

    init(_ text: String, style: TextFieldStyle = .default) {
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

        self.addSubview(self.inner)
        self.inner.constraintToFillSuperview()

        self.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .vertical)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    public func onChange(_ perform: @escaping (TextField, String) -> ()) -> Self {
        self._onChange = perform
        return self
    }

    @discardableResult
    public func onEndEditting(_ perform: @escaping (TextField, String) -> ()) -> Self {
        self._onEndEditting = perform
        return self
    }

    @discardableResult
    public func onBeginEditting(_ perform: @escaping (TextField, String) -> ()) -> Self {
        self._onBeginEditting = perform
        return self
    }

    @discardableResult
    public func withFont(_ font: XFont) -> Self {
        self.style = self.style.with(\.font, font)
        return self
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

    public func focus() {
        self.inner.window?.makeFirstResponder(self.inner)
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
    public var backgroundColor: XColor = .system.secondaryFill
    public var progressColor: XColor = .system.fill
    public var borderColor: XColor? = .system.fill
    public var cornerRadius: CGFloat = 6
    public var cornerCurve: CALayerCornerCurve = .continuous
    public var padding: CGSize = .init(width: 6, height: 4)
    public var font: XFont = .preferredFont(forTextStyle: .body)

    public static let `default`: Self = .init()

    public init(
        backgroundColor: XColor = .system.secondaryFill,
        borderColor: XColor? = .system.fill,
        progressColor: XColor = .system.fill,
        cornerRadius: CGFloat = 6,
        cornerCurve: CALayerCornerCurve = .continuous,
        padding: CGSize = .init(width: 6, height: 4),
        font: XFont = .preferredFont(forTextStyle: .body)
    ) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
        self.cornerCurve = cornerCurve
        self.padding = padding
        self.progressColor = progressColor
        self.font = font
    }
}

#Preview {
    {
        TextField("Hello!")
            .onChange({ print("change: \($1)") })
            .onBeginEditting({ print("begin: \($1)") })
            .onEndEditting({
                print("end: \($1)")
                // $0.focusable = false
            })
            .with(\.placeholderString, "Insert text...")
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
