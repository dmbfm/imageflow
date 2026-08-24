@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Filters
import Foundation
import Helpers
import Values

extension Nodes {
    struct Stylize {
        static var edges3D: NodeImpl {
            let schema = NodeSchema(
                name: "Edges 3D",
                inputs: [
                    .init(name: "Image", type: .image),
                    .init(name: "Shading Image", type: .image),
                    .init(name: "Thickness", defaultValue: .float(3.0)),
                    .init(name: "Spread", defaultValue: .float(1.0)),
                ],
                outputs: [
                    .init(name: "Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let image = await context.getImage(node.inputs[0].image)
                    let shadingImage = await context.getImage(node.inputs[1].image)
                    let edgeRadius = node.inputs[2].float
                    let heightIntensity = node.inputs[3].float

                    if image == nil || shadingImage == nil {

                        node.outputs[0] = .image(await context.addImage(nil, 0))
                        return
                    }

                    let ew = CIFilter.edgeWork()
                    ew.radius = Float(edgeRadius)
                    ew.inputImage = image

                    let hf = CIFilter.heightFieldFromMask()
                    hf.radius = Float(max(1.0, heightIntensity))
                    hf.inputImage = ew.outputImage

                    let sm = CIFilter.shadedMaterial()
                    sm.inputImage = hf.outputImage
                    sm.shadingImage = shadingImage

                    node.outputs[0] = .image(await context.addImage(sm.outputImage, 0))
                }
            )
        }
    }
}
