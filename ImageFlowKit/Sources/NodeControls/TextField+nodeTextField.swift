import Design
import SwiftUI

extension TextField {
    @MainActor
    func nodeTextField(
        onDragChanged: ((DragGesture.Value) -> ())? = nil,
        onDragEnded: ((DragGesture.Value) -> ())? = nil
    ) -> some View {
        NodeTextFieldWrapper(
            textField: self,
            onDragChanged: onDragChanged,
            onDragEnded: onDragEnded
        )
    }
}

struct NodeTextFieldWrapper<Label: View>: View {
    let textField: TextField<Label>
    var onDragChanged: ((DragGesture.Value) -> ())?
    var onDragEnded: ((DragGesture.Value) -> ())?

    @FocusState var focused: Bool

    func onTap() {
        self.focused = true
    }

    func onExitHandler() {
        self.focused = false
    }

    func onSubmitHandler() {
        self.focused = false
    }

    func onDragChangedHandler(_ value: DragGesture.Value) {
        self.onDragChanged?(value)
    }

    func onDragEndedHandler(_ value: DragGesture.Value) {
        self.onDragEnded?(value)
    }

    var body: some View {
        textField
            .font(.system(size: 10))
            .textFieldStyle(.plain)
            .fixedSize()
            .focused(self.$focused, equals: true)
            #if os(masOS)
        .onExitCommand(perform: self.onExitHandler)
            #endif
            .onSubmit(self.onSubmitHandler)
            .padding(.vertical, 3)
            .padding(.leading, 6)
            .padding(.top, self.focused ? 3 : 1)
            .animation(nil, value: self.focused)
            #if os(iOS)
        .padding(.trailing, 6)
        #else
        .padding(.trailing, 2)
        #endif
        .background(Background(focused: self.focused))
        .overlay(self.overlayView)
        .animation(.easeInOut(duration: 0.15), value: self.focused)
    }

    private var overlayView: some View {
        Color.clear
            .if(!self.focused) { view in
                view
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture().onChanged(self.onDragChangedHandler(_:)).onEnded(self.onDragEndedHandler(_:))
                    )
                    .onTapGesture(perform: self.onTap)
            }
    }
}

fileprivate struct Background: View, Equatable {
    let focused: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.tint)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .opacity(self.focused ? 1 : 0)
                .shadow(color: .init(white: 0, opacity: 0.9), radius: self.focused ? 5 : 0, y: 3)

            Rectangle()
                .fill(Colors.numberInputBackground.color)
                // .fill(Colors.numberInputBackground.color.shadow(.inner(color: .init(white: 0, opacity: 0.25), radius: self.focused ? 4 : 0, y: self.focused ? 8 : 0)))
                .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                .padding(3)
        }
    }
}
