import Foundation
import Values

extension Nodes {
    public struct MathFunctions {
        public static func floatFunc1NodeImpl(
            _ name: String,
            arg: String = "Value",
            defaultValue: Double = 0.0,
            f: @escaping (Double) -> Double
        ) -> NodeImpl {
            let schema = NodeSchema(
                name: name,
                inputs: [
                    .init(name: arg, defaultValue: .float(defaultValue))
                ],
                outputs: [
                    .init(name: "Result", type: .float)
                ]
            )

            return NodeImpl(
                schema: schema,
            ) { node, _ in
                node.outputs[0].float = f(node.inputs[0].float)
            }
        }

        public static func floatFunc2NodeImpl(
            _ name: String,
            arg1: String = "A",
            defaultValue1: Double = 0.0,
            arg2: String = "B",
            defaultValue2: Double = 0.0,
            f: @escaping (Double, Double) -> Double
        ) -> NodeImpl {
            let schema = NodeSchema(
                name: name,
                inputs: [
                    .init(name: arg1, defaultValue: .float(defaultValue1)),
                    .init(name: arg2, defaultValue: .float(defaultValue2)),
                ],
                outputs: [
                    .init(name: "Result", type: .float)
                ]
            )

            return NodeImpl(
                schema: schema,
            ) { node, _ in
                node.outputs[0].float = f(node.inputs[0].float, node.inputs[1].float)
            }
        }

        public static func floatFunc3NodeImpl(
            _ name: String,
            arg1: String = "A",
            defaultValue1: Double = 0.0,
            arg2: String = "B",
            defaultValue2: Double = 0.0,
            arg3: String = "C",
            defaultValue3: Double = 0.0,
            f: @escaping (Double, Double, Double) -> Double
        ) -> NodeImpl {
            let schema = NodeSchema(
                name: name,
                inputs: [
                    .init(name: arg1, defaultValue: .float(defaultValue1)),
                    .init(name: arg2, defaultValue: .float(defaultValue2)),
                    .init(name: arg3, defaultValue: .float(defaultValue3)),
                ],
                outputs: [
                    .init(name: "Result", type: .float)
                ]
            )

            return NodeImpl(
                schema: schema,
            ) { node, _ in
                node.outputs[0].float = f(node.inputs[0].float, node.inputs[1].float, node.inputs[2].float)
            }
        }
    }

    public struct AddNode: NodeImplProvider {
        static func impl(_ type: NumericValueType) -> NodeImpl {
            let schema = NodeSchema(
                name: "Add (\(type))",
                inputs: [
                    .init(name: "A", type: type.valueType),
                    .init(name: "B", type: type.valueType),
                ],
                outputs: [
                    .init(name: "Result", type: type.valueType)
                ]
            )

            return NodeImpl(
                schema: schema,
            ) { node, _ in
                node.outputs[0] = node.inputs[0] + node.inputs[1]
            }
        }
    }

    public struct SubtractNode: NodeImplProvider {
        static func impl(_ type: NumericValueType) -> NodeImpl {
            let schema = NodeSchema(
                name: "Subtract (\(type))",
                inputs: [
                    .init(name: "A", type: type.valueType),
                    .init(name: "B", type: type.valueType),
                ],
                outputs: [
                    .init(name: "Result", type: type.valueType)
                ]
            )

            return NodeImpl(
                schema: schema,
            ) { node, _ in
                node.outputs[0] = node.inputs[0] - node.inputs[1]
            }
        }
    }

    public struct MulNode: NodeImplProvider {
        static func impl(_ type: NumericValueType) -> NodeImpl {
            let schema = NodeSchema(
                name: "Multiply (\(type))",
                inputs: [
                    .init(name: "A", type: type.valueType),
                    .init(name: "B", type: type.valueType),
                ],
                outputs: [
                    .init(name: "Result", type: type.valueType)
                ]
            )

            return NodeImpl(
                schema: schema,
            ) { node, _ in
                node.outputs[0] = node.inputs[0] * node.inputs[1]
            }
        }
    }

    public struct DivNode: NodeImplProvider {
        static func impl(_ type: NumericDivValueType) -> NodeImpl {
            let schema = NodeSchema(
                name: "Divide (\(type))",
                inputs: [
                    .init(name: "A", type: type.valueType),
                    .init(name: "B", type: type.valueType),
                ],
                outputs: [
                    .init(name: "Result", type: type.valueType)
                ]
            )

            return NodeImpl(
                schema: schema,
            ) { node, _ in
                node.outputs[0] = node.inputs[0] / node.inputs[1]
            }
        }
    }
}
