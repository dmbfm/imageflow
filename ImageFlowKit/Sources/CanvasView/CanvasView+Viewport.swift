import CoreGraphics
import Foundation
import Helpers

extension CanvasView {
    public struct Viewport: Codable, Sendable, Hashable, Equatable {
        /// The origin of the viewport, in `canvas` coordinates.
        public var origin: CGPoint = .zero
        /// The scale/zoom of the viewport.
        public var scale: CGFloat = 1.0

        public init() {}

        public init(origin: CGPoint, scale: CGFloat) {
            self.origin = origin
            self.scale = scale
        }

        /// Returne the affine transform that converts coordinates between the
        /// two given coordinate spaces.
        /// - Parameters:
        ///     - from: The coordinate space to transform from.
        ///     - to: The coordinate space to transform to.
        public func transform(
            from: CoordinateSpace,
            to: CoordinateSpace
        )
            -> CGAffineTransform
        {
            switch (from, to) {
            // To transform between the screen and viewport we only need a scale.
            case (.screen, .viewport):
                return CGAffineTransform.init(
                    a: 1.0 / self.scale,
                    b: 0.0,
                    c: 0.0,
                    d: 1.0 / self.scale,
                    tx: 0.0,
                    ty: 0.0
                )
            // The inverse from the previous transform.
            case (.viewport, .screen):
                return self.transform(from: .screen, to: .viewport).inverted()
            // To transform from screen to canvas we need to scale (transforming to viewport) and then
            // translate the viewport origin.
            case (.screen, .canvas):
                return CGAffineTransform.init(
                    a: 1.0 / self.scale,
                    b: 0.0,
                    c: 0.0,
                    d: 1.0 / self.scale,
                    tx: self.origin.x,
                    ty: self.origin.y
                )
            // The inverse of the previous transform.
            case (.canvas, .screen):
                return self.transform(from: .screen, to: .canvas).inverted()
            // To tranform from viewport to canvas we translate by the viewport origin.
            case (.viewport, .canvas):
                return CGAffineTransform(translationX: self.origin.x, y: self.origin.y)
            // The inverse of the previous transform.
            case (.canvas, .viewport):
                return self.transform(from: .viewport, to: .canvas).inverted()
            // Identity transforms.
            case (.screen, .screen), (.viewport, .viewport), (.canvas, .canvas):
                return .identity
            }
        }

        /// Convert a point from one coordinate space to another.
        /// - Parameters:
        ///     - point: The point to convert.
        ///     - from: The coordinate space to convert from.
        ///     - to: The coordinate space to convert to.
        public func convert(
            _ point: CGPoint,
            from: CoordinateSpace,
            to: CoordinateSpace
        )
            -> CGPoint
        {
            point.applying(self.transform(from: from, to: to))
        }

        /// Convert a size from one coordinate space to another.
        /// - Parameters:
        ///     - size: The size to convert.
        ///     - from: The coordinate space to convert from.
        ///     - to: The coordinate space to convert to.
        public func convert(
            _ size: CGSize,
            from: CoordinateSpace,
            to: CoordinateSpace
        ) -> CGSize {
            size.applying(self.transform(from: from, to: to))
        }

        /// Convert a length from one coordinate space to another.
        /// - Parameters:
        ///     - length: The length to convert.
        ///     - from: The coordinate space to convert from.
        public func convert(
            _ length: CGFloat,
            from: CoordinateSpace,
            to: CoordinateSpace
        ) -> CGFloat {
            CGSize(width: length, height: 0).applying(self.transform(from: from, to: to)).width
        }

        public func convert(
            _ rect: CGRect,
            from: CoordinateSpace,
            to: CoordinateSpace
        ) -> CGRect {
            .init(
                origin: self.convert(rect.origin, from: from, to: to),
                size: self.convert(rect.size, from: from, to: to)
            )
        }

        /// Translate the viewport by the given amount in the given coordinate
        /// space.
        /// - Parameters:
        ///     - amount: The amount to translate by.
        ///     - space: The coordinate space of the amount.
        public mutating func translate(
            by amount: CGSize,
            in space: CoordinateSpace
        ) {
            let delta = self.convert(amount, from: space, to: .canvas)
            self.origin.x += delta.width
            self.origin.y += delta.height
        }

        public func translated(
            by amount: CGSize,
            in space: CoordinateSpace
        ) -> Self {
            var viewport = self
            viewport.translate(by: amount, in: space)
            return viewport
        }

        /// - Parameters:
        ///     - value: The zoom value.
        ///     - atScreenPoint: The point in screen coordinates to zoom at.
        public mutating func zoom(_ value: CGFloat, atScreenPoint point: CGPoint) {
            let p = self.convert(point, from: .screen, to: .canvas)
            let ratio = self.scale / value
            self.origin = CGPoint(
                x: p.x + ratio * (self.origin.x - p.x),
                y: p.y + ratio * (self.origin.y - p.y)
            )
            self.scale = value
        }

        public func zoomed(_ value: CGFloat, atScreenPoint point: CGPoint) -> Self {
            var viewport = self
            viewport.zoom(value, atScreenPoint: point)
            return viewport
        }

        /// Return the range of indices of the grid circles that are visible in
        /// the viewport.
        func gridCirclesRanges(
            spacing: CGFloat,
            radius: CGFloat,
            screenSize: CGSize
        ) -> (
            ClosedRange<Int>, ClosedRange<Int>
        ) {
            let size = self.convert(screenSize, from: .screen, to: .viewport)

            let imin = Int((self.origin.x - radius) / spacing)
            let imax = Int((self.origin.x + size.width + radius) / spacing)
            let jmin = Int((self.origin.y - radius) / spacing)
            let jmax = Int((self.origin.y + size.height + radius) / spacing)

            return (imin...imax, jmin...jmax)
        }

        public mutating func fit(
            contentRect: CGRect,
            centeredAtViewRect viewRect: CGRect,
            zoomRange: ClosedRange<CGFloat>? = nil,
            padding: CGFloat = 0.0
        ) {
            let contentRect = contentRect.insetBy(dx: -padding, dy: -padding)
            let viewAspect = viewRect.width / viewRect.height
            let contentAspect = contentRect.width / contentRect.height

            self.scale =
                if viewAspect >= contentAspect {
                    viewRect.height / contentRect.height
                } else {
                    viewRect.width / contentRect.width
                }

            if let range = zoomRange {
                self.scale = self.scale.clamped(to: range)
            }
            self.origin = .zero
            let viewRectPrime = self.convert(viewRect, from: .screen, to: .canvas)
            self.origin = contentRect.center - viewRectPrime.center
        }
    }
}
