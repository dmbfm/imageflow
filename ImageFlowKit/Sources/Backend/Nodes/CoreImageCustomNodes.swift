@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Filters
import Foundation
import GameKit
import Helpers
import Values

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
                        semantics: .float(.angle(nil)),
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
                    let angle = node.inputs[1].float
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

    // MARK: - Generator Nodes

    public struct RandomGeneratorNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Random Generator",
                displayName: "Random Generator",
                inputs: [
                    .init(name: "Width", defaultValue: .int(256)),
                    .init(name: "Height", defaultValue: .int(256)),
                    .init(name: "Seed", defaultValue: .int(0), semantics: .count),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ],
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let filter = CIFilter.randomGenerator()
                    let seed = node.inputs[2].int
                    let gm = GKMersenneTwisterRandomSource.init(seed: UInt64(seed.magnitude))
                    let x = CGFloat(floor(gm.nextUniform() * 512))
                    let y = CGFloat(floor(gm.nextUniform() * 512))
                    let outputImage = filter.outputImage?.cropped(
                        to: .init(
                            x: x,
                            y: y,
                            width: CGFloat(node.inputs[0].int),
                            height: CGFloat(node.inputs[1].int)
                        )
                    ).transformed(by: .init(translationX: -x, y: -y))
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                }
            )
        }
    }

    public struct BlurredRectangleGeneratorNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Blurred Rectangle",
                displayName: "Blurred Rectangle",
                inputs: [
                    .init(name: "Width", defaultValue: .int(256), semantics: .integer(.partialRangeFrom(1))),
                    .init(name: "Height", defaultValue: .int(256), semantics: .integer(.partialRangeFrom(1))),
                    .init(name: "Blur", defaultValue: .float(10)),
                    .init(name: "Color", defaultValue: .color4(.white)),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ],
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let filter = CIFilter.blurredRectangleGenerator()
                    let width = node.inputs[0].int
                    let height = node.inputs[1].int
                    let blur = node.inputs[2].float
                    let color = node.inputs[3].color4
                    filter.extent = .init(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
                    filter.sigma = Float(blur)
                    filter.color = color.ciColor
                    node.outputs[0] = .image(await context.addImage(filter.outputImage, 0))
                }
            )
        }
    }

    public struct BlurredRoundedRectangleGeneratorNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Blurred Rounded Rectangle",
                displayName: "Blurred Rounded Rectangle",
                inputs: [
                    .init(name: "Width", defaultValue: .int(256), semantics: .integer(.partialRangeFrom(1))),
                    .init(name: "Height", defaultValue: .int(256), semantics: .integer(.partialRangeFrom(1))),
                    .init(name: "Radius", defaultValue: .float(10)),
                    .init(name: "Smoothness", defaultValue: .float(0)),
                    .init(name: "Blur", defaultValue: .float(10)),
                    .init(name: "Color", defaultValue: .color4(.white)),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ],
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let filter = CIFilter.blurredRoundedRectangleGenerator()
                    let width = node.inputs[0].int
                    let height = node.inputs[1].int
                    let radius = node.inputs[2].float
                    let smoothness = node.inputs[3].float
                    let blur = node.inputs[4].float
                    let color = node.inputs[5].color4
                    filter.extent = .init(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
                    filter.radius = Float(radius)
                    filter.sigma = Float(blur)
                    filter.smoothness = Float(smoothness)
                    filter.color = color.ciColor
                    node.outputs[0] = .image(await context.addImage(filter.outputImage, 0))
                }
            )
        }
    }

    public struct RoundedRectangleGeneratorNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Rounded Rectangle",
                displayName: "Rounded Rectangle",
                inputs: [
                    .init(name: "Width", defaultValue: .int(256), semantics: .integer(.partialRangeFrom(1))),
                    .init(name: "Height", defaultValue: .int(256), semantics: .integer(.partialRangeFrom(1))),
                    .init(name: "Radius", defaultValue: .float(10)),
                    .init(name: "Smoothness", defaultValue: .float(0)),
                    .init(name: "Color", defaultValue: .color4(.white)),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ],
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let filter = CIFilter.roundedRectangleGenerator()
                    let width = node.inputs[0].int
                    let height = node.inputs[1].int
                    let radius = node.inputs[2].float
                    let smoothness = node.inputs[3].float
                    let color = node.inputs[4].color4
                    filter.extent = .init(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
                    filter.radius = Float(radius)
                    filter.smoothness = Float(smoothness)
                    filter.color = color.ciColor
                    node.outputs[0] = .image(await context.addImage(filter.outputImage, 0))
                }
            )
        }
    }

    public struct RoundedRectangleStrokeGeneratorNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Rounded Rectangle Stroke",
                displayName: "Rounded Rectangle Stroke",
                inputs: [
                    .init(name: "Width", defaultValue: .int(256), semantics: .integer(.partialRangeFrom(1))),
                    .init(name: "Height", defaultValue: .int(256), semantics: .integer(.partialRangeFrom(1))),
                    .init(name: "Radius", defaultValue: .float(10)),
                    .init(name: "Smoothness", defaultValue: .float(0)),
                    .init(name: "Color", defaultValue: .color4(.white)),
                    .init(name: "Stroke Width", defaultValue: .float(10)),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ],
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let filter = CIFilter.roundedRectangleStrokeGenerator()
                    let width = node.inputs[0].int
                    let height = node.inputs[1].int
                    let radius = node.inputs[2].float
                    let smoothness = node.inputs[3].float
                    let color = node.inputs[4].color4
                    let sw = node.inputs[5].float
                    filter.extent = .init(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
                    filter.radius = Float(radius)
                    filter.smoothness = Float(smoothness)
                    filter.color = color.ciColor
                    filter.width = Float(sw)
                    node.outputs[0] = .image(await context.addImage(filter.outputImage, 0))
                }
            )
        }
    }

    public struct StripesGeneratorNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Stripes",
                displayName: "Stripes",
                inputs: [
                    .init(name: "Width", defaultValue: .int(300), semantics: .integer(.partialRangeFrom(1))),
                    .init(name: "Height", defaultValue: .int(300), semantics: .integer(.partialRangeFrom(1))),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150, y: 150))),
                    .init(name: "Color 1", defaultValue: .color4(.red)),
                    .init(name: "Color 2", defaultValue: .color4(.white)),
                    .init(name: "Size", defaultValue: .float(40)),
                    .init(name: "Sharpness", defaultValue: .float(1.0)),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ],
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let filter = CIFilter.stripesGenerator()
                    filter.center = node.inputs[2].vector2.cgPoint
                    filter.color0 = node.inputs[3].color4.ciColor
                    filter.color1 = node.inputs[4].color4.ciColor
                    filter.width = Float(node.inputs[5].float)
                    filter.sharpness = Float(node.inputs[6].float)
                    let width = node.inputs[0].int.clamped(to: 1...Int.max)
                    let height = node.inputs[1].int.clamped(to: 1...Int.max)
                    let outputImage = filter.outputImage?.cropped(
                        to: .init(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
                    )
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                }
            )
        }
    }

    public struct CheckerboardGeneratorNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Checkerboard",
                displayName: "Checkerboard",
                inputs: [
                    .init(name: "Width", defaultValue: .int(300), semantics: .integer(.partialRangeFrom(1))),
                    .init(name: "Height", defaultValue: .int(300), semantics: .integer(.partialRangeFrom(1))),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150, y: 150))),
                    .init(name: "Color 1", defaultValue: .color4(.red)),
                    .init(name: "Color 2", defaultValue: .color4(.white)),
                    .init(name: "Size", defaultValue: .float(40)),
                    .init(name: "Sharpness", defaultValue: .float(1.0)),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ],
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let filter = CIFilter.checkerboardGenerator()
                    filter.center = node.inputs[2].vector2.cgPoint
                    filter.color0 = node.inputs[3].color4.ciColor
                    filter.color1 = node.inputs[4].color4.ciColor
                    filter.width = Float(node.inputs[5].float)
                    filter.sharpness = Float(node.inputs[6].float)
                    let width = node.inputs[0].int.clamped(to: 1...Int.max)
                    let height = node.inputs[1].int.clamped(to: 1...Int.max)
                    let outputImage = filter.outputImage?.cropped(
                        to: .init(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
                    )
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                }
            )
        }
    }

    public struct StarShineGeneratorNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Star Shine",
                displayName: "Star Shine",
                inputs: [
                    .init(name: "Width", defaultValue: .int(300), semantics: .integer(.partialRangeFrom(1))),
                    .init(name: "Height", defaultValue: .int(300), semantics: .integer(.partialRangeFrom(1))),
                    .init(name: "Center", defaultValue: .vector2(.init(x: 150, y: 150))),
                    .init(name: "Color", defaultValue: .color4(.red)),
                    .init(name: "Radius", defaultValue: .float(50)),
                    .init(name: "Cross Scale", defaultValue: .float(15)),
                    .init(name: "Cross Angle", defaultValue: .float(0.6), semantics: .float(.angle(0...(2 * .pi)))),
                    .init(name: "Cross Opacity", defaultValue: .float(-2.0)),
                    .init(name: "Cross Width", defaultValue: .float(0.5)),
                    .init(name: "Epsilon", defaultValue: .float(1.0)),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ],
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let filter = CIFilter.starShineGenerator()
                    filter.center = node.inputs[2].vector2.cgPoint
                    filter.color = node.inputs[3].color4.ciColor
                    filter.radius = Float(node.inputs[4].float)
                    filter.crossScale = Float(node.inputs[5].float)
                    filter.crossAngle = Float(node.inputs[6].float)
                    filter.crossOpacity = Float(node.inputs[7].float)
                    filter.crossWidth = Float(node.inputs[8].float)
                    filter.epsilon = Float(node.inputs[9].float)
                    let width = node.inputs[0].int.clamped(to: 1...Int.max)
                    let height = node.inputs[1].int.clamped(to: 1...Int.max)
                    let outputImage = filter.outputImage?.cropped(
                        to: .init(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
                    )
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                }
            )
        }
    }

    public struct ConstantColorGeneratorNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Constant Color",
                displayName: "Constant Color",
                inputs: [
                    .init(name: "Width", defaultValue: .int(256)),
                    .init(name: "Height", defaultValue: .int(256)),
                    .init(name: "Color", defaultValue: .color4(.red)),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ],
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let filter = CIFilter(name: "CIConstantColorGenerator")!
                    filter.setValue(node.inputs[2].color4.ciColor, forKey: "inputColor")
                    let outputImage = filter.outputImage
                    let width = node.inputs[0].int.clamped(to: 1...Int.max)
                    let height = node.inputs[1].int.clamped(to: 1...Int.max)
                    if let outputImage, !outputImage.extent.isEmpty {
                        node.outputs[0] = .image(
                            await context.addImage(
                                outputImage.cropped(
                                    to: .init(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
                                ),
                                0
                            )
                        )
                    } else {
                        node.outputs[0] = .image(.none)
                    }
                }
            )
        }
    }

    public struct PersonSegmentationNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Person Segmentation",
                inputs: [
                    .init(
                        name: "Image",
                        type: .image,
                        semantics: .image
                    ),
                    .init(
                        name: "Quality Level",
                        defaultValue: .int(2),
                        semantics: .integer(
                            .picker([
                                .init(label: "Accurate", value: 0),
                                .init(label: "Balanced", value: 1),
                                .init(label: "Fast", value: 2),
                            ])
                        )
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIPersonSegmentation")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }
                filter.setValue(inputImage, forKey: "inputImage")
                filter.setValue(node.inputs[1].int, forKey: "inputQualityLevel")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    let scaleX = inputImage.extent.width / outputImage.extent.width
                    let scaleY = inputImage.extent.height / outputImage.extent.height
                    let finalImage = outputImage.transformed(by: .init(scaleX: scaleX, y: scaleY))
                    node.outputs[0] = .image(await context.addImage(finalImage, 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIConvolution3X3Node: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Convolution 3x3",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Kernel", defaultValue: .matrix3x3(.init([0, 0, 0, 0, 1, 0, 0, 0, 0]))),
                    .init(name: "Bias", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIConvolutionRGB3X3")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }

                filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                filter.setValue(
                    CIVector(values: node.inputs[1].matrix3x3.values.map({ CGFloat($0) }), count: 9),
                    forKey: "inputWeights"
                )
                filter.setValue(node.inputs[2].float, forKey: "inputBias")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIConvolution5x5Node: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Convolution 5x5",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Kernel",
                        defaultValue: .matrix5x5(
                            .init([
                                0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0,
                                0, 0, 1, 0, 0,
                                0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0,
                            ])
                        )
                    ),
                    .init(name: "Bias", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIConvolutionRGB5X5")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }

                filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                filter.setValue(
                    CIVector(values: node.inputs[1].matrix5x5.values.map({ CGFloat($0) }), count: 25),
                    forKey: "inputWeights"
                )
                filter.setValue(node.inputs[2].float, forKey: "inputBias")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct CIConvolution7x7Node: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Convolution 7x7",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Kernel",
                        defaultValue: .matrix7x7(
                            .init([
                                0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 1, 0, 0, 0,
                                0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0, 0, 0,
                            ])
                        )
                    ),
                    .init(name: "Bias", defaultValue: .float(0.0), semantics: .default),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIConvolutionRGB7X7")!
                guard let inputImage = await context.getImage(node.inputs[0].image) else {
                    node.outputs[0] = .image(.none)
                    return
                }

                filter.setValue(inputImage.clampedToExtent(), forKey: "inputImage")
                filter.setValue(
                    CIVector(values: node.inputs[1].matrix7x7.values.map({ CGFloat($0) }), count: 49),
                    forKey: "inputWeights"
                )
                filter.setValue(node.inputs[2].float, forKey: "inputBias")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                } else {
                    node.outputs[0] = .image(.none)
                }
            }
        }
    }

    public struct KMeansNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "KMeans Palette",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    // .init(name: "Extent", type: .rect, semantics: .rectangle),
                    // .init(name: "Means", type: .image, semantics: .image),
                    .init(name: "Count", defaultValue: .int(8), semantics: .integer(.partialRangeFrom(0))),
                    .init(name: "Passes", defaultValue: .int(2), semantics: .integer(.partialRangeFrom(0))),
                    .init(name: "Perceptual", defaultValue: .bool(false), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIKMeans")!
                let inputImage = await context.getImage(node.inputs[0].image)

                if let image = inputImage, !image.extent.isEmpty, !image.extent.isInfinite {
                    let size = 128.0
                    let smallImage = image.transformed(
                        by: .init(scaleX: size / image.extent.width, y: size / image.extent.height),
                        highQualityDownsample: false
                    )
                    .cropped(to: .init(x: image.extent.origin.x, y: image.extent.origin.y, width: size, height: size))
                    filter.setValue(smallImage, forKey: "inputImage")
                    filter.setValue(CIVector(cgRect: smallImage.extent), forKey: "inputExtent")
                }

                filter.setValue(node.inputs[1].int, forKey: "inputCount")
                filter.setValue(node.inputs[2].int, forKey: "inputPasses")
                filter.setValue(node.inputs[3].bool, forKey: "inputPerceptual")

                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(
                        await context.addImage(outputImage.settingAlphaOne(in: outputImage.extent), 0)
                    )
                } else {
                    node.outputs[0] = .image(await context.addImage(nil, 0))
                }
            }
        }
    }

    public struct PalettizeKMeans: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Palettize (KMeans)",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    // .init(name: "Extent", type: .rect, semantics: .rectangle),
                    // .init(name: "Means", type: .image, semantics: .image),
                    .init(name: "Count", defaultValue: .int(8), semantics: .integer(.partialRangeFrom(0))),
                    .init(name: "Passes", defaultValue: .int(5), semantics: .integer(.partialRangeFrom(0))),
                    .init(name: "Perceptual", defaultValue: .bool(false), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CIKMeans")!
                let inputImage = await context.getImage(node.inputs[0].image)

                if let image = inputImage, !image.extent.isEmpty, !image.extent.isInfinite {
                    let size = 128.0
                    let smallImage = image.transformed(
                        by: .init(scaleX: size / image.extent.width, y: size / image.extent.height),
                        highQualityDownsample: false
                    )
                    .cropped(to: .init(x: image.extent.origin.x, y: image.extent.origin.y, width: size, height: size))
                    filter.setValue(smallImage, forKey: "inputImage")
                    filter.setValue(CIVector(cgRect: smallImage.extent), forKey: "inputExtent")
                }

                filter.setValue(node.inputs[1].int, forKey: "inputCount")
                filter.setValue(node.inputs[2].int, forKey: "inputPasses")
                filter.setValue(node.inputs[3].bool, forKey: "inputPerceptual")

                let palettizeFilter = CIFilter.palettize()
                palettizeFilter.inputImage = inputImage

                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {

                    palettizeFilter.paletteImage = outputImage.settingAlphaOne(in: outputImage.extent)
                    palettizeFilter.perceptual = node.inputs[3].bool

                    if let finalImage = palettizeFilter.outputImage {
                        node.outputs[0] = .image(
                            await context.addImage(finalImage, 0)
                        )
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                } else {
                    node.outputs[0] = .image(await context.addImage(nil, 0))
                }
            }
        }
    }

    public struct GaussianGradientNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Gaussian Gradient",
                inputs: [
                    .init(name: "Radius", defaultValue: .float(300), semantics: .distance),
                    .init(
                        name: "Color 0",
                        defaultValue: .color4(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                        semantics: .color
                    ),
                    .init(
                        name: "Color 1",
                        defaultValue: .color4(.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)),
                        semantics: .color
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter.gaussianGradient()
                filter.center = .zero
                filter.radius = Float(node.inputs[0].float)
                filter.color0 = node.inputs[1].color4.ciColor
                filter.color1 = node.inputs[2].color4.ciColor
                node.outputs[0] = .image(await context.addImage(filter.outputImage, 0))
            }
        }
    }

    public struct DistanceGradientFromRedMaskNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Distance Gradient From Red Mask",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Maximum Distance", defaultValue: .float(10.0), semantics: .distance),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let filter = CIFilter.distanceGradientFromRedMask()

                    let inputImage = await context.getImage(node.inputs[0].image)

                    filter.inputImage = inputImage
                    filter.maximumDistance = Float(node.inputs[1].float)

                    let cropToSource = node.inputs[2].bool
                    let outputImage = filter.outputImage

                    if let inputImage, let outputImage {
                        if cropToSource {
                            node.outputs[0] = .image(
                                await context.addImage(outputImage.cropped(to: inputImage.extent), 0)
                            )
                        } else {
                            node.outputs[0] = .image(await context.addImage(outputImage, 0))
                        }
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            )
        }
    }

    public struct SignedDistanceGradientFromRedMaskNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Signed Distance Gradient From Red Mask",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(name: "Maximum Distance", defaultValue: .float(10.0), semantics: .distance),
                    .init(name: "Crop to Source", defaultValue: .bool(true), semantics: .boolean),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let filter = CIFilter.signedDistanceGradientFromRedMask()

                    let inputImage = await context.getImage(node.inputs[0].image)

                    filter.inputImage = inputImage
                    filter.maximumDistance = Float(node.inputs[1].float)

                    let cropToSource = node.inputs[2].bool
                    let outputImage = filter.outputImage

                    if let inputImage, let outputImage {
                        if cropToSource {
                            node.outputs[0] = .image(
                                await context.addImage(outputImage.cropped(to: inputImage.extent), 0)
                            )
                        } else {
                            node.outputs[0] = .image(await context.addImage(outputImage, 0))
                        }
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            )
        }
    }

    public struct ColorClampCustom: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Clamp",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image),
                    .init(
                        name: "Ranges",
                        defaultValue: .floatArray([
                            0.0, 1.0,
                            0.0, 1.0,
                            0.0, 1.0,
                            0.0, 1.0,
                        ]),
                        semantics: .floatArray(.colorClamp),
                        editorPlacement: .init(nodeView: .hidden, inspector: .controls)
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let filter = CIFilter(name: "CIColorClamp")!
                    guard let inputImage = await context.getImage(node.inputs[0].image) else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                        return
                    }
                    let arr = node.inputs[1].floatArray
                    filter.setValue(inputImage, forKey: "inputImage")
                    filter.setValue(CIVector(x: arr[0], y: arr[2], z: arr[4], w: arr[6]), forKey: "inputMinComponents")
                    filter.setValue(CIVector(x: arr[1], y: arr[3], z: arr[5], w: arr[7]), forKey: "inputMaxComponents")
                    let outputImage = filter.outputImage
                    if let outputImage, !outputImage.extent.isEmpty {
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: inputImage.extent), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            )
        }
    }

    public struct TemperatureAntTint: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Temperature and Tint",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                    .init(
                        name: "Temperature",
                        defaultValue: .float(6500),
                        semantics: .float(.range(2000...10000)),
                        editorPlacement: .default
                    ),
                    .init(
                        name: "Tint",
                        defaultValue: .float(0),
                        semantics: .float(.range(-100...100)),
                        editorPlacement: .default
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let filter = CIFilter(name: "CITemperatureAndTint")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(x: 6500.0, y: 0.0), forKey: "inputNeutral")
                filter.setValue(
                    CIVector(x: node.inputs[1].float, y: node.inputs[2].float),
                    forKey: "inputTargetNeutral"
                )
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(await context.addImage(nil, 0))
                }
            }
        }
    }

    public struct ToneMapNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Tone Map",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                    .init(
                        name: "Black Point",
                        defaultValue: .float(0),
                        semantics: .float(.range(0...1)),
                        editorPlacement: .default
                    ),
                    .init(
                        name: "Shadows",
                        defaultValue: .float(0.25),
                        semantics: .float(.range(0...1)),
                        editorPlacement: .default
                    ),
                    .init(
                        name: "Midtones",
                        defaultValue: .float(0.50),
                        semantics: .float(.range(0...1)),
                        editorPlacement: .default
                    ),
                    .init(
                        name: "Highlights",
                        defaultValue: .float(0.75),
                        semantics: .float(.range(0...1)),
                        editorPlacement: .default
                    ),
                    .init(
                        name: "White Point",
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
                let filter = CIFilter(name: "CIToneCurve")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(CIVector(x: 0.0, y: node.inputs[1].float), forKey: "inputPoint0")
                filter.setValue(CIVector(x: 0.25, y: node.inputs[2].float), forKey: "inputPoint1")
                filter.setValue(CIVector(x: 0.50, y: node.inputs[3].float), forKey: "inputPoint2")
                filter.setValue(CIVector(x: 0.75, y: node.inputs[4].float), forKey: "inputPoint3")
                filter.setValue(CIVector(x: 1.0, y: node.inputs[5].float), forKey: "inputPoint4")
                filter.setValue(true, forKey: "inputExtrapolate")
                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(await context.addImage(nil, 0))
                }
            }
        }
    }

    public struct ColorMapNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color Map",
                inputs: [
                    .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                    .init(
                        name: "Gradient",
                        defaultValue: .gradientData(.default),
                        editorPlacement: .init(nodeView: .hidden, inspector: .controls)
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(schema: schema) { node, context in
                let grad = GradientFilter(node.inputs[1].gradientData, p0: .init(x: 0, y: 0), p1: .init(x: 256, y: 0))
                let gradImage = grad.outputImage!.cropped(to: .init(x: 0, y: 0, width: 256, height: 1))

                let filter = CIFilter(name: "CIColorMap")!
                filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                filter.setValue(gradImage, forKey: "inputGradientImage")

                let outputImage = filter.outputImage
                if let outputImage, !outputImage.extent.isEmpty {
                    node.outputs[0] = .image(await context.addImage(outputImage, 0))
                } else {
                    node.outputs[0] = .image(await context.addImage(nil, 0))
                }
            }
        }
    }

    public struct LinearGradientNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Linear Gradient",
                inputs: [
                    .init(name: "Start Point", defaultValue: .vector2(.init(x: 0, y: 0))),
                    .init(name: "End Point", defaultValue: .vector2(.init(x: 256, y: 256))),
                    .init(name: "Width", defaultValue: .int(256)),
                    .init(name: "Height", defaultValue: .int(256)),
                    .init(
                        name: "Colors",
                        defaultValue: .gradientData(.default),
                        editorPlacement: .init(nodeView: .hidden, inspector: .controls)
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let gradientData = node.inputs[4].gradientData
                    let p0 = node.inputs[0].vector2
                    let p1 = node.inputs[1].vector2
                    let width = node.inputs[2].int
                    let height = node.inputs[3].int
                    let gradientFilter = GradientFilter(gradientData, p0: p0, p1: p1)
                    if let image = gradientFilter.outputImage?.cropped(
                        to: .init(x: 0, y: 0, width: width, height: height)
                    ) {
                        node.outputs[0] = .image(await context.addImage(image, 0))
                    }
                }
            )
        }
    }

    public struct RadialGradientNode: NodeImplProvider {
        public static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Radial Gradient",
                inputs: [
                    .init(name: "Inner Radius", defaultValue: .float(0.0)),
                    .init(name: "Outer Radius", defaultValue: .float(128.0)),
                    .init(name: "Padding", defaultValue: .int(0), semantics: .integer(.partialRangeFrom(0))),
                    .init(
                        name: "Colors",
                        defaultValue: .gradientData(.default),
                        editorPlacement: .init(nodeView: .hidden, inspector: .controls)
                    ),
                ],
                outputs: [
                    .init(name: "Output Image", type: .image)
                ]
            )

            return .init(
                schema: schema,
                runImpl: { node, context in
                    let gradientData = node.inputs[3].gradientData
                    let padding = node.inputs[2].int
                    let r0 = node.inputs[0].float.clamped(to: 0.0...Double.greatestFiniteMagnitude)
                    let r1 = node.inputs[1].float.clamped(to: r0...Double.greatestFiniteMagnitude)
                    let c = Int(ceil(r1)) + padding
                    let size = 2 * c + 1
                    let p0 = Vector2(x: Double(c), y: Double(c))
                    let p1 = Vector2(x: r0, y: r1)
                    let width = size
                    let height = size
                    let gradientFilter = GradientFilter(gradientData, gradientType: .radial, p0: p0, p1: p1)
                    if let image = gradientFilter.outputImage?.cropped(
                        to: .init(x: 0, y: 0, width: width, height: height)
                    ) {
                        node.outputs[0] = .image(await context.addImage(image, 0))
                    }
                }
            )
        }
    }
}
