import SwiftUI

public struct AngleDial: View {
    var angle: Double
    var range: ClosedRange<Double>? = nil
    @Environment(\.colorScheme) var cs
    @Environment(\.isEnabled) var enabled
    @Environment(\.angleDialRadius) var radius
    @Environment(\.angleDialThumbRadius) var thumbRadius
    @Environment(\.angleDialDisabledBehavior) var disabledBehavior

    public init(angle: Double, range: ClosedRange<Double>? = nil) {
        self.angle = angle
        self.range = range
    }

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
            if self.range != nil {
                self.contentRange
            } else {
                self.contentNoRange
            }
        }
        .frame(width: 2 * self.radius)
        .foregroundStyle(self.color)
        .opacity(self.opacity)
    }

    @ViewBuilder
    var contentNoRange: some View {
        Circle()
            .fill(self.fillColor)
        Circle()
            .stroke()

        Circle()
            .fill()
            .frame(width: 2 * self.thumbRadius)
            .transformEffect(.init(translationX: self.radius, y: 0))
            .rotationEffect(.radians(-self.angle))
    }

    @ViewBuilder
    var contentRange: some View {
        let range = self.range!

        Circle()
            .stroke(.primary, style: .init(dash: [4, 2]))

        CircleArc(startAngle: .radians(range.lowerBound), endAngle: .radians(range.upperBound))
            .fill(self.fillColor)

        CircleArc(startAngle: .radians(range.lowerBound), endAngle: .radians(range.upperBound))
            .stroke()

        Circle()
            .fill()
            .frame(width: 2 * self.thumbRadius)
            .transformEffect(.init(translationX: self.radius, y: 0))
            .rotationEffect(.radians(-self.angle))
    }
}

struct CircleArc: Shape {

    var startAngle: Angle
    var endAngle: Angle

    nonisolated func path(in rect: CGRect) -> Path {
        var p = Path()
        let radius = min(rect.width, rect.height) * 0.5
        p.move(to: rect.center)
        p.addLine(
            to:
                .init(
                    x: rect.center.x + radius * cos(startAngle.radians),
                    y: rect.center.y + radius * sin(startAngle.radians),
                )
        )
        p.addArc(
            center: rect.center,
            radius: radius,
            startAngle: self.startAngle,
            endAngle: self.endAngle,
            clockwise: false
        )
        p.addLine(to: rect.center)
        return p
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
        AngleDial(angle: -40.radians, range: (-.pi * 0.25)...(.pi * 0.25))
    }
}
