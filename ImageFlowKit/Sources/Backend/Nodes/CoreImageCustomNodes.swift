@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Foundation
import Helpers

extension Nodes {
    struct CoreImageCustom {}
}

extension Nodes.CoreImageCustom {

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
                    node.outputs[0] = .image(await context.addImage(filter.outputImage, 0))
                }
            )
        }
    }
    public struct ApplyAffineTransformFilterNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Apply Affine Transform",
                inputs: [
                    .init(name: "Image", type: .image),
                    .init(name: "Affine Transform", defaultValue: .affineTransform(.identity)),
                ],
                outputs: [
                    .init(name: "Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let inputImage = await context.getImage(node.inputs[0].image)
                    let outputImage = inputImage?.transformed(
                        by: node.inputs[1].affineTransform.cgAffineTransform,
                        highQualityDownsample: true
                    )
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                }
            )
        }
    }

    public struct RotateFilterNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Rotate",
                displayName: "Rotate",
                inputs: [
                    .init(name: "Image", type: .image),
                    .init(
                        name: "Angle",
                        defaultValue: .float(0),
                        semantics: .angle,
                        options: [
                            .init(name: "Units", pickerOptions: ["Degrees", "Radians"], defaultValue: 0)!
                        ]
                    ),
                ],
                outputs: [
                    .init(name: "Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let inputImage = await context.getImage(node.inputs[0].image)
                    let rawAngle = node.inputs[1].float
                    let angle =
                        switch node.inputOptions[1][0].int {
                        case 0: rawAngle.radians
                        default: rawAngle
                        }
                    let outputImage = inputImage?.transformed(
                        by: .init(rotationAngle: angle),
                        highQualityDownsample: true
                    )
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                }
            )
        }
    }

    public struct TranslateFilterNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Translate",
                inputs: [
                    .init(name: "Image", type: .image),
                    .init(name: "Translation", defaultValue: .vector2(.init(x: 0, y: 0))),
                ],
                outputs: [
                    .init(name: "Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let inputImage = await context.getImage(node.inputs[0].image)
                    let t = node.inputs[1].vector2
                    let outputImage = inputImage?.transformed(
                        by: .init(translationX: t.x, y: t.y),
                        highQualityDownsample: true
                    )
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                }
            )
        }
    }

    public struct ScaleFilterNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Scale",
                inputs: [
                    .init(name: "Image", type: .image),
                    .init(name: "Scale", defaultValue: .vector2(.init(x: 1, y: 1)), semantics: .scaleVector),
                ],
                outputs: [
                    .init(name: "Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let inputImage = await context.getImage(node.inputs[0].image)
                    let t = node.inputs[1].vector2
                    let outputImage = inputImage?.transformed(
                        by: .init(scaleX: t.x, y: t.y),
                        highQualityDownsample: true
                    )
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                }
            )
        }
    }
}
