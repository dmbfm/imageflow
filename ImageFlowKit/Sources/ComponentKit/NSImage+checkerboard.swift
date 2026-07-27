#if os(macOS)

import XKit

extension NSImage {
    public static func checkerboard(
        _ context: CIContext?,
        color0: CIColor = .white,
        color1: CIColor = .init(red: 0.85, green: 0.85, blue: 0.85, alpha: 8.0),
        width: CGFloat = 6.0,
        size: CGSize
    ) -> NSImage {
        let context = context ?? .init()
        let filter = CIFilter.checkerboardGenerator()
        filter.setDefaults()
        filter.color0 = color0
        filter.color1 = color1
        filter.width = Float(width)
        filter.sharpness = 1.0
        let ciImage = filter.outputImage!.samplingNearest()
        let cgImage = context.createCGImage(
            ciImage,
            from: .init(origin: .zero, size: size),
            format: .RGBA8,
            colorSpace: nil,
            deferred: false,
            calculateHDRStats: false
        )!
        // self.lastDrawSize = self.bounds.size
        let nsImage = NSImage(cgImage: cgImage, size: size)
        return nsImage
    }
}

#endif
