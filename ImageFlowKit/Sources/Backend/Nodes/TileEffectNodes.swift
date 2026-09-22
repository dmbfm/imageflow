import CoreGraphics
import CoreImage
import Foundation
import Values

extension Nodes {
    struct TileEffectNodes {

        public struct TileNode: NodeImplProvider {
            public static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Regular Tile",
                    inputs: [
                        .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                        .init(name: "Scale", defaultValue: .float(1.0)),
                        .init(name: "Columns", defaultValue: .int(2), semantics: .integer(.partialRangeFrom(1))),
                        .init(name: "Rows", defaultValue: .int(2), semantics: .integer(.partialRangeFrom(1))),
                    ],
                    outputs: [
                        .init(name: "Output Image", type: .image)
                    ]
                )

                return .init(schema: schema) { node, context in
                    let filter = CIFilter.affineTile()  //CIFilter(name: "CIAffineTile")!
                    guard let inputImage = await context.getImage(node.inputs[0].image) else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                        return
                    }
                    // filter.inpu
                    let scale = node.inputs[1].float
                    filter.transform = .init(scaleX: scale, y: scale)
                    filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                    // #if os(macOS)
                    // filter.setValue(node.inputs[1].affineTransform.fAffineTransform, forKey: "inputTransform")
                    // #else
                    // filter.setValue(node.inputs[1].affineTransform.nsValue, forKey: "inputTransform")
                    // #endif
                    let ext = inputImage.extent
                    let cols = node.inputs[2].int
                    let rows = node.inputs[3].int
                    let rect = CGRect(
                        x: ext.origin.x * scale,
                        y: ext.origin.y * scale,
                        width: Double(cols) * ext.width * scale,
                        height: Double(rows) * ext.height * scale
                    )
                    let outputImage = filter.outputImage?.cropped(to: rect)
                    if let outputImage, !outputImage.extent.isEmpty {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            }
        }

        public struct AffineTileNode: NodeImplProvider {
            public static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Affine Tile",
                    inputs: [
                        .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                        .init(
                            name: "Transform",
                            defaultValue: .affineTransform(
                                .init(m11: 0.4, m12: 0.0, m21: 0.0, m22: 0.4, tX: 0.0, tY: 0.0)
                            ),
                            semantics: .transform,
                            editorPlacement: .default
                        ),
                        .init(name: "Rectangle", defaultValue: .rect(.init(x: 0, y: 0, width: 150, height: 150))),
                    ],
                    outputs: [
                        .init(name: "Output Image", type: .image)
                    ]
                )

                return .init(schema: schema) { node, context in
                    let filter = CIFilter(name: "CIAffineTile")!
                    filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                    #if os(macOS)
                    filter.setValue(node.inputs[1].affineTransform.fAffineTransform, forKey: "inputTransform")
                    #else
                    filter.setValue(node.inputs[1].affineTransform.nsValue, forKey: "inputTransform")
                    #endif
                    let outputImage = filter.outputImage?.cropped(to: node.inputs[2].rect)
                    if let outputImage, !outputImage.extent.isEmpty {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            }
        }

        public struct EightfoldReflectedTileNode: NodeImplProvider {
            public static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Eightfold Reflected Tile",
                    inputs: [
                        .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                        .init(
                            name: "Center",
                            defaultValue: .vector2(.init(x: 150.0, y: 150.0)),
                            semantics: .position2,
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Angle",
                            defaultValue: .float(0.0),
                            semantics: .float(.angle(-3.141592653589793...3.141592653589793)),
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Width",
                            defaultValue: .float(100.0),
                            semantics: .distance,
                            editorPlacement: .default
                        ),
                        .init(name: "Rectangle", defaultValue: .rect(.init(x: 0, y: 0, width: 150, height: 150))),
                    ],
                    outputs: [
                        .init(name: "Output Image", type: .image)
                    ]
                )

                return .init(schema: schema) { node, context in
                    let filter = CIFilter(name: "CIEightfoldReflectedTile")!
                    filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                    filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                    filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                    filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                    let outputImage = filter.outputImage?.cropped(to: node.inputs[4].rect)
                    if let outputImage, !outputImage.extent.isEmpty {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            }
        }

