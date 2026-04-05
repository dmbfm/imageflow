import SwiftUI
import XViewKit

#if os(macOS)
import AppKit
public typealias TextFieldExXView = TextFieldExNSView
#endif

#if os(iOS)
import UIKit
public typealias TextFieldExXView = TextFieldExUIView
#endif

public struct TextFieldEx: XViewRepresentable {

    @Binding var text: String
    @Environment(\.autocorrectionDisabled) var autocorrectionDisabled
    @Environment(\.textFieldExStyle) var style
    @Environment(\.textFieldExFont) var font
    @Environment(\.textFieldExForegroundColor) var textColor
    @Environment(\.textFieldExDidBeginEditing) var didBeginEditing
    @Environment(\.textFieldExDidEndEditing) var didEndEditing
    @Environment(\.textFieldExDidChange) var didChange
    @Environment(\.textFieldExCancelAction) var cancelAction
    @Environment(\.textFieldExInteractionMode) var mode
    @Environment(\.textFieldExIsEditable) var isEditable
    @Environment(\.textFieldExPlaceholder) var placeholder
    @Environment(\.multilineTextAlignment) var alignment
    @Environment(\.controlSize) var controlSize
    @Environment(\.textFieldExDragGestureHandler) var dragGestureHandler
    
    #if os(iOS)
    @Environment(\.textFieldExKeyboardType) var keyboardType
    @Environment(\.textFieldExReturnKeyType) var returnKeyType
    @Environment(\.textFieldExClearMode) var clearMode
    @Environment(\.textFieldExClearButton) var clearButton
    @Environment(\.textFieldExBackgroundColor) var bgColor
    #endif

    var allowsCancellation: Bool {
        self.mode == .commit
    }
    
    #if os(iOS)
    var autocorrectionType: UITextAutocorrectionType {
        self.autocorrectionDisabled ? .no : .default
    }
    #endif
    
    public init(text: Binding<String>) {
        self._text = text
    }

    public func makeView(context: Context) -> TextFieldExXView {
        let view = TextFieldExXView()

        view.font = self.font
        view.textColor = self.textColor
        view.delegate = context.coordinator

        #if os(macOS)
        view.alignment = self.alignment.nsTextAlignment
        view.controlSize = self.controlSize.nsControlSize
        view.isEditable = self.isEditable
        view.placeholderString = self.placeholder
        #endif

        #if os(iOS)
        view.text = self.text
        view.delegate = context.coordinator
        view.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
        //        view.keyboardType = .numbersAndPunctuation
        view.enablesReturnKeyAutomatically = false
        view.autocorrectionType = .no

        if let keyboardType = self.keyboardType {
            view.keyboardType = keyboardType
        }
        view.placeholder = self.placeholder
        view.font = self.font
        view.textAlignment = self.alignment.nsTextAlignment
        view.borderStyle = self.style.borderStyle
        view.returnKeyType = self.returnKeyType
        view.clearButtonMode = self.clearButton
        view.clearsOnInsertion = self.clearMode.clearOnInsert
        view.clearsOnBeginEditing = self.clearMode.clearOnBeginEditting
        view.autocorrectionType = self.autocorrectionType
        view.backgroundColor = self.bgColor
        view.textColor = self.textColor

        if self.dragGestureHandler != nil {
            view.addGestureRecognizer(
                UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.dragHandler(_:)))
            )
        }
        #endif

        return view
    }

    public func updateView(_ view: TextFieldExXView, context: Context) {
        view.update(self)

        context.coordinator.text = self._text
        context.coordinator.mode = self.mode
        context.coordinator.didBeginEditing = self.didBeginEditing
        context.coordinator.didEndEditing = self.didEndEditing
        context.coordinator.didChange = self.didChange
    }
    
#if os(iOS)
    public func sizeThatFits(_ proposal: ProposedViewSize, view: TextFieldExUIView, context: Context) -> CGSize? {
        let proposal = proposal.replacingUnspecifiedDimensions()
        return CGSize(
            width: proposal.width,
            height: view.intrinsicContentSize.height
        )
    }
#endif
    
    #if os(macOS)
    public func sizeThatFits(_ proposal: ProposedViewSize, view: TextFieldExNSView, context: Context) -> CGSize? {
        nil
    }
    #endif
    
    public func makeCoordinator() -> TextFieldExXView.Coordinator {
        TextFieldExXView.Coordinator()
    }
}

extension TextFieldEx {
    public enum Style: Sendable, Equatable {
        case rounded
        case square
        case plain
        
        #if os(iOS)
        var borderStyle: UITextField.BorderStyle {
            switch self {
            case .rounded: .roundedRect
            case .plain: .none
            case .square: .bezel
            }
        }
        #endif
    }

