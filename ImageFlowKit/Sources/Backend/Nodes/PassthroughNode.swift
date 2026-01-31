import Foundation
import Values

extension Nodes {
    public struct PassthroughNode: NodeImplProvider {
        static func impl(_ type: ValueType) -> NodeImpl {
            let schema = NodeSchema(
                name: "Passthrough (\(type))",
                inputs: [.init(name: "Input", type: type)],
                outputs: [.init(name: "Output", type: type)]
            )

            return .init(schema: schema) { node, _ in
                node.outputs[0] = node.inputs[0]
            }
        }
    }
}
