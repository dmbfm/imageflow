import Values

extension Nodes {
    struct CombineValueNodes {
        struct CombineAffineTransformNode: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Combine Transform",
                    inputs: [
                        .init(name: "Matrix", defaultValue: .matrix2x2(.identity)),
                        .init(name: "Translation", defaultValue: .vector2(.zero)),
                    ],
                    outputs: [
                        .init(name: "Transform", type: .affineTransform)
                    ],
                )

                return .init(
                    schema: schema,
                    runImpl: { node, context in

                        let m = node.inputs[0].matrix2x2
                        let t = node.inputs[1].vector2

                        node.outputs[0] = .affineTransform(
                            .init(
                                m11: m[0, 0],
                                m12: m[0, 1],
                                m21: m[1, 0],
                                m22: m[1, 1],
                                tX: t.x,
                                tY: t.y
                            )
                        )
                    }
                )
            }
        }

        struct CombineVector2Node: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Combine Vector 2",
                    inputs: [
                        .init(name: "x", type: .float),
                        .init(name: "y", type: .float),
                    ],
                    outputs: [
                        .init(name: "Vector", type: .vector2)
                    ],
                )

                return .init(
                    schema: schema,
                    runImpl: { node, _ in
                        node.outputs[0] = .vector2(.init(x: node.inputs[0].float, y: node.inputs[1].float))
                    }
                )
            }
        }

        struct CombineVector3Node: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Combine Vector 3",
                    inputs: [
                        .init(name: "x", type: .float),
                        .init(name: "y", type: .float),
                        .init(name: "z", type: .float),
                    ],
                    outputs: [
                        .init(name: "Vector", type: .vector3)
                    ],
                )

                return .init(
                    schema: schema,
                    runImpl: { node, _ in
                        node.outputs[0] = .vector3(
                            .init(x: node.inputs[0].float, y: node.inputs[1].float, z: node.inputs[2].float)
                        )
                    }
                )
            }
        }

        struct CombineVector4Node: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Combine Vector 4",
                    inputs: [
                        .init(name: "x", type: .float),
                        .init(name: "y", type: .float),
                        .init(name: "z", type: .float),
                        .init(name: "w", type: .float),
                    ],
                    outputs: [
                        .init(name: "Vector", type: .vector4)
                    ],
                )

                return .init(
                    schema: schema,
                    runImpl: { node, _ in
                        node.outputs[0] = .vector4(
                            .init(
                                x: node.inputs[0].float,
                                y: node.inputs[1].float,
                                z: node.inputs[2].float,
                                w: node.inputs[3].float
                            )
                        )
                    }
                )
            }
        }

        struct CombineColor4Node: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Combine Color RGBA",
                    inputs: [
                        .init(name: "r", type: .float),
                        .init(name: "g", type: .float),
                        .init(name: "b", type: .float),
                        .init(name: "a", defaultValue: .float(1.0)),
                    ],
                    outputs: [
                        .init(name: "Color", type: .color4)
                    ],
                )

                return .init(
                    schema: schema,
                    runImpl: { node, _ in
                        node.outputs[0] = .color4(
                            .init(
                                red: node.inputs[0].float,
                                green: node.inputs[1].float,
                                blue: node.inputs[2].float,
                                alpha: node.inputs[3].float
                            )
                        )
                    }
                )
            }
        }

        struct CombineRectNode: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Combine Rectangle",
                    inputs: [
                        .init(name: "X", type: .float),
                        .init(name: "Y", type: .float),
                        .init(name: "Width", type: .float),
                        .init(name: "Height", type: .float),
                    ],
                    outputs: [
                        .init(name: "Rectangle", type: .rect)
                    ],
                )

                return .init(
                    schema: schema,
                    runImpl: { node, _ in
                        node.outputs[0] = .rect(
                            .init(
                                x: node.inputs[0].float,
                                y: node.inputs[1].float,
                                width: node.inputs[2].float,
                                height: node.inputs[3].float
                            )
                        )
                    }
                )
            }
        }
    }
}
