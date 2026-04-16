import Helpers
import SwiftUI

public struct TextInputView: PlatformViewRepresentable {

    // @Binding var text: String
    var textBinding: Binding<String>?
    var text: String
    let progress: Double?
    let behaviours: TextInput.Behaviors
    let placeholder: String?
    let onChangeAction: ((Change) -> ())?
    let cancelAction: (() -> ())?
    let dragAction: ((TextInput.DragData) -> ())?

    @Environment(\.textInputSizingMode) var sizingMode
    @Environment(\.textInputStyle) var style
    @Environment(\.textInputAlignment) var alignment
    #if os(iOS)
    @Environment(\.textInputKeyboardType) var keyboardType
    #endif

    public struct Change {
        public var newValue: String
        public var oldValue: String?
        public var commit: Bool
        public init(newValue: String, oldValue: String?, commit: Bool) {
            self.newValue = newValue
            self.oldValue = oldValue
            self.commit = commit
        }
    }

    public init(
        _ text: Binding<String>,
        progress: Double? = nil,
        placeholder: String? = nil,
        behaviours: TextInput.Behaviors = .default,
        onChangeAction: ((Change) -> ())? = nil,
        cancelAction: (() -> ())? = nil,
        dragAction: ((TextInput.DragData) -> ())? = nil,
    ) {
        self.text = ""
        self.textBinding = text
        self.progress = progress
        self.behaviours = behaviours
        self.placeholder = placeholder
        self.onChangeAction = onChangeAction
        self.cancelAction = cancelAction
        self.dragAction = dragAction
    }

    public init(
        _ text: String,
        progress: Double? = nil,
        placeholder: String? = nil,
        behaviours: TextInput.Behaviors = .default,
        onChangeAction: ((Change) -> ())? = nil,
        cancelAction: (() -> ())? = nil,
        dragAction: ((TextInput.DragData) -> ())? = nil,
    ) {
        self.text = text
        self.progress = progress
        self.behaviours = behaviours
        self.placeholder = placeholder
        self.onChangeAction = onChangeAction
        self.cancelAction = cancelAction
        self.dragAction = dragAction
    }

    public func makeView(context: Context) -> TextInput {
        let view = TextInput(behaviours: self.behaviours)
        view.sizingMode = self.sizingMode
        view.text = self.text
        view.style = self.style ?? .default
        view.delegate = context.coordinator
        view.progress = self.progress
        view.alignment = self.alignment ?? .left
        #if os(iOS)
        view.keyboardType = self.keyboardType
        #endif
        return view
    }

    public func updateView(_ view: TextInput, context: Context) {
        if view.placeholder != self.placeholder {
            view.placeholder = self.placeholder
        }

        if view.sizingMode != self.sizingMode {
            view.sizingMode = self.sizingMode
        }

        if let textBinding = self.textBinding {
            if view.text != textBinding.wrappedValue {
                view.text = textBinding.wrappedValue
            }
        } else if view.text != self.text {
            view.text = self.text
        }

        if view.style != (self.style ?? .default) {
            view.style = self.style ?? .default
        }

        if view.progress != self.progress {
            view.progress = self.progress
        }

        if view.alignment != (self.alignment ?? .left) {
            view.alignment = self.alignment ?? .left
        }

        #if os(iOS)
        if view.keyboardType != self.keyboardType {
            view.keyboardType = self.keyboardType
        }
        #endif

        context.coordinator.text = self.textBinding
        context.coordinator.onChangeAction = self.onChangeAction
        context.coordinator.cancelAction = self.cancelAction
        context.coordinator.dragAction = self.dragAction
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, view: TextInput, context: Context) -> CGSize? {
        Self.sizeThatFitsCommon(proposal, view: view, sizingMode: self.sizingMode)
    }

    public func makeCoordinator() -> Coordinator {
        .init()
    }

    @MainActor
    public class Coordinator: TextInputDelegate {

        var text: Binding<String>?

        var onChangeAction: ((Change) -> ())?
        var cancelAction: (() -> ())?
        var dragAction: ((TextInput.DragData) -> ())?

