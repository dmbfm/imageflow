#if os(iOS)

import SwiftUI
import UIKit
import Logging
import Design

enum TextFieldExStyle {
    case `default`
    case inspectorDefault
}

struct TextFieldExDragGestureHandler {
    var onChange: (CGSize) -> ()
    var onEnded: (CGSize) -> ()
}

extension EnvironmentValues {
    @Entry var uiFont: UIFont? = nil
    @Entry var textFieldExPlaceholder: String? = nil
    @Entry var textFieldExKeyboardType: UIKeyboardType = .default
    @Entry var textFieldExDidBeginEditing: ((String) -> ())? = nil
    @Entry var textFieldExDidEndEditing: ((String) -> ())? = nil
    @Entry var textFieldExDidChange: ((String) -> ())? = nil
    @Entry var textFieldExInspect: ((UITextField) -> ())? = nil
    @Entry var textFieldExBorderStyle: UITextField.BorderStyle = .none
    @Entry var textFieldExReturnKeyType: UIReturnKeyType = .done
    @Entry var textFieldExClearButton: UITextField.ViewMode = .never
    @Entry var textFieldExClearMode: TextFieldEx.ClearMode = .none
    @Entry var textFieldExUpdatesBinding: Bool = true
    @Entry var textFieldExStyle: TextFieldExStyle = .default
    @Entry var textFieldExBackgroundColor: UIColor? = nil
    @Entry var textFieldExForegroundColor: UIColor? = nil
    @Entry var textFieldExDragGestureHandler: TextFieldExDragGestureHandler? = nil
}


extension View {
    func uiFont(_ font: UIFont? = nil) -> some View {
        self
            .environment(\.uiFont, font)
    }
    
    func textFieldExDragGestureHandler(_ handler: TextFieldExDragGestureHandler?) -> some View {
        self.environment(\.textFieldExDragGestureHandler, handler)
    }
    
    func textFieldExBackgroundColor(_ color: UIColor?) -> some View {
        self.environment(\.textFieldExBackgroundColor, color)
    }
    
    func textFieldExForegroundColor(_ color: UIColor?) -> some View {
        self.environment(\.textFieldExForegroundColor, color)
    }
    
    func textFieldExUpdatesBinding(_ value: Bool) -> some View {
        self.environment(\.textFieldExUpdatesBinding, value)
    }
    
    func textFieldExInspect(_ inspect: ((UITextField) -> ())? = nil) -> some View {
        self.environment(\.textFieldExInspect, inspect)
    }
    
    func textFieldExClearMode(_ value: TextFieldEx.ClearMode) -> some View {
        self.environment(\.textFieldExClearMode, value)
    }
    
    func textFieldExClearButton(_ value: UITextField.ViewMode) -> some View {
        self.environment(\.textFieldExClearButton, value)
    }
    
    func textFieldExPlaceholder(_ text: String?) -> some View {
        self.environment(\.textFieldExPlaceholder, text)
    }
    
    func textFieldExKeyboardType(_ value: UIKeyboardType) -> some View {
        self.environment(\.textFieldExKeyboardType, value)
    }
    
    func textFieldExDidBeginEditing(_ action: @escaping @MainActor (String) -> ()) -> some View {
        self.environment(\.textFieldExDidBeginEditing, action)
    }

    func textFieldExDidEndEditing(_ action: @escaping @MainActor (String) -> ()) -> some View {
        self.environment(\.textFieldExDidEndEditing, action)
    }

    func textFieldExDidChange(_ action: @escaping @MainActor (String) -> ()) -> some View {
        self.environment(\.textFieldExDidChange, action)
    }
    
    func textFieldExBorderStyle(_ style: UITextField.BorderStyle) -> some View {
        self.environment(\.textFieldExBorderStyle, style)
    }
    
    func textFieldExReturnKeyType(_ value: UIReturnKeyType) -> some View {
        self.environment(\.textFieldExReturnKeyType, value)
    }
}

struct TextFieldEx: View {

    @Binding var text: String
    
    @Environment(\.textFieldExStyle) var style
    @Environment(\.colorScheme) var cs
    
    typealias ClearMode = TextFieldExBase.ClearMode
    
