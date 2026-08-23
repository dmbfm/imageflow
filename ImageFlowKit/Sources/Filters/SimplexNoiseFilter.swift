import CoreImage
import CoreImage.CIFilterBuiltins
import Metal
import Values

public final class SimplexNoiseFilter: CIFilter {
    public var scale: Float = 100.0

    static let kernel = try? CIKernel(
        functionName: "filter_kernel",
        fromMetalLibraryData: SimplexNoiseFilterData,
    )

    public override var outputImage: CIImage? {
        let ext = CGRect(
            x: -CGFloat.infinity,
            y: -CGFloat.infinity,
            width: CGFloat.infinity,
            height: CGFloat.infinity
        )
        return Self.kernel?.apply(
            extent: ext,
            roiCallback: { _, _ in ext },
            arguments: [self.scale]
        )
    }
}
