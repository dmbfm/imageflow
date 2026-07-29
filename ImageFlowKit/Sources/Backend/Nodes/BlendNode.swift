import CoreImage
import CoreImage.CIFilterBuiltins
import Filters

extension Nodes.CoreImageCustom {
    public struct BlendNode: NodeImplProvider {
        public enum BlendMode: Int, CaseIterable {
            case additionCompositing
            case colorBlendMode
            case colorBurnBlendMode
            case colorDodgeBlendMode
            case darkenBlendMode
            case differenceBlendMode
            case divideBlendMode
            case exclusionBlendMode
            case hardLightBlendMode
            case hueBlendMode
            case lightenBlendMode
            case linearBurnBlendMode
            case linearDodgeBlendMode
            case linearLightBlendMode
            case luminosityBlendMode
            case maximumCompositing
            case minimumCompositing
            case multiplyBlendMode
            case overlayBlendMode
            case pinLightBlendMode
            case saturationBlendMode
            case screenBlendMode
            case softLightBlendMode
            case sourceAtopCompositing
            case sourceInCompositing
            case sourceOutCompositing
            case sourceOverCompositing
            case subtractBlendMode
            case vividLightBlendMode

            var displayName: String {
                switch self {
                case .additionCompositing: "Add"
                case .colorBlendMode: "Color Blend"
                case .colorBurnBlendMode: "Color Burn"
                case .colorDodgeBlendMode: "Color Dodge"
                case .darkenBlendMode: "Darken"
                case .differenceBlendMode: "Difference"
                case .divideBlendMode: "Divide"
                case .exclusionBlendMode: "Exclusion"
                case .hardLightBlendMode: "Hard Light"
                case .hueBlendMode: "Hue"
                case .lightenBlendMode: "Lighten"
                case .linearBurnBlendMode: "Linear Burn"
                case .linearDodgeBlendMode: "Linear Dodge"
                case .linearLightBlendMode: "Linear Light"
                case .luminosityBlendMode: "Luminosity"
                case .maximumCompositing: "Maximum"
                case .minimumCompositing: "Minimum"
                case .multiplyBlendMode: "Multiply"
                case .overlayBlendMode: "Overlay"
                case .pinLightBlendMode: "Pin Light"
                case .saturationBlendMode: "Saturation"
                case .screenBlendMode: "Screen"
                case .softLightBlendMode: "Soft Light"
                case .sourceAtopCompositing: "Source Atop"
                case .sourceInCompositing: "Source In"
                case .sourceOutCompositing: "Source Out"
                case .sourceOverCompositing: "Source Over"
                case .subtractBlendMode: "Subtract"
                case .vividLightBlendMode: "Vivid Light"
                }
            }

            var filter: CIFilter {
                switch self {
                case .additionCompositing: .additionCompositing()
                case .colorBlendMode: .colorBlendMode()
                case .colorBurnBlendMode: .colorBurnBlendMode()
                case .colorDodgeBlendMode: .colorDodgeBlendMode()
                case .darkenBlendMode: .darkenBlendMode()
                case .differenceBlendMode: .differenceBlendMode()
                case .divideBlendMode: .divideBlendMode()
                case .exclusionBlendMode: .exclusionBlendMode()
                case .hardLightBlendMode: .hardLightBlendMode()
                case .hueBlendMode: .hueBlendMode()
                case .lightenBlendMode: .lightenBlendMode()
                case .linearBurnBlendMode: .linearBurnBlendMode()
                case .linearDodgeBlendMode: .linearDodgeBlendMode()
                case .linearLightBlendMode: .linearLightBlendMode()
                case .luminosityBlendMode: .luminosityBlendMode()
                case .maximumCompositing: .maximumCompositing()
                case .minimumCompositing: .minimumCompositing()
                case .multiplyBlendMode: .multiplyBlendMode()
                case .overlayBlendMode: .overlayBlendMode()
                case .pinLightBlendMode: .pinLightBlendMode()
                case .saturationBlendMode: .saturationBlendMode()
                case .screenBlendMode: .screenBlendMode()
                case .softLightBlendMode: .softLightBlendMode()
                case .sourceAtopCompositing: .sourceAtopCompositing()
                case .sourceInCompositing: .sourceInCompositing()
                case .sourceOutCompositing: .sourceOutCompositing()
                case .sourceOverCompositing: .sourceOverCompositing()
                case .subtractBlendMode: .subtractBlendMode()
                case .vividLightBlendMode: .vividLightBlendMode()
                }
            }
        }

