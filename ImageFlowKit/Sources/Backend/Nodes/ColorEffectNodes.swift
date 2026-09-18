@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Filters
import Foundation
import Helpers
import Values

extension Nodes {
    struct ColorEffect {
        static var applyDitherNoise: NodeImpl {
            let schema = NodeSchema(
                name: "Apply Dither Noise",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                    .init(
                        name: "Intensity",
                        defaultValue: .float(0.1),
                        semantics: .float(.range(0.0...1.0)),
                        editorPlacement: .default
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIDither")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(node.inputs[1].float, forKey: "inputIntensity")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(await context.addImage(nil, 0))
                }
            }
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

        static var photoEffect: NodeImpl {

            enum Type: Int, CaseIterable, Sendable {
                case chrome
                case fade
                case instant
                case mono
                case noir
                case process
                case tonal
                case transfer

                static let `default`: Self = .chrome

                var displayName: String {
                    switch self {
                    case .chrome: "Chrome"
                    case .fade: "Fade"
                    case .instant: "Instant"
                    case .mono: "Mono"
                    case .noir: "Noir"
                    case .process: "Process"
                    case .tonal: "Tonal"
                    case .transfer: "Transfer"
                    }
                }

                var filter: CIFilter {
                    switch self {

                    case .chrome: CIFilter.photoEffectChrome()
                    case .fade: CIFilter.photoEffectFade()
                    case .instant: CIFilter.photoEffectInstant()
                    case .mono: CIFilter.photoEffectMono()
                    case .noir: CIFilter.photoEffectNoir()
                    case .process: CIFilter.photoEffectProcess()
                    case .tonal: CIFilter.photoEffectTonal()
                    case .transfer: CIFilter.photoEffectTransfer()
                    }
                }
            }

            let schema = NodeSchema(
                name: "Photo Effect",
                inputs: [
                    .init(name: "Image", type: .image),
                    .init(
                        name: "Type",
                        defaultValue: .int(Type.default.rawValue),
                        semantics: .integer(
                            .picker(Type.allCases.map({ .init(label: $0.displayName, value: $0.rawValue) }))
                        )
                    ),
                ],
                outputs: [
                    .init(name: "Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let ty: Type = .init(rawValue: node.inputs[1].int)!
                    let filter = ty.filter

                    filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                    let outputImage = filter.outputImage
                    if let outputImage, !outputImage.extent.isEmpty {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            )
        }
    }
}
