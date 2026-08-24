@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Filters
import Foundation
import Helpers
import Values

extension Nodes {
    struct Experimental {
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

        static var ordererdDither: NodeImpl {

            let schema = NodeSchema(
                name: "Ordered Dither",
                inputs: [
                    .init(name: "Image", type: .image),
                    .init(
                        name: "Type",
                        defaultValue: .int(0),
                        semantics: .integer(
                            .picker(
                                OrderedDitherFilter.DitherType.allCases.enumerated().map({ e in
                                    ValueSemantics.IntegerSemantics.PickerOption(
                                        label: e.element.displayName,
                                        value: e.offset
                                    )
                                })
                            )
                        )
                    ),
                    .init(name: "Dark Color", defaultValue: .color4(.black)),
                    .init(name: "Light Color", defaultValue: .color4(.white)),
                    .init(name: "Noise", defaultValue: .float(0.0), semantics: .float(.range(0...1))),
                    .init(name: "Bias", defaultValue: .float(0.0), semantics: .float(.range(-0.5...0.5))),
                ],
                outputs: [
                    .init(name: "Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let filter = OrderedDitherFilter()
                    filter.inputImage = await context.getImage(node.inputs[0].image)
                    filter.ditherType = .init(rawValue: node.inputs[1].int) ?? .bayer2x2
                    filter.darkColor = node.inputs[2].color4.ciColor
                    filter.lightColor = node.inputs[3].color4.ciColor
                    filter.noiseAmount = Float(node.inputs[4].float)
                    filter.bias = Float(node.inputs[5].float)
                    node.outputs[0] = .image(await context.addImage(filter.outputImage, 0))
                }
            )
        }

        static var chromaticAberration: NodeImpl {

            let schema = NodeSchema(
                name: "Chromatic Aberration",
                inputs: [
                    .init(name: "Image", type: .image),
                    .init(name: "Intensity", defaultValue: .float(0.5), semantics: .float(.range(0...1))),
                ],
                outputs: [
                    .init(name: "Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let filter = ChromaticAberrationFilter()
                    filter.inputImage = await context.getImage(node.inputs[0].image)
                    filter.intensity = Float(node.inputs[1].float)
                    node.outputs[0] = .image(await context.addImage(filter.outputImage, 0))
                }
            )
        }

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