    var body: some View {
        switch self.style {
        case .default:
            TextFieldExBase(text: $text)
        case .inspectorDefault:
            TextFieldExBase(text: $text)
//                .padding(.vertical, 4)
//                .padding(.horizontal, 12)
//                .background(cs == .dark ? Color(white: 0.11) : Color(white: 0.82))
//                .background(.ultraThickMaterial)
//                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

struct TextFieldExBase: UIViewRepresentable {
    
    @Binding var text: String
    
    @Environment(\.uiFont) var font
    @Environment(\.autocorrectionDisabled) var autocorrectionDisabled
    @Environment(\.textFieldExPlaceholder) var placeholder
    @Environment(\.textFieldExKeyboardType) var keyboardType
    @Environment(\.textFieldExDidBeginEditing) var didBeginEditing
    @Environment(\.textFieldExDidEndEditing) var didEndEditing
    @Environment(\.textFieldExDidChange) var didChange
    @Environment(\.textFieldExBorderStyle) var borderStyle
    @Environment(\.textFieldExReturnKeyType) var returnKeyType
    @Environment(\.textFieldExClearButton) var clearButton
    @Environment(\.textFieldExClearMode) var clearMode
    @Environment(\.textFieldExInspect) var inspect
    @Environment(\.textFieldExUpdatesBinding) var updatesBinding
    @Environment(\.textFieldExBackgroundColor) var bgColor
    @Environment(\.textFieldExForegroundColor) var fgColor
    @Environment(\.textFieldExDragGestureHandler) var dragGestureHandler
    @Environment(\.multilineTextAlignment) var alignment
    
    var autocorrectionType: UITextAutocorrectionType {
        self.autocorrectionDisabled ? .no : .default
    }
    
    enum ClearMode: Equatable {
        case none
        case onInsert
        case onBeginEditting
        
        var clearOnInsert: Bool {
            self == .onInsert
        }
        
        var clearOnBeginEditting: Bool {
            self == .onBeginEditting
        }
    }

    func makeUIView(context: Context) -> Inner {
        let view = Inner()
        view.text = self.text
        view.delegate = context.coordinator
        view.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
//        view.keyboardType = .numbersAndPunctuation
        view.enablesReturnKeyAutomatically = false
        view.autocorrectionType = .no
        
        view.keyboardType = self.keyboardType
        view.placeholder = self.placeholder
        view.font = self.font
        view.textAlignment = self.alignment.nsTextAlignment
        view.borderStyle = self.borderStyle
        view.returnKeyType = self.returnKeyType
        view.clearButtonMode = self.clearButton
        view.clearsOnInsertion = self.clearMode.clearOnInsert
        view.clearsOnBeginEditing = self.clearMode.clearOnBeginEditting
        view.autocorrectionType = self.autocorrectionType
        view.backgroundColor = self.bgColor
        view.textColor = self.fgColor
        
        if self.dragGestureHandler != nil {
            view.addGestureRecognizer(UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.dragHandler(_:))))
        }
        
        self.inspect?(view)
        
        context.coordinator.text = self.$text
        context.coordinator.updatesBinding = self.updatesBinding
        context.coordinator.didChange = self.didChange
        context.coordinator.didEndEditing = self.didEndEditing
        context.coordinator.didBeginEditing = self.didBeginEditing
        
        return view
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView view: Inner, context: Context) -> CGSize? {
        let proposal = proposal.replacingUnspecifiedDimensions()
        return CGSize(width: min(view.intrinsicContentSize.width, proposal.width), height: view.intrinsicContentSize.height)
    }
    
    func updateUIView(_ view: Inner, context: Context) {
        if view.text != self.text {
            view.text = self.text
        }
        
        if view.font != self.font {
            view.font = self.font
        }
        
        if view.placeholder != self.placeholder {
            view.placeholder = self.placeholder
        }
        
        if view.keyboardType != self.keyboardType {
            view.keyboardType = self.keyboardType
        }
        
        if view.textAlignment != self.alignment.nsTextAlignment {
            view.textAlignment = self.alignment.nsTextAlignment
        }
        
        if view.borderStyle != self.borderStyle {
            view.borderStyle = self.borderStyle
        }
        
        if view.returnKeyType != self.returnKeyType {
            view.returnKeyType = self.returnKeyType
        }
        
        if view.clearButtonMode != self.clearButton {
            view.clearButtonMode = self.clearButton
        }
        
        if view.clearsOnInsertion != self.clearMode.clearOnInsert {
            view.clearsOnInsertion = self.clearMode.clearOnInsert
        }
        
        if view.clearsOnBeginEditing != self.clearMode.clearOnBeginEditting {
            view.clearsOnBeginEditing = self.clearMode.clearOnBeginEditting
        }
        
        if view.autocorrectionType != self.autocorrectionType {
            view.autocorrectionType = self.autocorrectionType
        }
        
        if view.backgroundColor != self.bgColor {
            view.backgroundColor = self.bgColor
        }
        
        if view.textColor != self.fgColor {
            view.textColor = self.fgColor
        }
        
        context.coordinator.text = self.$text
        context.coordinator.updatesBinding = self.updatesBinding
        context.coordinator.didChange = self.didChange
        context.coordinator.didEndEditing = self.didEndEditing
        context.coordinator.didBeginEditing = self.didBeginEditing
        context.coordinator.dragGestureHandler = self.dragGestureHandler
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

extension TextFieldExBase {
    class Coordinator: NSObject, UITextFieldDelegate {
        
        var text: Binding<String>?
        var updatesBinding: Bool = true
        
        var didChange: ((String) -> ())?
        var didBeginEditing: ((String) -> ())?
        var didEndEditing: ((String) -> ())?
        
        var dragGestureHandler: TextFieldExDragGestureHandler?

        func textFieldDidBeginEditing(_ textField: UITextField) {
            log("begin: \(textField.text, default: "")")
            self.didBeginEditing?(textField.text ?? "")
        }
        
        func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            log("end:reason:\(reason): \(textField.text, default: "")")
            self.didEndEditing?(textField.text ?? "")
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            log("shouldReturn")
            textField.endEditing(false)
            return true
        }
        
        func textFieldShouldClear(_ textField: UITextField) -> Bool {
            log("shouldClear")
            return true
        }
        
        @objc
        func textFieldDidChange(_ textField: UITextField) {
            log("change: \(textField.text, default: "")")
            
            if let text = textField.text, self.updatesBinding {
                self.text?.wrappedValue = text
            }
            
            self.didChange?(textField.text ?? "")
        }
        
        @objc
        func dragHandler(_ gesture: UIPanGestureRecognizer) {
            guard let handler = self.dragGestureHandler else { return }
            switch gesture.state {
            case .began, .changed: handler.onChange(gesture.translation(in: nil).cgSize)
            case .ended, .cancelled: handler.onEnded(gesture.translation(in: nil).cgSize)
            default: break
            }
            log("drag:\(gesture.translation(in: nil))")
        }
    }
}

extension TextFieldExBase {
    class Inner: UITextField {
        
        override var keyCommands: [UIKeyCommand]  {[
            .init(input: "\r", modifierFlags: [], action: #selector(Self.enterKeyPressed)),
//            .init(input: "\033", modifierFlags: [], action: #selector(Self.enterKeyPressed)),
        ]}
        
        @objc
        func enterKeyPressed() {
            log("enter!!!")
            self.endEditing(false)
        }
    }
}

extension View {
    func textFieldExStyle(_ style: TextFieldExStyle) -> some View {
        self.environment(\.textFieldExStyle, style)
    }
}

extension TextAlignment {
    var nsTextAlignment: NSTextAlignment {
        switch self {
        case .center: .center
        case .leading: .left
        case .trailing: .right
        }
    }
}


#Preview {
    @Previewable @State var text: String = "3.1415"
    ZStack {
        Color.clear
        VStack {
            TextFieldEx(text: $text)
//                .textFieldExStyle(TextFieldExInspectorStyle())
                .textFieldExUpdatesBinding(false)
                .textFieldExDidEndEditing { value in
                    text = value
                }
            
            TextFieldEx(text: $text)
                .uiFont(.boldSystemFont(ofSize: 22))
                .textFieldExBorderStyle(.roundedRect)
                .textFieldExBackgroundColor(.clear)
                .textFieldExInspect { view in
//                    view.backgroundColor = .clear
//                    view.backgroundColor = .red
                }
            
            Text("value: \(text)")
        }
        .textFieldExStyle(.inspectorDefault)
    }
}

#endif
