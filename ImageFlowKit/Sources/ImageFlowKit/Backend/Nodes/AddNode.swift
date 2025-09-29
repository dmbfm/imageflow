import Foundation

extension Backend.Nodes {
    public struct AddNode: Backend.NodeImplProvider {
        static func impl(_ type: NumericValueType) -> Backend.NodeImpl {
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

            return .init(
                schema: schema,
            ) { node, context in
                node.outputs[0] = node.inputs[0] + node.inputs[1]
            }
        }
    }
}
