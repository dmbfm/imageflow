#if os(macOS)

import AppKit
import SwiftUI
import Logging
import Helpers
import XKit

final class NodeTextFieldNSView: NSView, NodeTextFieldProtocol {

    // MARK: - Exposed Properties

    var text: String {
        didSet {
            var needsResize = false

            if self.label.stringValue != self.text {
                self.label.stringValue = self.text
                needsResize = true
            }

            if self.textField.stringValue != self.text {
                self.textField.stringValue = self.text
                needsResize = true
            }

            self.updateIdleLabel(checkIfIdle: true)

            if needsResize {
                self.resize()
            }
        }
    }

    var progress: CGFloat? {
        get {
            self.backgroundView.progress
        }

        set {
            self.backgroundView.progress = newValue
        }
    }

    var placeholder: String?

    var onEvent: ((NodeTextFieldEvent) -> ())?

    var style: NodeTextFieldStyle {
        didSet {
            self.setNeedsLayout()
            self.setNeedsDisplay()
            self.backgroundView.style = self.style
        }
    }

    var isEditable: Bool {
        get {
            self.state != .nonEditable
        }

        set {
            guard self.isEditable != newValue else { return }

            switch self.state {
            case .idle:
                if !newValue {
                    self.state = .nonEditable
                }
            case .editing:
                if !newValue {
                    self.textField.abortEditing()
                    self.state = .nonEditable
                }
            case .nonEditable:
                if newValue {
                    self.state = .idle
                }
            }
        }
    }

    // MARK: - Private Properties

    fileprivate var state: State {
        didSet {
            if self.state != oldValue {
                self.update()
            }
        }
    }

    fileprivate enum State {
        case idle
        case editing
        case nonEditable
    }

    // MARK: - Subviews and Lazy vars

    lazy var font: NSFont = {
        switch self.style.fontDesign {
        case .monospaced:
            .monospacedSystemFont(ofSize: self.style.fontSize, weight: .regular)
        case .regular:
            .systemFont(ofSize: self.style.fontSize)
        }
    }()

    lazy var label: NSTextField = {
        let label = NSTextField(labelWithString: self.text)
        label.maximumNumberOfLines = 1
        label.font = self.font
        return label
    }()

    lazy var textField: NSTextField = {
        let view = NSTextField()
        view.font = self.font
        view.stringValue = self.text
        view.isBezeled = false
        view.drawsBackground = false
        view.isBordered = false
        view.focusRingType = .none
        view.maximumNumberOfLines = 1
        view.delegate = self
        view.contentType = .password
        return view
    }()

    lazy var backgroundView: BackgroundView = {
        let view = BackgroundView(self.style)
        return view
    }()

    // MARK: - Init

