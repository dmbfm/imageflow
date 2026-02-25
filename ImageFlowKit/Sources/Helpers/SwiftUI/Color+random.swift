import SwiftUI

extension Color {
    public static func randomHue(saturation: Double = 0.5, brightness: Double = 0.5) -> Self {
        Color(hue: .random(in: 0...1), saturation: saturation, brightness: brightness)
    }
}