        public struct FourfoldReflectedTileNode: NodeImplProvider {
            public static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Fourfold Reflected Tile",
                    inputs: [
                        .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                        .init(
                            name: "Center",
                            defaultValue: .vector2(.init(x: 150.0, y: 150.0)),
                            semantics: .position2,
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Angle",
                            defaultValue: .float(0.0),
                            semantics: .float(.angle(-3.141592653589793...3.141592653589793)),
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Width",
                            defaultValue: .float(100.0),
                            semantics: .distance,
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Acute Angle",
                            defaultValue: .float(1.5707963267948966),
                            semantics: .float(.angle(-3.141592653589793...3.141592653589793)),
                            editorPlacement: .default
                        ),
                        .init(name: "Rectangle", defaultValue: .rect(.init(x: 0, y: 0, width: 150, height: 150))),
                    ],
                    outputs: [
                        .init(name: "Output Image", type: .image)
                    ]
                )

                return .init(schema: schema) { node, context in
                    let filter = CIFilter(name: "CIFourfoldReflectedTile")!
                    filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                    filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                    filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                    filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                    filter.setValue(node.inputs[4].float, forKey: "inputAcuteAngle")
                    let outputImage = filter.outputImage?.cropped(to: node.inputs[5].rect)
                    if let outputImage, !outputImage.extent.isEmpty {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            }
        }

        public struct FourfoldRotatedTileNode: NodeImplProvider {
            public static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Fourfold Rotated Tile",
                    inputs: [
                        .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                        .init(
                            name: "Center",
                            defaultValue: .vector2(.init(x: 150.0, y: 150.0)),
                            semantics: .position2,
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Angle",
                            defaultValue: .float(0.0),
                            semantics: .float(.angle(-3.141592653589793...3.141592653589793)),
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Width",
                            defaultValue: .float(100.0),
                            semantics: .distance,
                            editorPlacement: .default
                        ),
                        .init(name: "Rectangle", defaultValue: .rect(.init(x: 0, y: 0, width: 150, height: 150))),
                    ],
                    outputs: [
                        .init(name: "Output Image", type: .image)
                    ]
                )

                return .init(schema: schema) { node, context in
                    let filter = CIFilter(name: "CIFourfoldRotatedTile")!
                    filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                    filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                    filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                    filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                    let outputImage = filter.outputImage?.cropped(to: node.inputs[4].rect)
                    if let outputImage, !outputImage.extent.isEmpty {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            }
        }

        public struct FourfoldTranslatedTileNode: NodeImplProvider {
            public static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Fourfold Translated Tile",
                    inputs: [
                        .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                        .init(
                            name: "Center",
                            defaultValue: .vector2(.init(x: 150.0, y: 150.0)),
                            semantics: .position2,
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Angle",
                            defaultValue: .float(0.0),
                            semantics: .float(.angle(-3.141592653589793...3.141592653589793)),
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Width",
                            defaultValue: .float(100.0),
                            semantics: .distance,
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Acute Angle",
                            defaultValue: .float(1.5707963267948966),
                            semantics: .float(.angle(-3.141592653589793...3.141592653589793)),
                            editorPlacement: .default
                        ),
                        .init(name: "Rectangle", defaultValue: .rect(.init(x: 0, y: 0, width: 150, height: 150))),
                    ],
                    outputs: [
                        .init(name: "Output Image", type: .image)
                    ]
                )

                return .init(schema: schema) { node, context in
                    let filter = CIFilter(name: "CIFourfoldTranslatedTile")!
                    filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                    filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                    filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                    filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                    filter.setValue(node.inputs[4].float, forKey: "inputAcuteAngle")
                    let outputImage = filter.outputImage?.cropped(to: node.inputs[5].rect)
                    if let outputImage, !outputImage.extent.isEmpty {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            }
        }

        public struct GlideReflectedTileNode: NodeImplProvider {
            public static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Glide Reflected Tile",
                    inputs: [
                        .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                        .init(
                            name: "Center",
                            defaultValue: .vector2(.init(x: 150.0, y: 150.0)),
                            semantics: .position2,
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Angle",
                            defaultValue: .float(0.0),
                            semantics: .float(.angle(-3.141592653589793...3.141592653589793)),
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Width",
                            defaultValue: .float(100.0),
                            semantics: .distance,
                            editorPlacement: .default
                        ),
                        .init(name: "Rectangle", defaultValue: .rect(.init(x: 0, y: 0, width: 150, height: 150))),
                    ],
                    outputs: [
                        .init(name: "Output Image", type: .image)
                    ]
                )

                return .init(schema: schema) { node, context in
                    let filter = CIFilter(name: "CIGlideReflectedTile")!
                    filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                    filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                    filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                    filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                    let outputImage = filter.outputImage?.cropped(to: node.inputs[4].rect)
                    if let outputImage, !outputImage.extent.isEmpty {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            }
        }

