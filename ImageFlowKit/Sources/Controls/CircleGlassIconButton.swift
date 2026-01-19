import SwiftUI

public struct CircleGlassIconButton: View {
    let systemName: String
    var glass: Glass = .regular
    var action: () -> ()

    @Environment(\.circleGlassButtonSize) var size

    public init(_ systemName: String, glass: Glass = .regular, _ action: @escaping () -> ()) {
        self.systemName = systemName
        self.glass = glass
        self.action = action
    }

    public var body: some View {
        Button {
            self.action()
        } label: {
            Image(systemName: systemName)
                .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .glassEffect(self.glass.interactive())
        .contentShape(Circle())
    }
}

extension EnvironmentValues {
    @Entry public var circleGlassButtonSize: CGFloat = 32.0
}

extension View {
    public func circleGlassButtonSize(_ value: CGFloat) -> some View {
        self.environment(\.circleGlassButtonSize, value)
    }
}

#Preview {
    ZStack {
        Rectangle()
            .fill(Color.teal.gradient)

        CircleGlassIconButton("xmark") {}
    }
}
