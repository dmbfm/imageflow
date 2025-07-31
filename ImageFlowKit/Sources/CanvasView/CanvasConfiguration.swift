import CommonUtils
import Foundation

public struct CanvasConfiguration: Sendable, Hashable {
    public var scrollWheelSensitivity: CGFloat
    public var zoomRange: ClosedRange<CGFloat>

    public init(
        scrollWheelSensitivity: CGFloat = 0.05,
        zoomRange: ClosedRange<CGFloat> = 0.1...4.0
    ) {
        self.scrollWheelSensitivity = scrollWheelSensitivity
        self.zoomRange = zoomRange
    }

    static public let `default`: Self = Self()

    public func clampZoom(_ zoom: CGFloat) -> CGFloat {
        zoom.clamped(to: self.zoomRange)
    }
}