    init(_ text: String, placeholder: String? = nil, isEditable: Bool = true, style: NodeTextFieldStyle = .default) {
        self.text = text
        self.style = style
        self.placeholder = placeholder

        if isEditable {
            self.state = .idle
        } else {
            self.state = .nonEditable
        }

        super.init(frame: .zero)

        self.addSubview(self.backgroundView)
        self.addSubview(self.label)
        self.addSubview(self.textField)

        self.wantsLayer = true
        self.layer?.delegate = self
        self.clipsToBounds = false

        let panGesture = NSPanGestureRecognizer(target: self, action: #selector(Self.panGestureHandler(_:)))
        self.addGestureRecognizer(panGesture)

        self.update()
    }

    public required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Updates

    override var wantsUpdateLayer: Bool {
        true
    }

    override func updateLayer() {
        switch self.state {
        case .idle:
            self.layer?.borderColor = self.style.borderColor.cgColor
            self.layer?.borderWidth = 0
            self.layer?.cornerRadius = self.style.outerCornerRadius
            self.backgroundView.layer?.backgroundColor = self.style.backgroundColor.cgColor
        case .nonEditable:
            self.layer?.borderColor = self.style.borderColor.cgColor
            self.layer?.borderWidth = 0
            self.layer?.cornerRadius = self.style.outerCornerRadius
            self.backgroundView.layer?.backgroundColor = self.style.backgroundColorNonEditable.cgColor
        case .editing:
            self.layer?.borderColor = self.style.borderColor.cgColor
            self.layer?.borderWidth = self.style.borderWidth
            self.layer?.cornerRadius = self.style.outerCornerRadius
            self.backgroundView.layer?.backgroundColor = self.style.backgroundColor.cgColor
        }
    }

    func update() {
        switch self.state {
        case .idle, .nonEditable:
            self.textField.isHidden = true
            self.label.isHidden = false
            self.label.text = self.text
            self.updateIdleLabel()
            self.resize()
        case .editing:
            self.label.stringValue = self.text
            self.label.isHidden = true
            self.textField.isHidden = false
            self.window?.makeFirstResponder(self.textField)
            self.resize()
        }
        self.setNeedsDisplay()
    }

    func updateIdleLabel(checkIfIdle: Bool = false) {
        if self.label.text == "", let placeholder = self.placeholder, !checkIfIdle || self.state == .idle {
            self.label.text = placeholder
            self.label.textColor = .system.tertiaryLabel
        } else {
            self.label.textColor = .system.label
        }
    }

    // MARK: - Layout

    override var isFlipped: Bool {
        true
    }

    public override var intrinsicContentSize: NSSize {
        let str = NSAttributedString(
            string: self.label.text,
            attributes: [
                NSAttributedString.Key.font: self.label.font as Any
            ]
        )
        let height = NSAttributedString(
            string: "X",
            attributes: [
                NSAttributedString.Key.font: self.label.font as Any
            ]
        ).size().height

        let size =
            str.size().minMax(.init(width: 0, height: height), width: .ours, height: .max) + .init(width: 4, height: 0)
        return size.minMax(.init(width: 10, height: 0), width: .max, height: .ours)
            + style.textInsets.size
    }

    override func layout() {
        let size = self.intrinsicContentSize
        let rect = CGRect(origin: .zero, size: size)
        self.backgroundView.frame = rect.insetted(by: self.style.backgroundInsets)
        self.label.frame = rect.insetted(by: self.style.textInsets)
        self.textField.frame = rect.insetted(by: self.style.textInsets)
    }

    func resize() {
        self.invalidateIntrinsicContentSize()
        self.needsLayout = true
        self.onEvent?(.sizeDidChange)
    }

    // MARK: - User Interaction

    @objc
    func panGestureHandler(_ gesture: NSPanGestureRecognizer) {
        guard self.state != .nonEditable else { return }
        let t = gesture.translation(in: nil)
        self.onEvent?(
            .drag(
                .init(
                    phase: gesture.state,
                    dx: t.x,
                    dy: t.y,
                    shiftDown: gesture.modifierFlags.contains(.shift),
                    optionDown: gesture.modifierFlags.contains(.option),
                    commandDown: gesture.modifierFlags.contains(.command),
                )
            )
        )
    }

    public override func mouseDown(with event: NSEvent) {
        if self.state == .idle {
            self.state = .editing
        }
    }
}

// MARK: - NSTextFieldDelegate

extension NodeTextFieldNSView: NSTextFieldDelegate {
    public func controlTextDidChange(_ obj: Notification) {
        self.label.stringValue = self.textField.stringValue
        self.resize()
    }

    public func controlTextDidEndEditing(_ obj: Notification) {
        if self.state == .idle { return }
        self.text = self.textField.stringValue
        self.onEvent?(.textDidChange(self.text))
        self.state = .idle
    }

    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            self.textField.abortEditing()
            self.state = .idle
            return true
        }

        return false
    }
}

// MARK: - CALayerDelegate

extension NodeTextFieldNSView: @preconcurrency CALayerDelegate {
    public func action(for layer: CALayer, forKey event: String) -> (any CAAction)? {
        if event == "borderWidth" || event.starts(with: "shadow") {
            let anim = CABasicAnimation()
            anim.duration = 0.1
            return anim
        }

        return nil
    }
}

extension NodeTextFieldNSView {

    class BackgroundView: NSView {
        var style: NodeTextFieldStyle {
            didSet {
                self.needsDisplay = true
                self.needsLayout = true
            }
        }

        var progress: CGFloat? {
            didSet {
                if self.progress != oldValue {
                    self.progressFillView.isHidden = self.progress == nil
                    self.needsDisplay = true
                    self.needsLayout = true
                }
            }
        }

        init(_ style: NodeTextFieldStyle) {
            self.style = style
            super.init(frame: .zero)
            self.wantsLayer = true
            self.layer?.backgroundColor = self.style.backgroundColor.cgColor
            self.layer?.cornerRadius = self.style.innerCornerRadius
            self.layer?.cornerCurve = .continuous
            self.layer?.masksToBounds = true
            self.addSubview(self.progressFillView)
        }

        lazy var progressFillView: NSView = {
            let view = NSView()
            view.wantsLayer = true
            view.layer?.backgroundColor = self.style.progressFillColor.cgColor
            return view
        }()

        required init?(coder: NSCoder) {
            nil
        }

        override var wantsUpdateLayer: Bool {
            true
        }

        override func updateLayer() {
            self.progressFillView.layer?.backgroundColor = self.style.progressFillColor.cgColor
        }

        override func layout() {
            if let progress = self.progress {
                self.progressFillView.frame = self.bounds
                self.progressFillView.frame.size.width *= progress.clamped(to: 0...1)
                self.progressFillView.frame.size.height = self.style.progressFillHeight
            }
        }
    }
}
#endif
