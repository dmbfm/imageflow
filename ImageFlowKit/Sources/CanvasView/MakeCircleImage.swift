import CoreGraphics
import Foundation

@MainActor
class CircleImageDrawer {
    private var cache: CGImage?
    private var lastBGColor: CGColor?
    private var lastDotColor: CGColor?

    func invalidateCache() {
        self.cache = nil
        self.lastBGColor = nil
        self.lastDotColor = nil
    }

    @inline(__always)
    func draw(_ bgColor: CGColor, _ dotColor: CGColor) -> CGImage {
        if self.lastBGColor == bgColor && self.lastDotColor == dotColor,
            let cache = self.cache
        {
            return cache
        }

        // Define the image size
        let imageSize = CGSize(width: 50, height: 50)

        // Define the circle's properties
        let circleRadius: CGFloat = 2.0
        let circleCenter = CGPoint(x: imageSize.width / 2, y: imageSize.height / 2)

        // Create a bitmap context
        let context = CGContext(
            data: nil,
            width: Int(imageSize.width),
            height: Int(imageSize.height),
            bitsPerComponent: 8,  // 8 bits per color component
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!

        // Fill the background with white
        context.setFillColor(bgColor)
        context.fill(CGRect(origin: .zero, size: imageSize))

        // Draw the black circle
        context.setFillColor(dotColor)
        context.fillEllipse(
            in: CGRect(
                x: circleCenter.x - circleRadius,
                y: circleCenter.y - circleRadius,
                width: circleRadius * 2,
                height: circleRadius * 2
            )
        )

        // Create the CGImage from the context
        let image = context.makeImage()!

        self.cache = image
        self.lastBGColor = bgColor
        self.lastDotColor = dotColor

        return image
    }
}
