import CoreImage
import CoreImage.CIFilterBuiltins
import Values

extension Nodes {
    struct SplitValueNodes {

        struct ImageChannelsNode: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Channel Masks",
                    inputs: [
                        .init(name: "Image", type: .image, semantics: .image, editorPlacement: .default)
                    ],
                    outputs: [
                        .init(name: "Red Mask", type: .image),
                        .init(name: "Green Mask", type: .image),
                        .init(name: "Blue Mask", type: .image),
                        .init(name: "Alpha Mask", type: .image),
                    ]
                )

                return .init(schema: schema) { node, context in
                    guard let inputImage = await context.getImage(node.inputs[0].image) else {
                        node.outputs[0] = .image(await context.addImage(nil, 0))
                        return
                    }

                    let rfilter = CIFilter.colorMatrix()
                    rfilter.inputImage = inputImage
                    rfilter.rVector = .init(x: 1.0, y: 0.0, z: 0.0, w: 0.0)
                    rfilter.gVector = .init(x: 1.0, y: 0.0, z: 0.0, w: 0.0)
                    rfilter.bVector = .init(x: 1.0, y: 0.0, z: 0.0, w: 0.0)
                    rfilter.aVector = .init(x: 1.0, y: 0.0, z: 0.0, w: 0.0)
                    node.outputs[0] = .image(await context.addImage(rfilter.outputImage!, 0))

                    let gfilter = CIFilter.colorMatrix()
                    gfilter.inputImage = inputImage
                    gfilter.rVector = .init(x: 0.0, y: 1.0, z: 0.0, w: 0.0)
                    gfilter.gVector = .init(x: 0.0, y: 1.0, z: 0.0, w: 0.0)
                    gfilter.bVector = .init(x: 0.0, y: 1.0, z: 0.0, w: 0.0)
                    gfilter.aVector = .init(x: 0.0, y: 1.0, z: 0.0, w: 0.0)
                    node.outputs[1] = .image(await context.addImage(gfilter.outputImage!, 1))

                    let bfilter = CIFilter.colorMatrix()
                    bfilter.inputImage = inputImage
                    bfilter.rVector = .init(x: 0.0, y: 0.0, z: 1.0, w: 0.0)
                    bfilter.gVector = .init(x: 0.0, y: 0.0, z: 1.0, w: 0.0)
                    bfilter.bVector = .init(x: 0.0, y: 0.0, z: 1.0, w: 0.0)
                    bfilter.aVector = .init(x: 0.0, y: 0.0, z: 1.0, w: 0.0)
                    node.outputs[2] = .image(await context.addImage(bfilter.outputImage!, 2))

                    let afilter = CIFilter.colorMatrix()
                    afilter.inputImage = inputImage
                    afilter.rVector = .init(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
                    afilter.gVector = .init(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
                    afilter.bVector = .init(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
                    afilter.aVector = .init(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
                    node.outputs[3] = .image(await context.addImage(afilter.outputImage!, 3))
                }
            }
        }

        struct SlipVector2Node: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Split Vector2",
                    inputs: [
                        .init(
                            name: "Value",
                            defaultValue: .vector2(.init(x: 0, y: 0)),
                            editorPlacement: .init(nodeView: .hiddenControl, inspector: .inputs)
                        )
                    ],
                    outputs: [
                        .init(name: "x", type: .float),
                        .init(name: "y", type: .float),
                    ]
                )

                return .init(
                    schema: schema,
                    runImpl: { node, _ in
                        let value = node.inputs[0].vector2
                        node.outputs[0].float = value.x
                        node.outputs[1].float = value.y
                    }
                )
            }
        }

        struct SlipVector3Node: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Split Vector3",
                    inputs: [
                        .init(
                            name: "Value",
                            defaultValue: .vector3(.init(x: 0, y: 0, z: 0)),
                            editorPlacement: .init(nodeView: .hiddenControl, inspector: .inputs)
                        )
                    ],
                    outputs: [
                        .init(name: "x", type: .float),
                        .init(name: "y", type: .float),
                        .init(name: "z", type: .float),
                    ]
                )

                return .init(
                    schema: schema,
                    runImpl: { node, _ in
                        let value = node.inputs[0].vector3
                        node.outputs[0].float = value.x
                        node.outputs[1].float = value.y
                        node.outputs[2].float = value.z
                    }
                )
            }
        }

        struct SlipVector4Node: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Split Vector4",
                    inputs: [
                        .init(
                            name: "Value",
                            defaultValue: .vector4(.init(x: 0, y: 0, z: 0, w: 0)),
                            editorPlacement: .init(nodeView: .hiddenControl, inspector: .inputs)
                        )
                    ],
                    outputs: [
                        .init(name: "x", type: .float),
                        .init(name: "y", type: .float),
                        .init(name: "z", type: .float),
                        .init(name: "w", type: .float),
                    ]
                )

                return .init(
                    schema: schema,
                    runImpl: { node, _ in
                        let value = node.inputs[0].vector4
                        node.outputs[0].float = value.x
                        node.outputs[1].float = value.y
                        node.outputs[2].float = value.z
                        node.outputs[3].float = value.w
                    }
                )
            }
        }

        struct SlipRectNode: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Split Rectangle",
                    inputs: [
                        .init(
                            name: "Value",
                            type: .rect,
                            editorPlacement: .init(nodeView: .hiddenControl, inspector: .inputs)
                        )
                    ],
                    outputs: [
                        .init(name: "x", type: .float),
                        .init(name: "y", type: .float),
                        .init(name: "width", type: .float),
                        .init(name: "height", type: .float),
                    ]
                )

                return .init(
                    schema: schema,
                    runImpl: { node, _ in
                        let value = node.inputs[0].rect
                        node.outputs[0].float = value.minX
                        node.outputs[1].float = value.minY
                        node.outputs[2].float = value.width
                        node.outputs[3].float = value.height
                    }
                )
            }
        }

        struct SlipColorRGBNode: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Split Color RGBA",
                    inputs: [
                        .init(name: "Value", type: .color4)
                    ],
                    outputs: [
                        .init(name: "Red", type: .float),
                        .init(name: "Green", type: .float),
                        .init(name: "Blue", type: .float),
                        .init(name: "Alpha", type: .float),
                    ]
                )

                return .init(
                    schema: schema,
                    runImpl: { node, _ in
                        let value = node.inputs[0].color4
                        node.outputs[0].float = value.red
                        node.outputs[1].float = value.green
                        node.outputs[2].float = value.blue
                        node.outputs[3].float = value.alpha
                    }
                )
            }
        }

        struct ImageInfoNode: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Image Info",
                    inputs: [
                        .init(name: "Value", type: .image)
                    ],
                    outputs: [
                        .init(name: "Extent", type: .rect),
                        .init(name: "Width", type: .float),
                        .init(name: "Height", type: .float),
                    ]
                )

                return .init(
                    schema: schema,
                    runImpl: { node, context in
                        guard let image = await context.getImage(node.inputs[0].image) else {
                            node.outputs[0].rect = .zero
                            return
                        }

                        node.outputs[0].rect = image.extent
                        node.outputs[1].float = image.extent.width
                        node.outputs[2].float = image.extent.height
                    }
                )
            }
        }

        struct ImageRectNode: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Image Rect",
                    inputs: [
                        .init(name: "Value", type: .image)
                    ],
                    outputs: [
                        .init(name: "Rect", type: .rect)
                    ]
                )

                return .init(
                    schema: schema,
                    runImpl: { node, context in
                        guard let image = await context.getImage(node.inputs[0].image) else {
                            node.outputs[0].rect = .zero
                            return
                        }

                        node.outputs[0].rect = image.extent
                    }
                )
            }
        }

        struct ImageOriginNode: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Image Origin",
                    inputs: [
                        .init(name: "Value", type: .image)
                    ],
                    outputs: [
                        .init(name: "Origin", type: .vector2)
                    ]
                )

                return .init(
                    schema: schema,
                    runImpl: { node, context in
                        guard let image = await context.getImage(node.inputs[0].image) else {
                            node.outputs[0].vector2 = .zero
                            return
                        }

                        node.outputs[0].vector2 = .init(x: image.extent.origin.x, y: image.extent.origin.y)
                    }
                )
            }
        }

        struct ImageSizeNode: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Image Size",
                    inputs: [
                        .init(name: "Value", type: .image)
                    ],
                    outputs: [
                        .init(name: "Width", type: .float),
                        .init(name: "Height", type: .float),
                    ]
                )

                return .init(
                    schema: schema,
                    runImpl: { node, context in
                        guard let image = await context.getImage(node.inputs[0].image) else {
                            node.outputs[0].float = 0.0
                            node.outputs[1].float = 0.0
                            return
                        }

                        node.outputs[0].float = image.extent.width
                        node.outputs[1].float = image.extent.height
                    }
                )
            }
        }
    }
}
