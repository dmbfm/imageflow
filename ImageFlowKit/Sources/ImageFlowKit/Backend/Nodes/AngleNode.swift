import Foundation

extension Nodes {
    public struct AngleNode: NodeImplProvider {
        static func impl(_: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Angle",
                inputs: [.init(name: "Value", type: .float, semantics: .angle)],
                outputs: [.init(name: "Output", type: .float)]
            )

            return .init(schema: schema) { node, context in
                node.outputs[0] = node.inputs[0]
            }
        }
    }
}
