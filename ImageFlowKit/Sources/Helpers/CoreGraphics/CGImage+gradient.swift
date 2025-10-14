import CoreGraphics
import Foundation

public extension CGImage {
    /// Creates a vertical (top → bottom) linear-gradient `CGImage`.
    /// - Parameters:
    ///   - width:  Image width in pixels.
    ///   - height: Image height in pixels.
    ///   - topColor: Color at the top edge.
    ///   - bottomColor: Color at the bottom edge.
    ///   - colorSpace: Target color space (defaults to sRGB).
    ///   - options: Gradient drawing options (defaults to extend before/after).
    /// - Returns: A `CGImage` or `nil` if creation failed.
    static func verticalGradientImage(
        width: Int,
        height: Int,
        topColor: CGColor,
        bottomColor: CGColor,
        colorSpace: CGColorSpace? = nil,
        options: CGGradientDrawingOptions = [.drawsBeforeStartLocation, .drawsAfterEndLocation]
    ) -> CGImage? {
        guard width > 0, height > 0 else { return nil }

        let cs = colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()

        // Ensure input colors match the destination color space.
        func convert(_ c: CGColor) -> CGColor {
            c.converted(to: cs, intent: .defaultIntent, options: nil) ?? c
        }
        let top = convert(topColor)
        let bottom = convert(bottomColor)

        // 8-bpc RGBA (premultiplied), little-endian.
        let bitmapInfo = CGBitmapInfo.byteOrder32Little
            .union(CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue))

        guard
            let ctx = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: cs,
                bitmapInfo: bitmapInfo.rawValue
            )
        else { return nil }

        guard
            let gradient = CGGradient(
                colorsSpace: cs,
                colors: [top, bottom] as CFArray,
                locations: [0.0, 1.0]
            )
        else { return nil }

        // Core Graphics origin is bottom-left. Start at y = height to place `topColor` at the visual top.
        ctx.drawLinearGradient(
            gradient,
            start: CGPoint(x: 0, y: CGFloat(height)),
            end: CGPoint(x: 0, y: 0),
            options: options
        )

        return ctx.makeImage()
    }
}
