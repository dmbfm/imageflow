//
//  NodeTextField.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 06/08/25.
//

#if os(macOS)

import AppKit
import SwiftUI

public final class NodeTextFieldNSView: NSView, NodeTextFieldProtocol {

    public var text: String {
        didSet {
            if self.label.stringValue != self.text {
                self.label.stringValue = self.text
                self.invalidateIntrinsicContentSize()
            }

            if self.textField.stringValue != self.text {
                self.textField.stringValue = self.text
                self.invalidateIntrinsicContentSize()
            }
        }
    }

    public var onEvent: ((NodeTextFieldEvent) -> ())?

    public var borderColor: NSColor {
        didSet {
            self.setNeedsDisplay()
        }
    }
    public var nodeTextFieldFont: NodeTextFieldFont = .mono {
        didSet {
            self.textField.font = self.font
            self.label.font = self.font
        }
    }

    var font: NSFont {
        .monospacedSystemFont(ofSize: 10, weight: .regular)
    }

    lazy var label: NSTextField = {
        let label = NSTextField(labelWithString: self.text)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = self.font  //.monospacedSystemFont(ofSize: 10, weight: .regular) //.systemFont(ofSize: 10)
        return label
    }()

    lazy var textField: NSTextField = {
        let view = NSTextField()
        view.font = self.font  //.systemFont(ofSize: 10)
        view.translatesAutoresizingMaskIntoConstraints = false
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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer?.backgroundColor = Colors.numberInputBackground.cgColor
        view.layer?.cornerRadius = 4
        view.layer?.cornerCurve = .continuous
        return view
    }()

    struct Style {
        var backgroundInsets: NSEdgeInsets = .init(top: 2, left: 2, bottom: 2, right: 2)
        var labelInsets: NSEdgeInsets = .init(top: 4, left: 6, bottom: 4, right: 6)
    }

    var style = Style()

    init(_ text: String, borderColor: NSColor) {
        self.text = text
        self.borderColor = borderColor
        super.init(frame: .zero)

        self.addSubview(self.backgroundView)
        self.backgroundView.constraintToFill(self, edgeInsets: style.backgroundInsets)
        self.addSubview(self.label)
        self.label.constraintToFill(self, edgeInsets: style.labelInsets)
        self.addSubview(self.textField)
        self.textField.constraintToFill(self, edgeInsets: style.labelInsets)
        self.textField.isHidden = true

        self.wantsLayer = true
        self.layer?.cornerRadius = 6
        self.layer?.cornerCurve = .continuous
        self.layer?.delegate = self
        self.layer?.borderColor = self.borderColor.cgColor
        self.layer?.borderWidth = 0
        self.clipsToBounds = false

        let panGesture = NSPanGestureRecognizer(target: self, action: #selector(Self.panGestureHandler(_:)))
        self.addGestureRecognizer(panGesture)
    }

    @objc
    func panGestureHandler(_ gesture: NSPanGestureRecognizer) {
        let t = gesture.translation(in: nil)
        self.onEvent?(.drag(.init(gestureRecognizerState: gesture.state), t.x, t.y))
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        self.onEvent?(.sizeDidChange)
    }

    public override var intrinsicContentSize: NSSize {
        self.label.intrinsicContentSize + style.labelInsets.size
    }

    public override func mouseDown(with event: NSEvent) {
        self.beginEditing()
    }

    enum State {
        case idle
        case editing
    }

    var state = State.idle

    func beginEditing() {
        if self.state == .idle {
            self.label.isHidden = true
            self.textField.isHidden = false
            self.window?.makeFirstResponder(self.textField)
            self.state = .editing
            self.layer?.borderWidth = 2
            //self.shadow(.init(radius: 4, opacity: 0.75, offset: .init(width: 0, height: -2)))
        }
    }

    func endEditing() {
        if self.state == .editing {
            self.label.isHidden = false
            self.textField.isHidden = true
            self.layer?.borderWidth = 0
            self.shadow(nil)
            self.state = .idle
            self.label.stringValue = self.text
            self.textField.stringValue = self.text
        }
    }

    func cancelEditing() {
        self.endEditing()
        self.invalidateIntrinsicContentSize()
    }
}

extension NodeTextFieldNSView: NSTextFieldDelegate {
    public func controlTextDidChange(_ obj: Notification) {
        self.label.stringValue = self.textField.stringValue
        self.invalidateIntrinsicContentSize()
    }

    public func controlTextDidEndEditing(_ obj: Notification) {
        self.text = self.textField.stringValue
        self.onEvent?(.textDidChange(self.text))
        self.endEditing()
    }

    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            self.textField.abortEditing()
            self.cancelEditing()
            return true
        }

        return false
    }
}

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
