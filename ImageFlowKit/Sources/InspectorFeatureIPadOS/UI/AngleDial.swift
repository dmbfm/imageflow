import SwiftUI

struct AngleDial: View {
    var angle: Double
    @Environment(\.colorScheme) var cs
    @Environment(\.isEnabled) var enabled
    
    var color: Color {
        Color(white: cs == .dark ? 0.45 : 0.6)
    }
    
    var fillColor: Color {
        Color(white: cs == .dark ? 0.15 : 0.85)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(self.fillColor)
            Circle()
                .stroke()

            Circle()
                .fill()
                .frame(width: 6)
                .transformEffect(.init(translationX: 14, y: 0))
            //                            .transformEffect(.init(rotationAngle: -90.radians))
            //                            .transformEffect(.init(translationX: -3, y: 0))
        }
        .frame(width: 28)
        .rotationEffect(.radians(-self.angle))
        .foregroundStyle(self.color)
        .opacity(self.enabled ? 1 : 0)
    }
    
}

#Preview {
    HStack {
        Text("Angle")
        AngleDial(angle: 45.radians)
    }
}
