import Foundation

extension Backend.Nodes {
    public struct PassthroughNode: Backend.NodeImplProvider {
        static func impl(_ type: ValueType) -> Backend.NodeImpl {
            let schema = NodeSchema(
                name: "Passthrough (\(type))",
                inputs: [.init(name: "Input", type: type)],
                outputs: [.init(name: "Output", type: type)]
            )

            return .init(schema: schema) { node, context in
                node.outputs[0] = node.inputs[0]
            }
        }
    }
}
