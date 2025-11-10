@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Foundation

extension Nodes {
    public struct LutFilterNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Lut Filter Node",
                displayName: "LUT Filter",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "LUT", defaultValue: .lut(nil)),
                ],
                outputs: []
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let filter = CIFilter.colorCube()
                    filter.inputImage = await context.getImage(node.inputs[0].image)
                    let lut = await context.getLut(node.inputs[1].lut)
                    filter.cubeData = lut.data
                    filter.cubeDimension =
                        switch lut.info.dim {
                        case .one: fatalError()
                        case .three(let n): Float(n)
                        }
                    filter.extrapolate = true
                    node.outputs[0] = .image(await context.addImage(filter.outputImage))
                }
            )
        }
    }
}
