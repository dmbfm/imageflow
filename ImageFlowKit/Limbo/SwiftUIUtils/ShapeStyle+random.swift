import SwiftUI

extension ShapeStyle where Self == Color {
    public static var random: Color {
        .init(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