        public struct KaleidoscopeNode: NodeImplProvider {
            public static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Kaleidoscope",
                    inputs: [
                        .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                        .init(
                            name: "Count",
                            defaultValue: .int(6),
                            semantics: .integer(.partialRangeFrom(0)),
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Center",
                            defaultValue: .vector2(.init(x: 150.0, y: 150.0)),
                            semantics: .position2,
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Angle",
                            defaultValue: .float(0.0),
                            semantics: .float(.angle(-3.141592653589793...3.141592653589793)),
                            editorPlacement: .default
                        ),
                    ],
                    outputs: [
                        .init(name: "Output Image", type: .image)
                    ]
                )

                return .init(schema: schema) { node, context in
                    let filter = CIFilter(name: "CIKaleidoscope")!
                    filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                    filter.setValue(node.inputs[1].int, forKey: "inputCount")
                    filter.setValue(node.inputs[2].vector2.ciVector, forKey: "inputCenter")
                    filter.setValue(node.inputs[3].float, forKey: "inputAngle")
                    let outputImage = filter.outputImage
                    if let outputImage, !outputImage.extent.isEmpty {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            }
        }

        public struct OpTileNode: NodeImplProvider {
            public static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Op Tile",
                    inputs: [
                        .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                        .init(
                            name: "Center",
                            defaultValue: .vector2(.init(x: 150.0, y: 150.0)),
                            semantics: .position2,
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Scale",
                            defaultValue: .float(2.8),
                            semantics: .float(.range(0.1...10.0)),
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Angle",
                            defaultValue: .float(0.0),
                            semantics: .float(.angle(-3.141592653589793...3.141592653589793)),
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Width",
                            defaultValue: .float(65.0),
                            semantics: .distance,
                            editorPlacement: .default
                        ),
                    ],
                    outputs: [
                        .init(name: "Output Image", type: .image)
                    ]
                )