    public enum InteractionMode: Sendable, Equatable {
        case continuous
        case commit
    }

    public struct DragGestureHandler {
        var onChange: (Value) -> ()
        var onEnded: (Value) -> ()

        public struct Value: Equatable {
            public var translation: CGSize
            public var shiftDown: Bool = false
            public var commandDown: Bool = false
            public var optionDown: Bool = false
        }
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

#if os(macOS)
extension ControlSize {
    var nsControlSize: NSControl.ControlSize {
        switch self {
        case .mini:
            .mini
        case .small:
            .small
        case .regular:
            .regular
        case .large:
            .large
        case .extraLarge:
            .extraLarge
        @unknown default:
            .regular
        }
    }
}
#endif

extension EnvironmentValues {
    @Entry var textFieldExFont: XFont? = nil
    #if os(macOS)
    @Entry var textFieldExStyle: TextFieldEx.Style = .rounded
    #else
    @Entry var textFieldExStyle: TextFieldEx.Style = .plain
    #endif
    @Entry var textFieldExDidBeginEditing: ((String) -> ())? = nil
    @Entry var textFieldExDidEndEditing: ((String) -> ())? = nil
    @Entry var textFieldExDidChange: ((String) -> ())? = nil
    @Entry var textFieldExCancelAction: (() -> ())? = nil
    @Entry var textFieldExInteractionMode: TextFieldEx.InteractionMode = .continuous
    @Entry var textFieldExIsEditable: Bool = true
    @Entry var textFieldExPlaceholder: String? = nil
    @Entry var textFieldExForegroundColor: XColor? = nil
    @Entry var textFieldExDragGestureHandler: TextFieldEx.DragGestureHandler? = nil

    #if os(iOS)
    @Entry var textFieldExKeyboardType: UIKeyboardType? = nil
    @Entry var textFieldExReturnKeyType: UIReturnKeyType = .done
    @Entry var textFieldExClearButton: UITextField.ViewMode = .never
    @Entry var textFieldExClearMode: TextFieldEx.ClearMode = .none
    @Entry var textFieldExBackgroundColor: XColor? = nil
    #endif
}

extension View {
    public func textFieldExFont(_ font: XFont?) -> some View {
        self.environment(\.textFieldExFont, font)
    }

    public func textFieldExForegroundColor(_ color: XColor?) -> some View {
        self.environment(\.textFieldExForegroundColor, color)
    }

    public func textFieldExStyle(_ style: TextFieldEx.Style) -> some View {
        self.environment(\.textFieldExStyle, style)
    }

    public func textFieldExDidBeginEditing(_ action: @escaping @MainActor (String) -> ()) -> some View {
        self.environment(\.textFieldExDidBeginEditing, action)
    }

    public func textFieldExDidEndEditing(_ action: @escaping @MainActor (String) -> ()) -> some View {
        self.environment(\.textFieldExDidEndEditing, action)
    }

    public func textFieldExDidChange(_ action: @escaping @MainActor (String) -> ()) -> some View {
        self.environment(\.textFieldExDidChange, action)
    }

    public func textFieldExCancelAction(_ action: @escaping @MainActor () -> ()) -> some View {
        self.environment(\.textFieldExCancelAction, action)
    }

    public func textFieldExInteractionMode(_ mode: TextFieldEx.InteractionMode) -> some View {
        self.environment(\.textFieldExInteractionMode, mode)
    }

    public func textFieldExIsEditable(_ editable: Bool) -> some View {
        self.environment(\.textFieldExIsEditable, editable)
    }

    public func textFieldExPlaceholder(_ value: String?) -> some View {
        self.environment(\.textFieldExPlaceholder, value)
    }

    public func textFieldExDragGestureHandler(_ handler: TextFieldEx.DragGestureHandler) -> some View {
        self.environment(\.textFieldExDragGestureHandler, handler)
    }

    #if os(iOS)
    func textFieldExClearMode(_ value: TextFieldEx.ClearMode) -> some View {
        self.environment(\.textFieldExClearMode, value)
    }

    func textFieldExClearButton(_ value: UITextField.ViewMode) -> some View {
        self.environment(\.textFieldExClearButton, value)
    }

    func textFieldExKeyboardType(_ value: UIKeyboardType) -> some View {
        self.environment(\.textFieldExKeyboardType, value)
    }
    
    func textFieldExBackgroundColor(_ color: XColor?) -> some View {
        self.environment(\.textFieldExBackgroundColor, color)
    }
    #endif
}

#Preview {
    @Previewable @State var text: String = "Some text..."
    VStack {
        TextFieldEx(text: $text)
        TextField("", text: $text)
    }
    .padding()
}
