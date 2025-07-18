import SwiftUI

public struct NodeAngleInput: View {

    @Binding var value: Double
    var mode: Mode = .compact

    public enum Mode {
        case compact
        case expanded
    }

    public init(value: Binding<Double>, mode: Mode) {
        self._value = value
        self.mode = mode
    }

    public var body: some View {
        switch self.mode {
        case .compact:
            self.compactView
        case .expanded:
            self.expandedView
        }
    }

    @ViewBuilder
    var compactView: some View {
        HStack(spacing: 0) {
            AngleDial(angle: self.$value)
                .scaleEffect(0.38)
                .frame(width: 20, height: 20)
            // .border(.red)

            NodeNumberInput(
                value: .init {
                    self.value.degrees
                } set: { newValue in
                    self.value = CGFloat(newValue).normalized(as: .degrees).radians
                },
                settings: .init(dragSensitivity: .init(normal: 0.1, slow: 0.01), formatter: .int)
            )
            .frame(minWidth: 34)
            .fixedSize()
            // .border(.blue)
        }
    }

    @ViewBuilder
    var expandedView: some View {
        VStack {
            AngleDial(angle: self.$value)
                .frame(width: 50, height: 50)
                .border(.red)

            NodeNumberInput(
                value: .init {
                    self.value.degrees
                } set: { newValue in
                    self.value = CGFloat(newValue).normalized(as: .degrees).radians
                },
                settings: .init(formatter: .int)
            )
            .frame(minWidth: 40)
            .fixedSize()
            .border(.blue)
        }
    }
}

#Preview("compact") {
    @Previewable @State var angle: Double = 45.0.radians

    VStack {
        NodeAngleInput(value: $angle, mode: .compact)
    }
    .padding(80)
}

#Preview("expanded") {
    @Previewable @State var angle: Double = 45.0.radians

    VStack {
        NodeAngleInput(value: $angle, mode: .expanded)
    }
    .padding(80)
}
