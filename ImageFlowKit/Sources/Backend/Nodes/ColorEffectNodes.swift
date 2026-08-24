@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Filters
import Foundation
import Helpers
import Values

extension Nodes {
    struct ColorEffect {
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
    }
}
