import Helpers
import Logging
import SwiftUI

#if os(macOS)
import AppKit

struct TextFieldEx: NSViewRepresentable {
    @Binding var text: String
    @Environment(\.nsFont) var font
    @Environment(\.textFieldExStyle) var style
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

    var allowsCancellation: Bool {
        self.mode == .commit
    }
    init(
        text: Binding<String>
    ) {
        self._text = text
    }

    init<V, P>(
        value: Binding<V>,
        format: P,
        suffix: String? = nil,
    )
    where
        P: ParseableFormatStyle,
        P.FormatOutput == String,
        P.FormatInput == V
    {
        if let suffix {
            self._text = .init(
                get: {
                    format.format(value.wrappedValue) + suffix
                },
                set: { newValue in
                    do {
                        value.wrappedValue = try format.parseStrategy.parse(newValue.trimmingSuffix(suffix))
                    } catch {
                        log("parsing error: \(error)", level: .error)
                    }
                }
            )
        } else {
            self._text = .init(
                get: {
                    format.format(value.wrappedValue)
                },
                set: { newValue in
                    do {
                        value.wrappedValue = try format.parseStrategy.parse(newValue)
                    } catch {
                        log("parsing error: \(error)", level: .error)
                    }
                }
            )
        }
    }

    func makeNSView(context: Context) -> Inner {
        let view = Inner()
        view.delegate = context.coordinator
        view.text = "Hello"
        view.drawsBackground = true
        view.clipsToBounds = false
        view.focusRingType = .none
        view.font = self.font
        view.textColor = self.textColor
        view.contentType = .password
        view.menu = .init()
        view.allowsExpansionToolTips = false
        view.allowsEditingTextAttributes = false
        view.allowsWritingTools = false
        view.allowsWritingToolsAffordance = false
        view.maximumNumberOfLines = 1
        view.isAutomaticTextCompletionEnabled = false
        view.alignment = self.alignment.nsTextAlignment
        view.controlSize = self.controlSize.nsControlSize
        view.isEditable = self.isEditable
        view.placeholderString = self.placeholder
        // view.pla

        self.updateViewStyle(view, context: context)

        return view
    }

    func updateViewStyle(_ view: Inner, context: Context) {
        if context.coordinator.currentStyle != self.style {
            context.coordinator.currentStyle = self.style

            switch self.style {
            case .plain:
                view.isBezeled = false
                view.drawsBackground = false
                view.isBordered = false

            case .square:
                view.isBezeled = false
                view.isBordered = true
                view.drawsBackground = true

            case .rounded:
                view.isBordered = false
                view.bezelStyle = .roundedBezel
                view.isBezeled = true
            }
        }
    }

    func updateNSView(_ view: Inner, context: Context) {
        if view.font != self.font {
            view.font = self.font
        }

        if view.textColor != self.textColor {
            view.textColor = self.textColor
        }

        if view.text != self.text {
            view.text = self.text
        }

        if view.controlSize != self.controlSize.nsControlSize {
            view.controlSize = self.controlSize.nsControlSize
        }

        if view.alignment != self.alignment.nsTextAlignment {
            view.alignment = self.alignment.nsTextAlignment
        }

        if view.allowsCancelation != self.allowsCancellation {
            view.allowsCancelation = self.allowsCancellation
        }

        if view.isEditable != self.isEditable {
            view.isEditable = self.isEditable
        }

        if view.placeholderString != self.placeholder {
            view.placeholderString = self.placeholder
        }

        context.coordinator.text = self._text
        context.coordinator.mode = self.mode
        context.coordinator.didBeginEditing = self.didBeginEditing
        context.coordinator.didEndEditing = self.didEndEditing
        context.coordinator.didChange = self.didChange

        self.updateViewStyle(view, context: context)
    }

    func makeCoordinator() -> Coordinator {
        .init()
    }

    func sizeThatFits(_ proposal: ProposedViewSize, view: Inner, context: Context) -> CGSize? {
        nil
    }

    class Inner: NSTextField {
        var allowsCancelation: Bool = false
        override func cancelOperation(_ sender: Any?) {
            if self.allowsCancelation {
                self.abortEditing()
            }
        }
    }

    @MainActor
    class Coordinator: NSObject, NSTextFieldDelegate {

        var text: Binding<String>?
        var mode: InteractionMode = .continuous
        var currentStyle: Style?
        var didBeginEditing: (() -> ())?
        var didEndEditing: (() -> ())?
        var didChange: (() -> ())?

        func controlTextDidBeginEditing(_ obj: Notification) {
            self.didBeginEditing?()
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            if let view = obj.object as? Inner {
                if self.mode == .commit,
                    let text = self.text
                {
                    text.wrappedValue = view.text
                }
            }

            self.didEndEditing?()
        }

