import Design
import Logging
import SwiftUI
import SwiftUIUtils

fileprivate struct Background: View, Equatable {
    let focused: Bool

    var body: some View {
        ZStack {
            Color.purple
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .opacity(self.focused ? 1 : 0)
                .shadow(color: .init(white: 0, opacity: 0.9), radius: self.focused ? 5 : 0, y: 3)

            Colors.numberInputBackground.color
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .padding(3)
        }
    }
}

public struct NodeNumberInput: View {

    @Binding var value: Double
    @State var valueAtDragStart: Double?
    @FocusState var focused: Bool

    public init(value: Binding<Double>) {
        self._value = value
    }

    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        #if os(macOS)
        formatter.roundingBehavior = .init(
            roundingMode: .plain,
            scale: 8,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        formatter.localizesFormat = false
        #endif
        #if os(iOS)
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 6
        #endif
        formatter.minimumFractionDigits = 1
        return formatter
    }()

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged(self.onDragChanged(_:))
            .onEnded(self.onDragEnded(_:))
    }

    let normalSensitiviy = 0.1
    let slowSensitivity = 0.001


    func onDragChanged(_ gesture: DragGesture.Value) {
        if self.valueAtDragStart == nil {
            self.valueAtDragStart = self.value
        }

        self.value = self.valueAtDragStart! + gesture.translation.width * 0.1
    }

    func onDragEnded(_ gesture: DragGesture.Value) {
        self.value = self.valueAtDragStart! + gesture.translation.width * 0.1
        self.valueAtDragStart = nil
    }

    func onTap() {
        log("tap!!!")
        self.focused = true
    }

    func onExitHandler() {
        self.focused = false
    }

    func onSubmitHandler() {
        self.focused = false
    }

    public var body: some View {
        TextField("", value: self.$value, formatter: Self.formatter)
            .textFieldStyle(.plain)
            .fixedSize()
        #if os(iOS)
            .keyboardType(.decimalPad)
        #endif
            .font(.system(size: 10))
            .focused(self.$focused, equals: true)
        #if os(masOS)
            .onExitCommand(perform: self.onExitHandler)
        #endif
            .onSubmit(self.onSubmitHandler)
            .padding(.vertical, 5)
            .padding(.leading, 6)
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
                    .gesture(self.dragGesture)
                    .onTapGesture(perform: self.onTap)
            }
    }
}

#Preview {
    @Previewable @State var value: Double = 0.0
    VStack {
        NodeNumberInput(value: $value)
        Text("value = \(value)")
    }
    .frame(width: 500, height: 200)
    .background(Colors.cardBackground.color)
    .onChange(of: value) {
        print("value: \(value)")
    }
}