                return .init(schema: schema) { node, context in
                    let filter = CIFilter(name: "CIOpTile")!
                    guard let inputImage = await context.getImage(node.inputs[0].image) else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                        return
                    }
                    filter.setValue(inputImage, forKey: "inputImage")
                    filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                    filter.setValue(node.inputs[2].float.clamped(to: 0.1...), forKey: "inputScale")
                    filter.setValue(node.inputs[3].float, forKey: "inputAngle")
                    filter.setValue(node.inputs[4].float, forKey: "inputWidth")
                    let outputImage = filter.outputImage
                    if let outputImage, !outputImage.extent.isEmpty {
                        let roi = outputImage.regionOfInterest(for: inputImage, in: outputImage.extent)
                        node.outputs[0] = .image(await context.addImage(outputImage.cropped(to: roi), 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            }
        }

        public struct ParallelogramTileNode: NodeImplProvider {
            public static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Parallelogram Tile",
                    inputs: [
                        .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                        .init(
                            name: "Center",
                            defaultValue: .vector2(.init(x: 150.0, y: 150.0)),
                            semantics: .position2,
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Angle",
                            defaultValue: .float(0.0),
                            semantics: .float(.angle(-3.141592653589793...3.141592653589793)),
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Acute Angle",
                            defaultValue: .float(1.5707963267948966),
                            semantics: .float(.angle(-3.141592653589793...3.141592653589793)),
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Width",
                            defaultValue: .float(100.0),
                            semantics: .distance,
                            editorPlacement: .default
                        ),
                        .init(name: "Rectangle", defaultValue: .rect(.init(x: 0, y: 0, width: 150, height: 150))),
                    ],
                    outputs: [
                        .init(name: "Output Image", type: .image)
                    ]
                )

                return .init(schema: schema) { node, context in
                    let filter = CIFilter(name: "CIParallelogramTile")!
                    filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                    filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                    filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                    filter.setValue(node.inputs[3].float, forKey: "inputAcuteAngle")
                    filter.setValue(node.inputs[4].float, forKey: "inputWidth")
                    let outputImage = filter.outputImage?.cropped(to: node.inputs[5].rect)
                    if let outputImage, !outputImage.extent.isEmpty {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            }
        }

        public struct SixfoldReflectedTileNode: NodeImplProvider {
            public static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Sixfold Reflected Tile",
                    inputs: [
                        .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                        .init(
                            name: "Center",
                            defaultValue: .vector2(.init(x: 150.0, y: 150.0)),
                            semantics: .position2,
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Angle",
                            defaultValue: .float(0.0),
                            semantics: .float(.angle(-3.141592653589793...3.141592653589793)),
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Width",
                            defaultValue: .float(100.0),
                            semantics: .distance,
                            editorPlacement: .default
                        ),
                        .init(name: "Rectangle", defaultValue: .rect(.init(x: 0, y: 0, width: 150, height: 150))),
                    ],
                    outputs: [
                        .init(name: "Output Image", type: .image)
                    ]
                )

                return .init(schema: schema) { node, context in
                    let filter = CIFilter(name: "CISixfoldReflectedTile")!
                    filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                    filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                    filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                    filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                    let outputImage = filter.outputImage?.cropped(to: node.inputs[4].rect)
                    if let outputImage, !outputImage.extent.isEmpty {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            }
        }

        public struct SixfoldRotatedTileNode: NodeImplProvider {
            public static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Sixfold Rotated Tile",
                    inputs: [
                        .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                        .init(
                            name: "Center",
                            defaultValue: .vector2(.init(x: 150.0, y: 150.0)),
                            semantics: .position2,
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Angle",
                            defaultValue: .float(0.0),
                            semantics: .float(.angle(-3.141592653589793...3.141592653589793)),
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Width",
                            defaultValue: .float(100.0),
                            semantics: .distance,
                            editorPlacement: .default
                        ),
                        .init(name: "Rectangle", defaultValue: .rect(.init(x: 0, y: 0, width: 150, height: 150))),
                    ],
                    outputs: [
                        .init(name: "Output Image", type: .image)
                    ]
                )

                return .init(schema: schema) { node, context in
                    let filter = CIFilter(name: "CISixfoldRotatedTile")!
                    filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                    filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                    filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                    filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                    let outputImage = filter.outputImage?.cropped(to: node.inputs[4].rect)
                    if let outputImage, !outputImage.extent.isEmpty {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            }
        }

        public struct TriangleTileNode: NodeImplProvider {
            public static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Triangle Tile",
                    inputs: [
                        .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                        .init(
                            name: "Center",
                            defaultValue: .vector2(.init(x: 150.0, y: 150.0)),
                            semantics: .position2,
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Angle",
                            defaultValue: .float(0.0),
                            semantics: .float(.angle(-3.141592653589793...3.141592653589793)),
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Width",
                            defaultValue: .float(100.0),
                            semantics: .distance,
                            editorPlacement: .default
                        ),
                        .init(name: "Rectangle", defaultValue: .rect(.init(x: 0, y: 0, width: 150, height: 150))),
                    ],
                    outputs: [
                        .init(name: "Output Image", type: .image)

                    ]
                )

                return .init(schema: schema) { node, context in
                    let filter = CIFilter(name: "CITriangleTile")!
                    guard let inputImage = await context.getImage(node.inputs[0].image) else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                        return
                    }
                    filter.setValue(inputImage, forKey: "inputImage")
                    filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                    filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                    filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                    let outputImage = filter.outputImage?.cropped(to: node.inputs[4].rect)
                    if let outputImage, !outputImage.extent.isEmpty {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            }
        }

        public struct TwelvefoldReflectedTileNode: NodeImplProvider {
            public static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Twelvefold Reflected Tile",
                    inputs: [
                        .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default),
                        .init(
                            name: "Center",
                            defaultValue: .vector2(.init(x: 150.0, y: 150.0)),
                            semantics: .position2,
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Angle",
                            defaultValue: .float(0.0),
                            semantics: .float(.angle(-3.141592653589793...3.141592653589793)),
                            editorPlacement: .default
                        ),
                        .init(
                            name: "Width",
                            defaultValue: .float(100.0),
                            semantics: .distance,
                            editorPlacement: .default
                        ),
                        .init(name: "Rectangle", defaultValue: .rect(.init(x: 0, y: 0, width: 150, height: 150))),
                    ],
                    outputs: [
                        .init(name: "Output Image", type: .image)
                    ]
                )

                return .init(schema: schema) { node, context in
                    let filter = CIFilter(name: "CITwelvefoldReflectedTile")!
                    filter.setValue(await context.getImage(node.inputs[0].image), forKey: "inputImage")
                    filter.setValue(node.inputs[1].vector2.ciVector, forKey: "inputCenter")
                    filter.setValue(node.inputs[2].float, forKey: "inputAngle")
                    filter.setValue(node.inputs[3].float, forKey: "inputWidth")
                    let outputImage = filter.outputImage?.cropped(to: node.inputs[4].rect)
                    if let outputImage, !outputImage.extent.isEmpty {
                        node.outputs[0] = .image(await context.addImage(outputImage, 0))
                    } else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                    }
                }
            }
        }
    }
}
