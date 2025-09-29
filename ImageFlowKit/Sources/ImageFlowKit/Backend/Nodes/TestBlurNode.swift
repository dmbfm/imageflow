@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Foundation

extension Nodes {
    public struct TestBlurNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {

            let schema = NodeSchema(
                name: "Blur Node (Test)",
                inputs: [
                    .init(name: "Input Image", type: .image),
                    .init(name: "Radius", defaultValue: .float(10)),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter.gaussianBlur()
                filter.radius = Float(node.inputs[1].float);
                filter.inputImage = await context.getImage(node, 0)
                node.outputs[0] = await .image(context.addImage(filter.outputImage))
            }
        }
    }
}
