@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Foundation

public enum BlurType: Sendable, Hashable, Codable {
    case bokeh

    var impl: NodeImpl {
        fatalError()
    }
}

extension Nodes {
    public struct BokehBlurNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Bokeh Blur",
                inputs: [],
                outputs: []
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter.bokehBlur()
                filter.radius = Float(node.inputs[1].float)
                filter.inputImage = await context.getImage(node, 0)
                node.outputs[0] = await .image(context.addImage(filter.outputImage))
            }
        }
    }
}
