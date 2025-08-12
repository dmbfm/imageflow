//
//  NodeTextField.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 06/08/25.
//

#if os(macOS)

import AppKit
import SwiftUI
import CommonUtils
import Logging
import Design
import ColorUtils

public final class NodeTextFieldAppKit: NSView {
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

    public var textDidChange: ((String) -> ())?

    public var borderColor: NSColor {
        didSet {

        }
    }

    lazy var label: NSTextField = {
        let label = NSTextField(labelWithString: self.text)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 10)
        return label
    }()

    lazy var textField: NSTextField = {
        let view = NSTextField()
        view.font = .systemFont(ofSize: 10)
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

        self.wantsLayer = true
        self.layer?.cornerRadius = 6
        self.layer?.cornerCurve = .continuous
        self.layer?.delegate = self
        self.layer?.borderColor = self.borderColor.cgColor
        self.layer?.borderWidth = 0
        self.clipsToBounds = false
    }

    public required init?(coder: NSCoder) {
        nil
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
            self.label.removeFromSuperview()
            self.addSubview(self.textField)
            self.textField.constraintToFill(self, edgeInsets: self.style.labelInsets)
            self.window?.makeFirstResponder(self.textField)
            self.state = .editing
            self.layer?.borderWidth = 2
            //            self.shadow(.init(radius: 4, opacity: 0.75, offset: .init(width: 0, height: -2)))
        }
    }

    func endEditing() {
        if self.state == .editing {
            self.textField.removeFromSuperview()
            self.addSubview(self.label)
            self.label.constraintToFill(self, edgeInsets: self.style.labelInsets)
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

extension NodeTextFieldAppKit: NSTextFieldDelegate {
    public func controlTextDidChange(_ obj: Notification) {
        self.label.stringValue = self.textField.stringValue
        self.invalidateIntrinsicContentSize()
    }

    public func controlTextDidEndEditing(_ obj: Notification) {
        self.text = self.textField.stringValue
        self.textDidChange?(self.text)
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

extension NodeTextFieldAppKit: @preconcurrency CALayerDelegate {
    public func action(for layer: CALayer, forKey event: String) -> (any CAAction)? {
        if event == "borderWidth" || event.starts(with: "shadow") {
            let anim = CABasicAnimation()
            anim.duration = 0.1
            return anim
        }

        return nil
    }
}

extension NSEdgeInsets {
    var size: CGSize {
        .init(width: self.left + self.right, height: self.top + self.bottom)
    }
}

extension NodeTextFieldAppKit {

    public struct Preview: NSViewRepresentable {

        @Binding var text: String

        public init(_ text: Binding<String>) {
            self._text = text
        }

        public func makeNSView(context: Context) -> NodeTextFieldAppKit {
            let view = NodeTextFieldAppKit(self.text, borderColor: .systemBlue)
            view.textDidChange = { text in self.text = text }
            return view
        }

        public func updateNSView(_ nsView: NodeTextFieldAppKit, context: Context) {
            if nsView.text != self.text {
                nsView.text = self.text
            }
        }

        public func sizeThatFits(_ proposal: ProposedViewSize, nsView: NSViewType, context: Context) -> CGSize? {
            nsView.intrinsicContentSize
        }
    }
}

#Preview {
    @Previewable @State var text = "Hello!"
    VStack {
        NodeTextFieldAppKit.Preview($text)
        Text(text)
            .fixedSize()
        Button("Reset") {
            text = "Hello!"
        }
        //            .border(.gray)
    }
    .padding(100)
    .background(.white)
}

#endif
