import Values

extension Nodes {
    public struct BooleanOperations {
        public struct IfNode: NodeImplProvider {
            public static func impl(_ type: ValueType) -> NodeImpl {
                let schema = NodeSchema(
                    name: "If",
                    inputs: [
                        .init(name: "Condition", defaultValue: .bool(false)),
                        .init(name: "Then", type: type),
                        .init(name: "Else", type: type),
                    ],
                    outputs: [
                        .init(name: "Output", type: type)
                    ]
                )

                return .init(schema: schema) { node, context in
                    let cond = node.inputs[0].bool

                    if cond {
                        node.outputs[0] = node.inputs[1]
                    } else {
                        node.outputs[0] = node.inputs[2]
                    }
                }
            }
        }

        public struct AndNode: NodeImplProvider {
            public static func impl(_ param: (())) -> NodeImpl {
                let schema = NodeSchema(
                    name: "And",
                    inputs: [
                        .init(name: "Condition A", defaultValue: .bool(false)),
                        .init(name: "Condition B", defaultValue: .bool(false)),
                    ],
                    outputs: [
                        .init(name: "Result", type: .bool)
                    ]
                )

                return .init(schema: schema) { node, context in
                    node.outputs[0].bool = node.inputs[0].bool && node.inputs[1].bool
                }
            }
        }

        public struct OrNode: NodeImplProvider {
            public static func impl(_ param: (())) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Or",
                    inputs: [
                        .init(name: "Condition A", defaultValue: .bool(false)),
                        .init(name: "Condition B", defaultValue: .bool(false)),
                    ],
                    outputs: [
                        .init(name: "Result", type: .bool)
                    ]
                )

                return .init(schema: schema) { node, context in
                    node.outputs[0].bool = node.inputs[0].bool || node.inputs[1].bool
                }
            }
        }

        public struct XorNode: NodeImplProvider {
            public static func impl(_ param: (())) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Xor",
                    inputs: [
                        .init(name: "Condition A", defaultValue: .bool(false)),
                        .init(name: "Condition B", defaultValue: .bool(false)),
                    ],
                    outputs: [
                        .init(name: "Result", type: .bool)
                    ]
                )

                return .init(schema: schema) { node, context in
                    node.outputs[0].bool =
                        switch (node.inputs[0].bool, node.inputs[1].bool) {
                        case (true, true): false
                        case (false, false): false
                        case (true, false): true
                        case (false, true): true
                        }
                }
            }
        }

        public struct NotNode: NodeImplProvider {
            public static func impl(_ param: (())) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Not",
                    inputs: [
                        .init(name: "Value", defaultValue: .bool(false))
                    ],
                    outputs: [
                        .init(name: "Result", type: .bool)
                    ]
                )

                return .init(schema: schema) { node, context in
                    node.outputs[0].bool = !node.inputs[0].bool
                }
            }
        }
    }
}
