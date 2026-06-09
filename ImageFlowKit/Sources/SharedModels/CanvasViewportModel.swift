import Foundation

public struct CanvasViewportModel: Sendable, Equatable {
    public var origin: CGPoint
    public var scale: CGFloat

    public init(origin: CGPoint, scale: CGFloat) {
        self.origin = origin
        self.scale = scale
    }
}