        public func textInputDidChange(_ textInput: TextInput) {
            self.text?.wrappedValue = textInput.text
            self.onChangeAction?(.init(newValue: textInput.text, oldValue: textInput.textAtEditingStart, commit: false))
        }

        public func textInputDidCancel(_ textInput: TextInput) {
            self.text?.wrappedValue = textInput.text
            self.onChangeAction?(.init(newValue: textInput.text, oldValue: nil, commit: false))
            self.cancelAction?()
        }

        public func textInputDidEndEditing(_ textInput: TextInput) {
            self.onChangeAction?(.init(newValue: textInput.text, oldValue: textInput.textAtEditingStart, commit: true))
        }

        public func textInputDidDrag(_ textInput: TextInput, dragData: TextInput.DragData) {
            self.dragAction?(dragData)
        }
    }
}

extension TextInputView {
    public enum UpdateMode {
        case binding
        case callback
    }
}

public extension EnvironmentValues {
    @Entry var textInputSizingMode: TextInput.SizingMode = .fillWidth
    @Entry var textInputStyle: TextInputStyle? = nil
    @Entry var textInputAlignment: NSTextAlignment? = nil
    #if os(iOS)
    @Entry var textInputKeyboardType: UIKeyboardType = .default
    #endif
}

public extension View {
    func textInputSizingMode(_ mode: TextInput.SizingMode) -> some View {
        self.environment(\.textInputSizingMode, mode)
    }

    func textInputStyle(_ style: TextInputStyle) -> some View {
        self.environment(\.textInputStyle, style)
    }

    func textInputAlignment(_ alignment: NSTextAlignment) -> some View {
        self.environment(\.textInputAlignment, alignment)
    }

    #if os(iOS)
    func textInputKeyboardType(_ keyboardType: UIKeyboardType) -> some View {
        self.environment(\.textInputKeyboardType, keyboardType)
    }
    #endif
}

public extension TextInputView {
    struct Preview: View {
        @State var text: String = ""

        public init() {}

        public var body: some View {
            VStack(alignment: .leading) {
                TextInputView($text)
                    #if os(iOS)
                .textInputKeyboardType(.numbersAndPunctuation)
                    #endif

                TextInputView($text, progress: 0.82)
                    .textInputAlignment(.right)

                // TextInputView($text, placeholder: "Type in something...", behaviours: .draggableTextInput) {
                //     print("done!")
                // } cancelAction: {
                //     print("cancel!")
                // } dragAction: { drag in
                //     print("drag: \(drag)")
                // }
                // .textInputStyle(.default.with(\.font, .preferredFont(forTextStyle: .caption2)))

                TextInputView($text)
                    .textInputSizingMode(.textWidth)

                Text("[\(text)]")
            }
            .padding()
        }
    }
}

extension TextInputView {
    @MainActor
    static func sizeThatFitsCommon(
        _ proposal: ProposedViewSize,
        view: TextInput,
        sizingMode: TextInput.SizingMode,
    ) -> CGSize? {
        let intrinsicContentSize = view.intrinsicContentSize

        switch proposal {
        case .zero:
            return intrinsicContentSize
        case .infinity:
            // max size
            switch sizingMode {
            case .fixedWidth:
                return intrinsicContentSize
            case .fillWidth:
                return .init(width: intrinsicContentSize.height, height: .infinity)
            case .textWidth:
                return intrinsicContentSize
            }
        case .unspecified:
            return intrinsicContentSize
        default:
            break
        }

        let proposal = proposal.replacingUnspecifiedDimensions()

        switch sizingMode {
        case .fillWidth:
            return .init(width: proposal.width, height: intrinsicContentSize.height)
        case .fixedWidth(let width):
            if proposal.width > width {
                return intrinsicContentSize
            } else {
                return .init(width: proposal.width, height: intrinsicContentSize.height)
            }
        case .textWidth:
            if proposal.width > intrinsicContentSize.width {
                return intrinsicContentSize
            } else {
                return .init(width: proposal.width, height: intrinsicContentSize.height)
            }
        }
    }
}

#Preview {
    TextInputView.Preview()
}
