import CoreImage
import Metal
import Values

@objc
public final class GradientFilter: CIFilter {

    public var gradientData: GradientData
    public var p0: Vector2
    public var p1: Vector2
    public var gradientType: GradientType

    public enum GradientType: Int {
        case linear
        case radial
    }

    private struct Kernels {
        let kernel: CIKernel

        init?() {
            guard let kernel = try? CIKernel(functionName: "filter_kernel", fromMetalLibraryData: PassthroughFilterData)
            else {
                return nil
            }
            self.kernel = kernel
        }
    }

    private static let kernels = Kernels()

    public init(
        _ gradientData: GradientData = .init([
            .init(position: 0.0, color: .white),
            .init(position: 0.5, color: .black),
            .init(position: 1.0, color: .init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)),
        ]),
        gradientType: GradientType = .linear,
        p0: Vector2 = .init(x: 0.0, y: 0.0),
        p1: Vector2 = .init(x: 256.0, y: 256.0),
    ) {
        self.gradientData = gradientData
        self.gradientType = gradientType
        self.p0 = p0
        self.p1 = p1
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var outputImage: CIImage? {
        guard let kernels = GradientFilter.kernels else { return nil }

        let width = self.gradientData.stops.count
        var data = Data(count: width * 8)

        for (index, stop) in self.gradientData.stops.enumerated() {
            let s = UInt8(stop.position * 255.999)
            let r = UInt8(stop.color.red * 255.999)
            let g = UInt8(stop.color.green * 255.999)
            let b = UInt8(stop.color.blue * 255.999)
            let a = UInt8(stop.color.alpha * 255.999)
            data[4 * index] = s
            data[4 * width + 4 * index] = r
            data[4 * width + 4 * index + 1] = g
            data[4 * width + 4 * index + 2] = b
            data[4 * width + 4 * index + 3] = a
        }

        let h = 2
        let dataImage = CIImage(
            bitmapData: data,
            bytesPerRow: width * 4,
            size: .init(width: width, height: h),
            format: .RGBA8,
            colorSpace: nil
        ).samplingNearest()

        let p0 = CIVector(x: self.p0.x, y: self.p0.y)
        let p1 = CIVector(x: self.p1.x, y: self.p1.y)

        return self.apply(
            kernels.kernel,
            arguments: [
                dataImage,
                self.gradientType.rawValue,
                self.gradientData.interpolation.rawValue,
                self.gradientData.noiseAmount,
                p0,
                p1,
            ]
        )?.premultiplyingAlpha()
    }
}
