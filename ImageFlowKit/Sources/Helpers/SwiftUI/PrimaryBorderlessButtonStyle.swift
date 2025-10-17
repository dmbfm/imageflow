import SwiftUI

public struct PrimaryBorderlessButtonStyle: ButtonStyle {

    var pressedStyle: AnyShapeStyle = .init(.secondary)

    public init() {

    }

    public init<S: ShapeStyle>(_ pressedStyle: S) {
        self.pressedStyle = .init(pressedStyle)
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(configuration.isPressed ? self.pressedStyle : AnyShapeStyle(.primary))
            .animation(.interpolatingSpring.speed(10), value: configuration.isPressed)
    }

    public func pressed<S: ShapeStyle>(_ style: S) -> Self {
        var s = self
        s.pressedStyle = .init(style)
        return s
    }
}

extension ButtonStyle where Self == PrimaryBorderlessButtonStyle {
    public static var primaryBorderless: Self { .init() }
}
