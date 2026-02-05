import Foundation
import Helpers

extension CanvasView {
    public struct Configuration: Sendable, Hashable, With {
        public var scrollWheelSensitivity: CGFloat
        public var zoomRange: ClosedRange<CGFloat>

        public init(
            scrollWheelSensitivity: CGFloat = 0.05,
            zoomRange: ClosedRange<CGFloat> = 0.1...4.0
        ) {
            self.scrollWheelSensitivity = scrollWheelSensitivity
            self.zoomRange = zoomRange
        }

        #if os(macOS)
        static public let `default`: Self = Self()
        #endif

        #if os(iOS)
        static public let `default`: Self = Self()
            .with(\.scrollWheelSensitivity, 0.08)
            .with(\.zoomRange, 0.1...1.0)
        #endif

        public func clampZoom(_ zoom: CGFloat) -> CGFloat {
            zoom.clamped(to: self.zoomRange)
        }
    }
}
