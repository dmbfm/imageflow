import Foundation
import Values

extension Nodes {
    public struct AffineTransformValueNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Affine Transform",
                displayName: "Affine Transform",
                inputs: [
                    .init(name: "Matrix Row 1", defaultValue: .vector2(.init(x: 1, y: 0))),
                    .init(name: "Matrix Row 2", defaultValue: .vector2(.init(x: 0, y: 1))),
                    .init(name: "Translation", defaultValue: .vector2(.init(x: 0, y: 0))),
                ],
                outputs: [.init(name: "Affine Transform", type: .affineTransform)]
            )

            return NodeImpl(
                schema: schema,
                runImpl: { node, context in
                    let r1 = node.inputs[0].vector2
                    let r2 = node.inputs[1].vector2
                    let t = node.inputs[2].vector2
                    node.outputs[0] = .affineTransform(
                        .init(m11: r1.x, m12: r1.y, m21: r2.x, m22: r2.y, tX: t.x, tY: t.y)
                    )
                }
            )
        }
    }
}
