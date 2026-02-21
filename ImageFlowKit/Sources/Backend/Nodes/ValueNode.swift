import Foundation
import Values

extension Nodes {
    public struct ValueNode: NodeImplProvider {
        static func impl(_ type: ValueType) -> NodeImpl {
            switch type {
            case .vector2:
                vector2Impl(type)
            default:
                defaultImpl(type)
            }
        }

        static func defaultImpl(_ type: ValueType) -> NodeImpl {
            let schema = NodeSchema(
                name: "Value \(type)",
                inputs: [.init(name: "Value", type: type)],
                outputs: [.init(name: "Output", type: type)]
            )

            return .init(schema: schema) { node, context in
                if type == .image {
                    let image = await context.getImage(node.inputs[0].image)
                    node.outputs[0] = .image(await context.addImage(image, 0))
                } else {
                    node.outputs[0] = node.inputs[0]
                }
            }
        }

        static func vector2Impl(_ type: ValueType) -> NodeImpl {
            assert(type == .vector2)

            let schema = NodeSchema(
                name: "Value \(type)",
                inputs: [
                    .init(name: "x", type: .float),
                    .init(name: "y", type: .float),
                ],
                outputs: [.init(name: "Output", type: type)]
            )

            return .init(schema: schema) { node, context in
                node.outputs[0] = .vector2(.init(x: node.inputs[0].float, y: node.inputs[1].float))
            }
        }
    }
}
