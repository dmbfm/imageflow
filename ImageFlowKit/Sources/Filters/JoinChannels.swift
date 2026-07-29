import CoreImage
import Metal
import Values

public final class JoinChannelsFilter: CIFilter {

    public var mode: Mode = .rgba

    public var imageR: CIImage?
    public var imageG: CIImage?
    public var imageB: CIImage?
    public var imageA: CIImage?

    public enum Mode {
        case rgb
        case rgba
    }

    static let kernel_rgb = try? CIKernel(functionName: "join_rgb", fromMetalLibraryData: JoinChannelsFilterData)
    static let kernel_rgba = try? CIKernel(functionName: "join_rgba", fromMetalLibraryData: JoinChannelsFilterData)

    public override var outputImage: CIImage? {
        let kern =
            switch self.mode {
            case .rgb: Self.kernel_rgb
            case .rgba: Self.kernel_rgba
            }

        guard let kern else { return nil }

        func intersect(_ a: CGRect?, _ b: CGRect?) -> CGRect? {
            switch (a, b) {
            case (.some(let a), .some(let b)): a.intersection(b)
            case (.some(let a), nil): a
            case (nil, .some(let b)): b
            case (nil, nil): nil
            }
        }

        switch self.mode {
        case .rgb:
            if self.imageR == nil && self.imageG == nil && self.imageB == nil {
                return nil
            }

            guard
                let rect = intersect(
                    intersect(self.imageR?.extent, self.imageG?.extent),
                    self.imageB?.extent
                )
            else { return nil }

            return kern.apply(
                extent: rect,
                roiCallback: { $1 },
                arguments: [
                    self.imageR ?? .black,
                    self.imageG ?? .black,
                    self.imageB ?? .black,
                ]
            )

        case .rgba:
            if self.imageR == nil && self.imageG == nil && self.imageB == nil && self.imageA == nil {
                return nil
            }

            guard
                let rect = intersect(
                    intersect(
                        intersect(self.imageR?.extent, self.imageG?.extent),
                        self.imageB?.extent
                    ),
                    self.imageA?.extent
                )
            else { return nil }

            return kern.apply(
                extent: rect,
                roiCallback: { $1 },
                arguments: [
                    self.imageR ?? .black,
                    self.imageG ?? .black,
                    self.imageB ?? .black,
                    self.imageA ?? .black,
                ]
            )
        }
    }
}
