import CoreImage
import Metal
import Values

public final class ChromaticAberrationFilter: CIFilter {

    public var inputImage: CIImage?
    public var intensity: Float = 0.5

    static let kernel = try? CIKernel(
        functionName: "ca_kernel",
        fromMetalLibraryData: ChromaticAberrationFilterData
    )

    public override var outputImage: CIImage? {
        if let image = self.inputImage {
            Self.kernel?.apply(
                extent: image.extent,
                roiCallback: { $1 },
                arguments: [
                    image,
                    image.extent.center.x,
                    image.extent.center.y,
                    self.intensity,
                ]
            )
        } else {
            nil
        }
    }
}
