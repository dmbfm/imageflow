import Helpers
import SwiftUI

public struct TextInputView: PlatformViewRepresentable {

    @Binding var text: String
    let progress: Double?
    let behaviours: TextInput.Behaviors
    let placeholder: String?
    let doneAction: (() -> ())?
    let cancelAction: (() -> ())?
    let dragAction: ((TextInput.DragData) -> ())?

    @Environment(\.textInputSizingMode) var sizingMode
    @Environment(\.textInputStyle) var style
    @Environment(\.textInputAlignment) var alignment
    #if os(iOS)
    @Environment(\.textInputKeyboardType) var keyboardType
    #endif

    public init(
        _ text: Binding<String>,
        progress: Double? = nil,
        placeholder: String? = nil,
        behaviours: TextInput.Behaviors = .default,
        doneAction: (() -> ())? = nil,
        cancelAction: (() -> ())? = nil,
        dragAction: ((TextInput.DragData) -> ())? = nil,
    ) {
        self._text = text
        self.progress = progress
        self.behaviours = behaviours
        self.placeholder = placeholder
        self.doneAction = doneAction
        self.cancelAction = cancelAction
        self.dragAction = dragAction
    }

    public func makeView(context: Context) -> TextInput {
        let view = TextInput(behaviours: self.behaviours)
        view.sizingMode = self.sizingMode
        view.text = self.text
        view.style = self.style
        view.delegate = context.coordinator
        view.progress = self.progress
        view.alignment = self.alignment
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

        if view.text != self.text {
            view.text = self.text
        }

        if view.style != self.style {
            view.style = self.style
        }

        if view.progress != self.progress {
            view.progress = self.progress
        }

        if view.alignment != self.alignment {
            view.alignment = self.alignment
        }

        #if os(iOS)
        if view.keyboardType != self.keyboardType {
            view.keyboardType = self.keyboardType
        }
        #endif

        context.coordinator.text = self.$text
        context.coordinator.doneAction = self.doneAction
        context.coordinator.cancelAction = self.cancelAction
        context.coordinator.dragAction = self.dragAction
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, view: TextInput, context: Context) -> CGSize? {
        let intrinsicContentSize = view.intrinsicContentSize

        switch proposal {
        case .zero:
            return intrinsicContentSize
        case .infinity:
            // max size
            switch self.sizingMode {
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

        switch self.sizingMode {
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

    public func makeCoordinator() -> Coordinator {
        .init()
    }

    @MainActor
    public class Coordinator: TextInputDelegate {

        var text: Binding<String>?

        var doneAction: (() -> ())?
        var cancelAction: (() -> ())?
        var dragAction: ((TextInput.DragData) -> ())?

        public func textInputDidChange(_ textInput: TextInput) {
            self.text?.wrappedValue = textInput.text
        }

        public func textInputDidCancel(_ textInput: TextInput) {
            self.text?.wrappedValue = textInput.text
            self.cancelAction?()
        }

        public func textInputDidEndEditing(_ textInput: TextInput) {
            self.doneAction?()
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
    @Entry var textInputStyle: TextInputStyle = .default
    @Entry var textInputAlignment: NSTextAlignment = .left
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

                TextInputView($text, placeholder: "Type in something...", behaviours: .draggableTextInput) {
                    print("done!")
                } cancelAction: {
                    print("cancel!")
                } dragAction: { drag in
                    print("drag: \(drag)")
                }
                .textInputStyle(.default.with(\.font, .preferredFont(forTextStyle: .caption2)))

                TextInputView($text)
                    .textInputSizingMode(.textWidth)

                Text("[\(text)]")
            }
            .padding()
        }
    }
}

#Preview {
    TextInputView.Preview()
}
