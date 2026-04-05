#if os(macOS)

import AppKit
import SwiftUI
import Logging

public final class TextFieldExNSView: NSTextField {

    var allowsCancelation: Bool = false

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.drawsBackground = true
        self.clipsToBounds = false
        self.focusRingType = .none
        self.contentType = .password
        self.allowsExpansionToolTips = false
        self.allowsEditingTextAttributes = false
        self.allowsWritingTools = false
        self.allowsWritingToolsAffordance = false
        self.maximumNumberOfLines = 1
        self.isAutomaticTextCompletionEnabled = false
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public override func cancelOperation(_ sender: Any?) {
        if self.allowsCancelation {
            self.abortEditing()
        }
    }

    var currentStyle: TextFieldEx.Style? = nil

    func updateStyle(_ style: TextFieldEx.Style) {
        if self.currentStyle == style { return }

        switch style {
        case .plain:
            self.isBezeled = false
            self.drawsBackground = false
            self.isBordered = false

        case .square:
            self.isBezeled = false
            self.isBordered = true
            self.drawsBackground = true

        case .rounded:
            self.isBordered = false
            self.bezelStyle = .roundedBezel
            self.isBezeled = true
        }

        self.currentStyle = style
    }

    func update(_ view: TextFieldEx) {

        if view.font != self.font {
            self.font = view.font
        }

        if view.textColor != self.textColor {
            self.textColor = view.textColor
        }

        if view.text != self.text {
            self.text = view.text
        }

        if self.controlSize != view.controlSize.nsControlSize {
            self.controlSize = view.controlSize.nsControlSize
        }

        if self.alignment != view.alignment.nsTextAlignment {
            self.alignment = view.alignment.nsTextAlignment
        }

        if self.allowsCancelation != view.allowsCancellation {
            self.allowsCancelation = view.allowsCancellation
        }

        if view.isEditable != self.isEditable {
            self.isEditable = view.isEditable
        }

        if self.placeholderString != view.placeholder {
            self.placeholderString = view.placeholder
        }

        self.updateStyle(view.style)
    }
}

extension TextFieldExNSView {
    @MainActor
    public class Coordinator: NSObject, NSTextFieldDelegate {

        var text: Binding<String>?
        var mode: TextFieldEx.InteractionMode = .continuous
        var currentStyle: TextFieldEx.Style?
        var didBeginEditing: ((String) -> ())?
        var didEndEditing: ((String) -> ())?
        var didChange: ((String) -> ())?

        public func controlTextDidBeginEditing(_ obj: Notification) {
            if let view = obj.object as? NSTextField {
                self.didBeginEditing?(view.text)
            }
        }

        public func controlTextDidEndEditing(_ obj: Notification) {
            if let view = obj.object as? TextFieldExNSView {
                if self.mode == .commit,
                    let text = self.text
                {
                    text.wrappedValue = view.text
                }
                self.didEndEditing?(view.text)
            }

        }

        public func controlTextDidChange(_ obj: Notification) {
                if let textField = obj.object as? TextFieldExNSView
            {
                
                if self.mode == .continuous, let text = self.text {
                    text.wrappedValue = textField.text
                }
                self.didChange?(textField.text)
            }
        }

        public func control(
            _ control: NSControl,
            didFailToFormatString string: String,
            errorDescription error: String?
        ) -> Bool {
            return false
        }

        public func control(
            _ control: NSControl,
            textView: NSTextView,
            completions words: [String],
            forPartialWordRange charRange: NSRange,
            indexOfSelectedItem index: UnsafeMutablePointer<Int>
        ) -> [String] {
            []
        }
    }
}

#endif
