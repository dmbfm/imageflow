import Foundation
import Values

extension Nodes {
    public struct ValueNode: NodeImplProvider {
        static func impl(_ type: ValueType) -> NodeImpl {
            switch type {
            case .vector2:
                vector2Impl(type)
            case .vector3:
                vector3Impl(type)
            case .vector4:
                vector4Impl(type)
            case .rect:
                rectImpl(type)
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

            return .init(schema: schema) { node, _ in
                node.outputs[0] = .vector2(.init(x: node.inputs[0].float, y: node.inputs[1].float))
            }
        }

        static func vector3Impl(_ type: ValueType) -> NodeImpl {
            assert(type == .vector3)

            let schema = NodeSchema(
                name: "Value \(type)",
                inputs: [
                    .init(name: "x", type: .float),
                    .init(name: "y", type: .float),
                    .init(name: "z", type: .float),
                ],
                outputs: [.init(name: "Output", type: type)]
            )

            return .init(schema: schema) { node, _  in
                node.outputs[0] = .vector3(
                    .init(x: node.inputs[0].float, y: node.inputs[1].float, z: node.inputs[2].float)
                )
            }
        }

        static func vector4Impl(_ type: ValueType) -> NodeImpl {
            assert(type == .vector4)

            let schema = NodeSchema(
                name: "Value \(type)",
                inputs: [
                    .init(name: "x", type: .float),
                    .init(name: "y", type: .float),
                    .init(name: "z", type: .float),
                    .init(name: "w", type: .float),
                ],
                outputs: [.init(name: "Output", type: type)]
            )

            return .init(schema: schema) { node, _ in
                node.outputs[0] = .vector4(
                    .init(
                        x: node.inputs[0].float,
                        y: node.inputs[1].float,
                        z: node.inputs[2].float,
                        w: node.inputs[3].float
                    )
                )
            }
        }

        static func rectImpl(_ type: ValueType) -> NodeImpl {
            assert(type == .rect)

            let schema = NodeSchema(
                name: "Value \(type)",
                inputs: [
                    .init(name: "x", type: .float),
                    .init(name: "y", type: .float),
                    .init(name: "width", type: .float),
                    .init(name: "height", type: .float),
                ],
                outputs: [.init(name: "Output", type: type)]
            )

            return .init(schema: schema) { node, _ in
                node.outputs[0] = .rect(
                    .init(
                        x: node.inputs[0].float,
                        y: node.inputs[1].float,
                        width: node.inputs[2].float,
                        height: node.inputs[3].float
                    )
                )
            }
        }
    }

    struct Color4RGBAValue: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Color RGBA",
                inputs: [
                    .init(name: "Red", type: .float),
                    .init(name: "Green", type: .float),
                    .init(name: "Blue", type: .float),
                    .init(name: "Alpha", defaultValue: .float(1.0)),
                ],
                outputs: [.init(name: "Output", type: .color4)]
            )

            return .init(schema: schema) { node, _ in
                node.outputs[0] = .color4(
                    .init(
                        red: node.inputs[0].float,
                        green: node.inputs[2].float,
                        blue: node.inputs[1].float,
                        alpha: node.inputs[3].float
                    )
                )
            }
        }
    }
}
