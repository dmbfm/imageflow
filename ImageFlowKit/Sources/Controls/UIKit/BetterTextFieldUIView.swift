#if os(iOS)

import UIKit
import SwiftUI
import Logging

public final class BetterTextFieldUIView: UITextField {
    public override var keyCommands: [UIKeyCommand] {
        [
            .init(input: "\r", modifierFlags: [], action: #selector(Self.enterKeyPressed))
            // .init(input: "\033", modifierFlags: [], action: #selector(Self.enterKeyPressed)),
        ]
    }

    @objc
    func enterKeyPressed() {
        self.endEditing(false)
    }

    var currentStyle: BetterTextFieldBase.Style? = nil

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    func update(_ view: BetterTextFieldBase) {
        if view.text != self.text {
            self.text = view.text
        }

        if view.font != self.font {
            self.font = view.font
        }

        if view.placeholder != self.placeholder {
            self.placeholder = view.placeholder
        }

        if view.keyboardType != self.keyboardType, let keyboardType = view.keyboardType {
            self.keyboardType = keyboardType
        }

        if self.textAlignment != view.alignment.nsTextAlignment {
            self.textAlignment = view.alignment.nsTextAlignment
        }

        if self.borderStyle != view.style.borderStyle {
            self.borderStyle = view.style.borderStyle
        }

        if view.returnKeyType != self.returnKeyType {
            self.returnKeyType = view.returnKeyType
        }

        if self.clearButtonMode != view.clearButton {
            self.clearButtonMode = view.clearButton
        }

        if self.clearsOnInsertion != view.clearMode.clearOnInsert {
            self.clearsOnInsertion = view.clearMode.clearOnInsert
        }

        if self.clearsOnBeginEditing != view.clearMode.clearOnBeginEditting {
            self.clearsOnBeginEditing = view.clearMode.clearOnBeginEditting
        }

        if self.autocorrectionType != view.autocorrectionType {
            self.autocorrectionType = view.autocorrectionType
        }

        if self.backgroundColor != view.bgColor {
            self.backgroundColor = view.bgColor
        }

        if self.textColor != view.textColor {
            self.textColor = view.textColor
        }
        
        if self.isEnabled != view.isEditable {
            self.isEnabled = view.isEditable
        }
    }

    func updateStyle(_ style: BetterTextFieldBase.Style) {
    }
}

extension BetterTextFieldUIView {
    public final class Coordinator: NSObject, UITextFieldDelegate {

        var text: Binding<String>?
        var mode: BetterTextFieldBase.InteractionMode = .continuous
        //            var updatesBinding: Bool = true

        var didChange: ((String) -> ())?
        var didBeginEditing: ((String) -> ())?
        var didEndEditing: ((String) -> ())?

        var dragGestureHandler: BetterTextFieldBase.DragGestureHandler?

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            log("begin: \(textField.text, default: "")")
            self.didBeginEditing?(textField.text ?? "")
        }

        public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            log("end:reason:\(reason): \(textField.text, default: "")")
            self.didEndEditing?(textField.text ?? "")
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            log("shouldReturn")
            textField.endEditing(false)
            return true
        }

        public func textFieldShouldClear(_ textField: UITextField) -> Bool {
            log("shouldClear")
            return true
        }

        @objc
        func textFieldDidChange(_ textField: UITextField) {
            log("change: \(textField.text, default: "")")

            if let text = textField.text, self.mode == .continuous {
                self.text?.wrappedValue = text
            }

            self.didChange?(textField.text ?? "")
        }

        @objc
        func dragHandler(_ gesture: UIPanGestureRecognizer) {
            guard let handler = self.dragGestureHandler else { return }
            let shiftDown = gesture.modifierFlags.contains(.shift)
            let optionDown = gesture.modifierFlags.contains(.alternate)
            let commandDown = gesture.modifierFlags.contains(.command)
            let translation = gesture.translation(in: nil).cgSize
            let value = BetterTextFieldBase.DragGestureHandler.Value(
                translation: translation,
                shiftDown: shiftDown,
                commandDown: commandDown,
                optionDown: optionDown
            )
            switch gesture.state {
            case .began, .changed: handler.onChange(value)
            case .ended, .cancelled: handler.onEnded(value)
            default: break
            }
        }
    }
}

#endif
