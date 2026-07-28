import Values

extension Nodes {
    struct SplitValueNodes {
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
                    name: "Split Color RBG",
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
    }
}
