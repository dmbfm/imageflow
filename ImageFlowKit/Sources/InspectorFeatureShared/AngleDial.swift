import SwiftUI

public struct AngleDial: View {
    var angle: Double
    @Environment(\.colorScheme) var cs
    @Environment(\.isEnabled) var enabled
    @Environment(\.angleDialRadius) var radius
    @Environment(\.angleDialThumbRadius) var thumbRadius
    @Environment(\.angleDialDisabledBehavior) var disabledBehavior

    public enum DisabledBehavior {
        case hide
        case nothing
    }

    public init(angle: Double) {
        self.angle = angle
    }

    var color: Color {
        Color(white: cs == .dark ? 0.45 : 0.6)
    }

    var fillColor: Color {
        Color(white: cs == .dark ? 0.15 : 0.85)
    }

    var opacity: CGFloat {
        if !self.enabled && self.disabledBehavior == .hide {
            0.0
        } else {
            1.0
        }
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(self.fillColor)
            Circle()
                .stroke()

            Circle()
                .fill()
                .frame(width: 2 * self.thumbRadius)
                .transformEffect(.init(translationX: self.radius, y: 0))
            //                            .transformEffect(.init(rotationAngle: -90.radians))
            //                            .transformEffect(.init(translationX: -3, y: 0))
        }
        .frame(width: 2 * self.radius)
        .rotationEffect(.radians(-self.angle))
        .foregroundStyle(self.color)
        .opacity(self.opacity)
    }

}

public extension EnvironmentValues {
    @Entry var angleDialRadius: CGFloat = 14
    @Entry var angleDialThumbRadius: CGFloat = 3
    @Entry var angleDialDisabledBehavior: AngleDial.DisabledBehavior = .hide
}

public extension View {
    func angleDialRadius(_ value: CGFloat) -> some View {
        self.environment(\.angleDialRadius, value)
    }

    func angleDialThumbRadius(_ value: CGFloat) -> some View {
        self.environment(\.angleDialThumbRadius, value)
    }

    func angleDialDisabledBehavior(_ value: AngleDial.DisabledBehavior) -> some View {
        self.environment(\.angleDialDisabledBehavior, value)
    }
}

#Preview {
    HStack {
        Text("Angle")
        AngleDial(angle: 45.radians)
    }
}
