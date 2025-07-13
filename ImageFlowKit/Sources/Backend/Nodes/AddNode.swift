import Foundation
import Values

extension Nodes {
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
            ) { node, context in
                node.outputs[0] = node.inputs[0] + node.inputs[1]
            }
        }
    }
}
