import SwiftUI
import XViewKit

#if os(macOS)
import AppKit
public typealias BetterTextFieldXView = BetterTextFieldNSView
#endif

#if os(iOS)
import UIKit
public typealias BetterTextFieldXView = BetterTextFieldUIView
#endif

public struct BetterTextFieldBase: XViewRepresentable {

    @Binding var text: String
    @Environment(\.autocorrectionDisabled) var autocorrectionDisabled
    @Environment(\.betterTextFieldBaseStyle) var style
    @Environment(\.betterTextFieldFont) var font
    @Environment(\.betterTextFieldForegroundColor) var textColor
    @Environment(\.betterTextFieldDidBeginEditing) var didBeginEditing
    @Environment(\.betterTextFieldDidEndEditing) var didEndEditing
    @Environment(\.betterTextFieldDidChange) var didChange
    @Environment(\.betterTextFieldCancelAction) var cancelAction
    @Environment(\.betterTextFieldInteractionMode) var mode
    @Environment(\.betterTextFieldIsEditable) var isEditable
    @Environment(\.betterTextFieldPlaceholder) var placeholder
    @Environment(\.multilineTextAlignment) var alignment
    @Environment(\.controlSize) var controlSize
    @Environment(\.betterTextFieldDragGestureHandler) var dragGestureHandler

    #if os(iOS)
    @Environment(\.betterTextFieldKeyboardType) var keyboardType
    @Environment(\.betterTextFieldReturnKeyType) var returnKeyType
    @Environment(\.betterTextFieldClearMode) var clearMode
    @Environment(\.betterTextFieldClearButton) var clearButton
    @Environment(\.betterTextFieldBackgroundColor) var bgColor
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

    public func makeView(context: Context) -> BetterTextFieldXView {
        let view = BetterTextFieldXView()

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

    public func updateView(_ view: BetterTextFieldXView, context: Context) {
        view.update(self)

        context.coordinator.text = self._text
        context.coordinator.mode = self.mode
        context.coordinator.didBeginEditing = self.didBeginEditing
        context.coordinator.didEndEditing = self.didEndEditing
        context.coordinator.didChange = self.didChange
    }

    #if os(iOS)
    public func sizeThatFits(_ proposal: ProposedViewSize, view: BetterTextFieldUIView, context: Context) -> CGSize? {
        let proposal = proposal.replacingUnspecifiedDimensions()
        return CGSize(
            width: proposal.width,
            height: view.intrinsicContentSize.height
        )
    }
    #endif

    #if os(macOS)
    public func sizeThatFits(_ proposal: ProposedViewSize, view: BetterTextFieldNSView, context: Context) -> CGSize? {
        if proposal == .zero {
            return view.intrinsicContentSize
        } else if proposal == .infinity {
            return nil
        } else if proposal == .unspecified {
            return view.intrinsicContentSize
        } else {
            let p = proposal.replacingUnspecifiedDimensions()
            return .init(width: p.width, height: view.intrinsicContentSize.height)
        }
    }
    #endif

    public func makeCoordinator() -> BetterTextFieldXView.Coordinator {
        BetterTextFieldXView.Coordinator()
    }
}

extension BetterTextFieldBase {
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

    public enum ClearMode: Equatable {
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

public extension EnvironmentValues {
    @Entry var betterTextFieldFont: XFont? = nil
    #if os(macOS)
    @Entry var betterTextFieldBaseStyle: BetterTextFieldBase.Style = .rounded
    #else
    @Entry var betterTextFieldBaseStyle: BetterTextFieldBase.Style = .plain
    #endif
    @Entry var betterTextFieldDidBeginEditing: ((String) -> ())? = nil
    @Entry var betterTextFieldDidEndEditing: ((String) -> ())? = nil
    @Entry var betterTextFieldDidChange: ((String) -> ())? = nil
    @Entry var betterTextFieldCancelAction: (() -> ())? = nil
    @Entry var betterTextFieldInteractionMode: BetterTextFieldBase.InteractionMode = .continuous
    @Entry var betterTextFieldIsEditable: Bool = true
    @Entry var betterTextFieldPlaceholder: String? = nil
    @Entry var betterTextFieldForegroundColor: XColor? = nil
    @Entry var betterTextFieldDragGestureHandler: BetterTextFieldBase.DragGestureHandler? = nil

    #if os(iOS)
    @Entry var betterTextFieldKeyboardType: UIKeyboardType? = nil
    @Entry var betterTextFieldReturnKeyType: UIReturnKeyType = .done
    @Entry var betterTextFieldClearButton: UITextField.ViewMode = .never
    @Entry var betterTextFieldClearMode: BetterTextFieldBase.ClearMode = .none
    @Entry var betterTextFieldBackgroundColor: XColor? = nil
    #endif
}

extension View {
    public func betterTextFieldFont(_ font: XFont?) -> some View {
        self.environment(\.betterTextFieldFont, font)
    }

    public func betterTextFieldForegroundColor(_ color: XColor?) -> some View {
        self.environment(\.betterTextFieldForegroundColor, color)
    }

    public func betterTextFieldBaseStyle(_ style: BetterTextFieldBase.Style) -> some View {
        self.environment(\.betterTextFieldBaseStyle, style)
    }

    public func betterTextFieldDidBeginEditing(_ action: @escaping @MainActor (String) -> ()) -> some View {
        self.environment(\.betterTextFieldDidBeginEditing, action)
    }

    public func betterTextFieldDidEndEditing(_ action: @escaping @MainActor (String) -> ()) -> some View {
        self.environment(\.betterTextFieldDidEndEditing, action)
    }

    public func betterTextFieldDidChange(_ action: @escaping @MainActor (String) -> ()) -> some View {
        self.environment(\.betterTextFieldDidChange, action)
    }

    public func betterTextFieldCancelAction(_ action: @escaping @MainActor () -> ()) -> some View {
        self.environment(\.betterTextFieldCancelAction, action)
    }

    public func betterTextFieldInteractionMode(_ mode: BetterTextFieldBase.InteractionMode) -> some View {
        self.environment(\.betterTextFieldInteractionMode, mode)
    }

    public func betterTextFieldIsEditable(_ editable: Bool) -> some View {
        self.environment(\.betterTextFieldIsEditable, editable)
    }

    public func betterTextFieldPlaceholder(_ value: String?) -> some View {
        self.environment(\.betterTextFieldPlaceholder, value)
    }

    public func betterTextFieldDragGestureHandler(_ handler: BetterTextFieldBase.DragGestureHandler) -> some View {
        self.environment(\.betterTextFieldDragGestureHandler, handler)
    }

    #if os(iOS)
    func betterTextFieldClearMode(_ value: BetterTextFieldBase.ClearMode) -> some View {
        self.environment(\.betterTextFieldClearMode, value)
    }

    func betterTextFieldClearButton(_ value: UITextField.ViewMode) -> some View {
        self.environment(\.betterTextFieldClearButton, value)
    }

    func betterTextFieldKeyboardType(_ value: UIKeyboardType) -> some View {
        self.environment(\.betterTextFieldKeyboardType, value)
    }

    func betterTextFieldBackgroundColor(_ color: XColor?) -> some View {
        self.environment(\.betterTextFieldBackgroundColor, color)
    }
    #endif
}

#Preview {
    @Previewable @State var text: String = "Some text..."
    VStack {
        BetterTextFieldBase(text: $text)
        TextField("", text: $text)
    }
    .padding()
}
