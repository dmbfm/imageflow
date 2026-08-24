import CoreImage
import CoreImage.CIFilterBuiltins
import Metal
import Values

public final class OrderedDitherFilter: CIFilter {

    public var inputImage: CIImage?
    public var ditherType: DitherType = .bayer2x2
    public var darkColor: CIColor = .init(red: 0, green: 0, blue: 0)
    public var lightColor: CIColor = .init(red: 1, green: 1, blue: 1)
    public var noiseAmount: Float = 0.0
    public var bias: Float = 0.0

    public enum DitherType: Int, CaseIterable {
        case bayer2x2
        case bayer4x4
        case bayer8x8
        case noiseOnly

        public var displayName: String {
            switch self {
            case .bayer2x2: "Bayer 2x2"
            case .bayer4x4: "Bayer 4x4"
            case .bayer8x8: "Bayer 8x8"
            case .noiseOnly: "Noise Only"
            }
        }
    }

    static let kernel = try? CIKernel(
        functionName: "ordered_dither",
        fromMetalLibraryData: OrderedDitherFilterData,
    )

    static let matrix2x2: [Double] = [
        0.2, 0.6,
        0.8, 0.4,
    ]

    static let matrix4x4: [Double] = [
        0.0, 8, 2, 10,
        12, 4, 14, 6,
        3, 11, 1, 9,
        15, 7, 13, 5,
    ].map({ ($0 + 1.0) / 17.0 })

    static let matrix8x8: [Double] = [
        0, 32, 8, 40, 2, 34, 10, 42,
        48, 16, 56, 24, 50, 18, 58, 26,
        12, 44, 4, 36, 14, 46, 6, 38,
        60, 28, 52, 20, 62, 30, 54, 22,
        3, 35, 11, 43, 1, 33, 9, 42,
        51, 19, 59, 27, 49, 17, 57, 25,
        15, 47, 7, 39, 13, 45, 5, 37,
        63, 31, 55, 23, 61, 29, 53, 21,
    ].map({ ($0 + 1) / 65.0 })

    static func imageOfmat(dim: Int, mat: [Double]) -> CIImage? {
        if mat.count != dim * dim { return nil }
        var data = Data(count: 4 * dim * dim)
        for row in 0..<dim {
            for col in 0..<dim {
                let val = mat[row * dim + col]
                data[4 * (row * dim + col)] = UInt8(val * 255)
                data[4 * (row * dim + col) + 1] = UInt8(val * 255)
                data[4 * (row * dim + col) + 2] = UInt8(val * 255)
                data[4 * (row * dim + col) + 3] = UInt8(255)
            }
        }

        let image = CIImage(
            bitmapData: data,
            bytesPerRow: 4 * dim,
            size: .init(width: dim, height: dim),
            format: .RGBA8,
            colorSpace: nil
        ).samplingNearest()

        let filter = CIFilter.affineTile()
        filter.inputImage = image
        filter.transform = .identity
        return filter.outputImage!
    }

    static let imageBayer2x2: CIImage = {
        imageOfmat(dim: 2, mat: matrix2x2)!
    }()

    static let imageBayer4x4: CIImage = {
        imageOfmat(dim: 4, mat: matrix4x4)!
    }()

    static let imageBayer8x8: CIImage = {
        imageOfmat(dim: 8, mat: matrix8x8)!
    }()

    static let imageNoiseOnly: CIImage = {
        imageOfmat(dim: 2, mat: [0.5, 0.5, 0.5, 0.5])!
    }()

    public override var outputImage: CIImage? {
        if let image = self.inputImage {

            let pat =
                switch self.ditherType {
                case .bayer2x2: Self.imageBayer2x2
                case .bayer4x4: Self.imageBayer4x4
                case .bayer8x8: Self.imageBayer8x8
                case .noiseOnly: Self.imageNoiseOnly
                }

            return Self.kernel?.apply(
                extent: image.extent,
                roiCallback: { $1 },
                arguments: [
                    image,
                    pat,
                    self.darkColor,
                    self.lightColor,
                    image.extent.origin.x,
                    image.extent.origin.y,
                    image.extent.size.width,
                    image.extent.size.height,
                    self.noiseAmount,
                    self.bias,
                ]
            )
        } else {
            return nil
        }
    }
}
