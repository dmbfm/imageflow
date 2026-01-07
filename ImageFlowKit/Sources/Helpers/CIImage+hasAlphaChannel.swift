import CoreImage
import CoreImage.CIFilterBuiltins

extension CIImage {
    public func hasAlphaChannel(_ context: CIContext?) -> Bool? {

        guard !self.extent.isInfinite else { return nil }
        
        let min = {
            let filter = CIFilter.areaMinimumAlpha()
            filter.inputImage = self
            filter.extent = self.extent
            return filter.outputImage
        }()

        let max = {
            let filter = CIFilter.areaMaximumAlpha()
            filter.inputImage = self
            filter.extent = self.extent
            return filter.outputImage
        }()

        let context = context ?? CIContext()

        if let min, let max {

            func renderToAlpha(_ image: CIImage) -> Float {
                var value: Float = 1.0

                context.render(
                    image,
                    toBitmap: &value,
                    rowBytes: MemoryLayout<Float>.stride,
                    bounds: .init(x: 0, y: 0, width: 1, height: 1),
                    format: .Af,
                    colorSpace: nil
                )

                return value
            }

            let minValue = renderToAlpha(min)
            let maxValue = renderToAlpha(max)

            return minValue < 1 || maxValue < 1
        } else {
            return nil
        }
    }
}