        static func impl(_ param: ()) -> NodeImpl {

            let schema = NodeSchema(
                name: "Blend",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                    .init(name: "Background Image", type: .image, semantics: .image, editorPlacement: .default),
                    .init(
                        name: "Blend Mode",
                        defaultValue: .int(0),
                        semantics: .integer(
                            .picker(BlendMode.allCases.map({ .init(label: $0.displayName, value: $0.rawValue) }))
                        ),
                        editorPlacement: .default
                    ),
                    .init(
                        name: "Amount",
                        defaultValue: .float(1.0),
                        semantics: .float(.range(0...1)),
                        editorPlacement: .default
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let blendMode = BlendMode(rawValue: node.inputs[2].int) ?? .colorBlendMode
                let filter = blendMode.filter
                let amount = node.inputs[3].float

                guard let backgroundImage = await context.getImage(node.inputs[1].image) else {
                    node.outputs[0] = .image(await context.addImage(nil, 0))
                    return
                }

                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(await context.addImage(backgroundImage, 0))
                    return
                }

                filter.setValue(backgroundImage, forKey: "inputBackgroundImage")

                if amount == 1.0 {
                    filter.setValue(inputImage, forKey: "inputImage")
                } else {
                    let mix = CIFilter.mix()
                    mix.inputImage = inputImage
                    mix.backgroundImage = clearImage
                    mix.amount = Float(amount)
                    if let image = mix.outputImage {
                        filter.setValue(image.cropped(to: inputImage.extent), forKey: "inputImage")
                    } else {
                        node.outputs[0] = .image(await context.addImage(backgroundImage, 0))
                        return
                    }
                }

                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(await context.addImage(nil, 0))
                }
            }
        }
    }

    public struct BlendWithMask: NodeImplProvider {
        public enum Mask: Int, CaseIterable {
            case red
            case green
            case blue
            case alpha
            case white

            public var displayName: String {
                switch self {
                case .red: "Red"
                case .green: "Green"
                case .blue: "Blue"
                case .alpha: "Alpha"
                case .white: "White"
                }
            }
        }

        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Blend With Mask",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                    .init(name: "Mask Image", type: .image, semantics: .image, editorPlacement: .default),
                    .init(name: "Background Image", type: .image, semantics: .image, editorPlacement: .default),
                    .init(
                        name: "Blend Mode",
                        defaultValue: .int(0),
                        semantics: .integer(
                            .picker(
                                BlendNode.BlendMode.allCases.map({ .init(label: $0.displayName, value: $0.rawValue) })
                            )
                        ),
                        editorPlacement: .default
                    ),
                    .init(
                        name: "Mask Type",
                        defaultValue: .int(Mask.alpha.rawValue),
                        semantics: .integer(
                            .picker(Mask.allCases.map({ .init(label: $0.displayName, value: $0.rawValue) }))
                        ),
                        editorPlacement: .default
                    ),
                    .init(
                        name: "Amount",
                        defaultValue: .float(1.0),
                        semantics: .float(.range(0...1)),
                        editorPlacement: .default
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let blendMode = BlendNode.BlendMode(rawValue: node.inputs[3].int) ?? .colorBlendMode
                let filter = blendMode.filter
                let maskType = Mask(rawValue: node.inputs[4].int) ?? .alpha
                let amount = node.inputs[5].float

                guard let backgroundImage = await context.getImage(node.inputs[2].image) else {
                    node.outputs[0] = .image(await context.addImage(nil, 0))
                    return
                }

                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(await context.addImage(backgroundImage, 0))
                    return
                }

                let maskImage = await context.getImage(node.inputs[1].image) ?? .white

                filter.setValue(backgroundImage, forKey: "inputBackgroundImage")

                let channel: MaskToAlphaFilter.MaskChannel =
                    switch maskType {
                    case .red: .red
                    case .green: .green
                    case .blue: .blue
                    case .alpha: .alpha
                    case .white: .white
                    }

                let maskToAlphaFilter = MaskToAlphaFilter(inputImage, maskImage: maskImage, channel: channel)
                guard let maskedImage = maskToAlphaFilter.outputImage?.cropped(to: inputImage.extent) else {
                    node.outputs[0] = .image(await context.addImage(backgroundImage, 0))
                    return
                }

                if amount == 1.0 {
                    filter.setValue(maskedImage, forKey: "inputImage")
                } else {
                    let mix = CIFilter.mix()
                    mix.inputImage = maskedImage
                    mix.backgroundImage = clearImage
                    mix.amount = Float(amount)
                    if let image = mix.outputImage {
                        filter.setValue(image.cropped(to: maskedImage.extent), forKey: "inputImage")
                    } else {
                        node.outputs[0] = .image(await context.addImage(backgroundImage, 0))
                        return
                    }
                }

                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(await context.addImage(nil, 0))
                }
            }
        }
    }
}

let clearImage: CIImage = {
    let filter = CIFilter(name: "CIConstantColorGenerator")!
    filter.setValue(CIColor.clear, forKey: "inputColor")
    return filter.outputImage!
}()
