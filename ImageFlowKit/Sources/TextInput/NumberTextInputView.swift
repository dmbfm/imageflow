import Helpers
import SwiftUI

public struct NumberTextInputView: PlatformViewRepresentable {

    var value: Double
    var bindedValue: Binding<Double>?
    var dragConfiguration: NumberInputController.DragConfiguration
    var isDragging: Binding<Bool>?
    var onChange: ((NumberInputController.Change) -> ())?

    var effectiveStyle: TextInputStyle {
        // self.style ?? .default.with(\.insets, .init(horizontal: 10, vertical: 8))
        self.style ?? .default
    }
    
    public init(
        _ value: Double,
        isDragging: Binding<Bool>? = nil,
        dragConfiguration: NumberInputController.DragConfiguration = .free(
            .init(sensitivity: .init(), fractionalDigits: 2)
        ),
        onChange: ((NumberInputController.Change) -> ())? = nil
    ) {
        self.value = value
        self.dragConfiguration = dragConfiguration
        self.bindedValue = nil
        self.isDragging = isDragging
        self.onChange = onChange
    }

    public init(
        _ value: Binding<Double>,
        isDragging: Binding<Bool>? = nil,
        dragConfiguration: NumberInputController.DragConfiguration = .free(
            .init(sensitivity: .init(), fractionalDigits: 2)
        ),
        onChange: ((NumberInputController.Change) -> ())? = nil
    ) {
        self.value = 0.0
        self.dragConfiguration = dragConfiguration
        self.bindedValue = value
        self.isDragging = isDragging
        self.onChange = onChange
    }

    @Environment(\.textInputStyle) var style
    @Environment(\.textInputSizingMode) var sizingMode
    @Environment(\.textInputAlignment) var alignment
    #if os(iOS)
    @Environment(\.numberTextInputKeyboardType) var keyboardType
    #endif

    public func makeView(context: Context) -> TextInput {
        let coordinator = context.coordinator

        coordinator.controller = .init(self.effectiveStyle)
        coordinator.controller.delegate = coordinator
        return coordinator.controller.view
    }

    public func updateView(_ view: TextInput, context: Context) {
        if let controller = context.coordinator.controller {

            if let bindedValue = self.bindedValue {
                if controller.value != bindedValue.wrappedValue {
                    controller.value = bindedValue.wrappedValue
                }
            } else {
                if controller.value != self.value {
                    controller.value = self.value
                }
            }

            if controller.style != self.effectiveStyle {
                controller.style = self.effectiveStyle
            }

            if controller.sizingMode != self.sizingMode {
                controller.sizingMode = self.sizingMode
            }

            if controller.alignment != (self.alignment ?? .right) {
                controller.alignment = self.alignment ?? .right
            }

            if controller.dragConfiguration != self.dragConfiguration {
                controller.dragConfiguration = self.dragConfiguration
            }

            #if os(iOS)
            if controller.keyboardType != self.keyboardType ?? .numbersAndPunctuation {
                controller.keyboardType = self.keyboardType  ?? .numbersAndPunctuation
            }
            #endif
        }

        context.coordinator.onChange = self.onChange
        context.coordinator.bindedValue = self.bindedValue
        context.coordinator.isDragging = self.isDragging
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, view: TextInput, context: Context) -> CGSize? {
        TextInputView.sizeThatFitsCommon(proposal, view: view, sizingMode: self.sizingMode)
    }

    public func makeCoordinator() -> Coordinator {
        .init()
    }

    public class Coordinator: NumberTextInputDelegate {
        var controller: NumberInputController!

        var bindedValue: Binding<Double>?

        var isDragging: Binding<Bool>?
        var onChange: ((NumberInputController.Change) -> ())?

        public func numberInputDidChange(_ numberInput: NumberInputController, change: NumberInputController.Change) {

            if let bindedValue {
                bindedValue.wrappedValue = change.newValue
            }

            self.onChange?(change)
        }

        public func numberInputDragStarted(_ numberInput: NumberInputController) {
            self.isDragging?.wrappedValue = true
        }

        public func numberInputDragEnded(_ numberInput: NumberInputController) {
            self.isDragging?.wrappedValue = false
        }
    }
}

extension EnvironmentValues {
    #if os(iOS)
    @Entry var numberTextInputKeyboardType: UIKeyboardType? = nil
    #endif
}

extension View {
    
    #if os(iOS)
    func numberTextInputKeyboardType(_ type: UIKeyboardType?) -> some View {
        self.environment(\.numberTextInputKeyboardType, type)
    }
    #endif
}

extension NumberTextInputView {
    public struct Preview: View {
        @State var value: Double = 5.0
        @State var isDragging: Bool = false

        public init() {}

        public var body: some View {
            VStack {
                NumberTextInputView(self.value, isDragging: self.$isDragging) { change in
                    self.value = change.newValue
                }

                NumberTextInputView(
                    self.$value,
                    isDragging: self.$isDragging,
                    dragConfiguration: .range(.closed(.init(range: 0...100, fractionalDigits: 2)))
                )

                Text("is dragging? \(self.isDragging, default: "")")
            }
            .padding()
            // .textInputStyle(.default)
            // .textInputStyle(.default.with(\.insets, .init(horizontal: 10, vertical: 8)))
        }
    }
}

#Preview {
    NumberTextInputView.Preview()
}
