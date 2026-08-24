@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Filters
import Foundation
import Helpers
import Values

extension Nodes {
    struct GeometryAdjustment {
        static var resize: NodeImpl {
            let schema = NodeSchema(
                name: "Resize",
                inputs: [
                    .init(name: "Image", type: .image),
                    .init(name: "Width", defaultValue: .int(256)),
                    .init(name: "Height", defaultValue: .int(256)),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    guard let inputImage = await context.getImage(node.inputs[0].image) else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                        return
                    }
                    let width = node.inputs[1].int
                    let height = node.inputs[2].int
                    let scaleX = CGFloat(width) / inputImage.extent.width
                    let scaleY = CGFloat(height) / inputImage.extent.height
                    node.outputs[0] = .image(
                        await context.addImage(inputImage.transformed(by: .init(scaleX: scaleX, y: scaleY)), 0)
                    )
                }
            )
        }

        static var resizeToWidth: NodeImpl {
            let schema = NodeSchema(
                name: "Resize To Width",
                inputs: [
                    .init(name: "Image", type: .image),
                    .init(name: "Width", defaultValue: .int(256)),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    guard let inputImage = await context.getImage(node.inputs[0].image) else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                        return
                    }
                    let width = node.inputs[1].int
                    let scale = CGFloat(width) / inputImage.extent.width
                    node.outputs[0] = .image(
                        await context.addImage(inputImage.transformed(by: .init(scaleX: scale, y: scale)), 0)
                    )
                }
            )
        }

        static var resizeToHeight: NodeImpl {
            let schema = NodeSchema(
                name: "Resize To Height",
                inputs: [
                    .init(name: "Image", type: .image),
                    .init(name: "Height", defaultValue: .int(256)),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    guard let inputImage = await context.getImage(node.inputs[0].image) else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                        return
                    }
                    let height = node.inputs[1].int
                    let scale = CGFloat(height) / inputImage.extent.height
                    node.outputs[0] = .image(
                        await context.addImage(inputImage.transformed(by: .init(scaleX: scale, y: scale)), 0)
                    )
                }
            )
        }
    }
}
