import Foundation

public struct CanvasViewportModel: Sendable, Equatable, Codable {
    public var origin: CGPoint
    public var scale: CGFloat

    public init(origin: CGPoint, scale: CGFloat) {
        self.origin = origin
        self.scale = scale
    }
}
