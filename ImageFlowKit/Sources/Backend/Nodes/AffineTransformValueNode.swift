import Foundation
import Values

extension Nodes {
    public struct AffineTransformValueNode: NodeImplProvider {
        static func impl(_ param: ()) -> NodeImpl {
            let schema = NodeSchema(
                name: "Affine Transform",
                displayName: "Affine Transform",
                inputs: [
                    .init(name: "Matrix", defaultValue: .matrix2x2(.identity)),
                    .init(name: "Translation", defaultValue: .vector2(.init(x: 0, y: 0))),
                ],
                outputs: [.init(name: "Affine Transform", type: .affineTransform)]
            )

            return NodeImpl(
                schema: schema,
                runImpl: { node, _ in
                    let m = node.inputs[0].matrix2x2
                    let t = node.inputs[1].vector2
                    node.outputs[0] = .affineTransform(
                        .init(
                            m11: m[0, 0],
                            m12: m[0, 0],
                            m21: m[1, 0],
                            m22: m[1, 1],
                            tX: t.x,
                            tY: t.y
                        )
                    )
                }
            )
        }
    }
}