        func controlTextDidChange(_ obj: Notification) {
            if self.mode == .continuous,
                let text = self.text,
                let textField = obj.object as? Inner
            {
                text.wrappedValue = textField.text
            }
            self.didChange?()
        }

        func control(
            _ control: NSControl,
            didFailToFormatString string: String,
            errorDescription error: String?
        ) -> Bool {
            log("\(error, default: "[unknown error]")", level: .error)
            return false
        }

        func control(
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

#Preview {
    @Previewable @State var text: String = "Hello"
    @Previewable @State var number: Int = 10
    @Previewable @State var float: Double = 1.234
    VStack {
        TextFieldEx(text: $text)
            .textFieldExDidBeginEditing {
                log("begin editing! [\(text)]")
            }
            .textFieldExDidEndEditing {
                log("end editing! [\(text)]")
            }
            .textFieldExDidChange {
                print("change! [\(text)]")
            }
            .textFieldExCancelAction {
                print("cancel! [\(text)]")
            }

        TextFieldEx(text: $text)
            .disabled(true)

        TextFieldEx(text: $text)
            .nsFont(.monospacedSystemFont(ofSize: 12, weight: .light))

        TextFieldEx(text: $text)
            .textFieldExStyle(.square)

        TextFieldEx(text: $text)
            .textFieldExStyle(.plain)
            .textFieldExForegroudColor(.systemIndigo)
            .textFieldExInteractionMode(.commit)

        TextFieldEx(value: $number, format: .number)
            .textFieldExInteractionMode(.commit)

        TextFieldEx(value: $float, format: .number.locale(.init(identifier: "en-US")))
            .textFieldExInteractionMode(.commit)

        Divider()

        Text("[\(text)]")
        Text("[\(number)]")
        Text("[\(float)]")
    }
    .padding(50)
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

#if os(iOS)

struct TextFieldEx: View {
    init(
        text: Binding<String>
    ) {
        //        self._text = text
    }

    init<V, P>(
        value: Binding<V>,
        format: P,
        suffix: String? = nil,
    )
    where
        P: ParseableFormatStyle,
        P.FormatOutput == String,
        P.FormatInput == V
    {
    }

    var body: some View {
    }
}

#endif

extension TextFieldEx {
    enum Style: Equatable {
        case rounded
        case square
        case plain
    }

    enum InteractionMode {
        case continuous
        case commit
    }
}

extension EnvironmentValues {
    #if os(macOS)
    @Entry var nsFont: NSFont? = nil
    #endif
    @Entry var textFieldExStyle: TextFieldEx.Style = .rounded
    @Entry var textFieldExForegroundColor: PlatformColor? = nil
    @Entry var textFieldExDidBeginEditing: (() -> ())? = nil
    @Entry var textFieldExDidEndEditing: (() -> ())? = nil
    @Entry var textFieldExDidChange: (() -> ())? = nil
    @Entry var textFieldExCancelAction: (() -> ())? = nil
    @Entry var textFieldExInteractionMode: TextFieldEx.InteractionMode = .continuous
    @Entry var textFieldExIsEditable: Bool = true
    @Entry var textFieldExPlaceholder: String? = nil
}

extension View {
    #if os(macOS)
    func nsFont(_ font: NSFont?) -> some View {
        self.environment(\.nsFont, font)
    }
    #endif

    func textFieldExStyle(_ style: TextFieldEx.Style) -> some View {
        self.environment(\.textFieldExStyle, style)
    }

    func textFieldExForegroudColor(_ color: PlatformColor?) -> some View {
        self.environment(\.textFieldExForegroundColor, color)
    }

    func textFieldExDidBeginEditing(_ action: @escaping @MainActor () -> ()) -> some View {
        self.environment(\.textFieldExDidBeginEditing, action)
    }

    func textFieldExDidEndEditing(_ action: @escaping @MainActor () -> ()) -> some View {
        self.environment(\.textFieldExDidEndEditing, action)
    }

    func textFieldExDidChange(_ action: @escaping @MainActor () -> ()) -> some View {
        self.environment(\.textFieldExDidChange, action)
    }

    func textFieldExCancelAction(_ action: @escaping @MainActor () -> ()) -> some View {
        self.environment(\.textFieldExCancelAction, action)
    }

    func textFieldExInteractionMode(_ mode: TextFieldEx.InteractionMode) -> some View {
        self.environment(\.textFieldExInteractionMode, mode)
    }

    func textFieldExIsEditable(_ editable: Bool) -> some View {
        self.environment(\.textFieldExIsEditable, editable)
    }

    func textFieldExPlaceholder(_ value: String?) -> some View {
        self.environment(\.textFieldExPlaceholder, value)
    }
}
