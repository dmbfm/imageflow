import CoreImage
import Metal
import Values

public final class MaskToAlphaFilter: CIFilter {

    public var channel: MaskChannel = .alpha
    public var inputImage: CIImage? = nil
    public var maskImage: CIImage? = nil

    public enum MaskChannel {
        case alpha
        case red
        case green
        case blue
        case white
    }

    public override init() {
        super.init()
    }

    public init(_ inputImage: CIImage, maskImage: CIImage, channel: MaskChannel = .alpha) {
        self.inputImage = inputImage
        self.maskImage = maskImage
        self.channel = channel
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static let kernel_alpha = try? CIKernel(
        functionName: "alpha_mask_to_alpha",
        fromMetalLibraryData: MaskToAlphaFilterData
    )
    static let kernel_red = try? CIKernel(
        functionName: "red_mask_to_alpha",
        fromMetalLibraryData: MaskToAlphaFilterData
    )
    static let kernel_green = try? CIKernel(
        functionName: "green_mask_to_alpha",
        fromMetalLibraryData: MaskToAlphaFilterData
    )
    static let kernel_blue = try? CIKernel(
        functionName: "blue_mask_to_alpha",
        fromMetalLibraryData: MaskToAlphaFilterData
    )
    static let kernel_white = try? CIKernel(
        functionName: "white_mask_to_alpha",
        fromMetalLibraryData: MaskToAlphaFilterData
    )

    public override var outputImage: CIImage? {

        guard let inputImage = self.inputImage else { return nil }

        guard let maskImage = self.maskImage?.clampedToExtent() else { return inputImage }

        let kernel =
            switch self.channel {
            case .alpha: Self.kernel_alpha
            case .red: Self.kernel_red
            case .green: Self.kernel_green
            case .blue: Self.kernel_blue
            case .white: Self.kernel_white
            }

        guard let kernel else { return inputImage }

        return kernel.apply(extent: inputImage.extent, roiCallback: { _, r in r }, arguments: [inputImage, maskImage])
    }
}
