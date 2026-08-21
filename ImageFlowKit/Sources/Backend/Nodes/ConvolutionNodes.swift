@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Filters
import Foundation
import GameKit
import Helpers
import Values

extension Nodes {
    struct Convolution {
        static var embossNodeImpl: NodeImpl {
            let schema = NodeSchema(
                name: "Emboss",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Size",
                        defaultValue: .int(0),
                        semantics: .integer(
                            .picker([
                                .init(label: "3x3", value: 0),
                                .init(label: "5x5", value: 1),
                            ])
                        ),
                    ),
                    .init(name: "Bias", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let type = node.inputs[1].int
                let filter = CIFilter(name: type == 0 ? "CIConvolutionRGB3X3" : "CIConvolutionRGB5X5")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                filter.setValue(
                    CIVector(
                        values: type == 0
                            ? [-2, -1, 0, -1, 1, 1, 0, 1, 2]
                            : [
                                -2, 0, -1, 0, 0,
                                0, -2, -1, 0, 0,
                                -1, -1, 1, 1, 1,
                                0, 0, 1, 2, 0,
                                0, 0, 1, 0, 2,
                            ],
                        count: type == 0 ? 9 : 25
                    ),
                    forKey: "inputWeights"
                )
                filter.setValue(node.inputs[2].float, forKey: "inputBias")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }
}
