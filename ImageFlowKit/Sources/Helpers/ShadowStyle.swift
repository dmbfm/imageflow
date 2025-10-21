import CoreGraphics
import Foundation

public struct ShadowStyle: Sendable, Hashable {
    public var radius: CGFloat
    public var color: PlatformColor
    public var opacity: CGFloat
    public var offset: CGSize

    public init(radius: CGFloat, color: PlatformColor, opacity: CGFloat = 0.4, offset: CGSize = .zero) {
        self.radius = radius
        self.color = color
        self.opacity = opacity
        self.offset = offset
    }
}
