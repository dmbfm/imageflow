//
//  NodeTextField.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 06/08/25.
//

#if os(macOS)

import AppKit
import SwiftUI
import Logging
import Helpers

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

    var placeholder: String?

    var onEvent: ((NodeTextFieldEvent) -> ())?

    var style: NodeTextFieldStyle

    // MARK: - Private Properties

    fileprivate var state: State = .`init`

    fileprivate enum State {
        case `init`
        case idle
        case editing
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
        return view
    }()

    lazy var backgroundView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = self.style.backgroundColor.cgColor
        view.layer?.cornerRadius = self.style.innerCornerRadius
        view.layer?.cornerCurve = .continuous
        return view
    }()

    // MARK: - Init

    init(_ text: String, placeholder: String? = nil, style: NodeTextFieldStyle = .default) {
        self.text = text
        self.style = style
        self.placeholder = placeholder

        super.init(frame: .zero)

        self.addSubview(self.backgroundView)
        self.addSubview(self.label)
        self.addSubview(self.textField)

        self.wantsLayer = true
        self.layer?.delegate = self
        self.clipsToBounds = false

        let panGesture = NSPanGestureRecognizer(target: self, action: #selector(Self.panGestureHandler(_:)))
        self.addGestureRecognizer(panGesture)

        self.transition(to: .idle)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Updates

    fileprivate func transition(to newState: State) {
        switch self.state {
        case .`init`:
            switch newState {
            case .`init`:
                break
            case .editing:
                fatalError("Invalid transition: init -> editing")
            case .idle:
                self.textField.isHidden = true
                self.layer?.borderColor = self.style.borderColor.cgColor
                self.layer?.borderWidth = 0
                self.layer?.cornerRadius = self.style.outerCornerRadius
                self.label.text = self.text
                self.updateIdleLabel()
                self.resize()
            }
            break
        case .idle:
            switch newState {
            case .`init`:
                fatalError("Invalid transition: idle -> init")
            case .idle:
                break
            case .editing:
                self.label.stringValue = self.text
                self.label.isHidden = true
                self.textField.isHidden = false
                self.layer?.borderWidth = self.style.borderWidth
                self.window?.makeFirstResponder(self.textField)
                self.resize()
            }
        case .editing:
            switch newState {
            case .`init`:
                fatalError("Invalid transition: editing -> init")
            case .editing:
                break
            case .idle:
                self.label.isHidden = false
                self.textField.isHidden = true
                self.layer?.borderColor = self.style.borderColor.cgColor
                self.layer?.borderWidth = 0
                self.label.text = self.text
                self.updateIdleLabel()
                self.resize()
            }
        }

        self.state = newState
    }

    func updateIdleLabel(checkIfIdle: Bool = false) {
        if self.label.text == "", let placeholder = self.placeholder, !checkIfIdle || self.state == .idle {
            self.label.text = placeholder
            self.label.textColor = .tertiaryLabel
        } else {
            self.label.textColor = .label
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
            + style.textInsets.platformEdgeInsets.size
    }

    override func layout() {
        let size = self.intrinsicContentSize
        let rect = CGRect(origin: .zero, size: size)
        self.backgroundView.frame = rect.insetted(by: self.style.backgroundInsets.platformEdgeInsets)
        self.label.frame = rect.insetted(by: self.style.textInsets.platformEdgeInsets)
        self.textField.frame = rect.insetted(by: self.style.textInsets.platformEdgeInsets)
    }

    func resize() {
        self.invalidateIntrinsicContentSize()
        self.needsLayout = true
        self.onEvent?(.sizeDidChange)
    }

    // MARK: - User Interaction

    @objc
    func panGestureHandler(_ gesture: NSPanGestureRecognizer) {
        let t = gesture.translation(in: nil)
        self.onEvent?(.drag(.init(gestureRecognizerState: gesture.state), t.x, t.y))
    }

    public override func mouseDown(with event: NSEvent) {
        if self.state == .idle {
            self.transition(to: .editing)
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
        self.transition(to: .idle)
    }

    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            self.textField.abortEditing()
            self.transition(to: .idle)
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

#endif
