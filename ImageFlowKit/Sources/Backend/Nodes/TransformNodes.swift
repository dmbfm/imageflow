import CoreGraphics
import Foundation
import Values

extension Nodes {
    struct TransformNodes {
        struct TransformRotate: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Rotate Transform",
                    inputs: [
                        .init(name: "Angle", type: .float, semantics: .float(.angle(nil)))
                    ],
                    outputs: [
                        .init(name: "Transform", type: .affineTransform)
                    ],
                )

                return .init(
                    schema: schema,
                    runImpl: { node, _ in
                        let t = CGAffineTransform(rotationAngle: node.inputs[0].float)
                        node.outputs[0] = .affineTransform(.init(cgAffineTransform: t))
                    }
                )
            }
        }

        struct TransformScale: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Scale Transform",
                    inputs: [
                        .init(name: "Scale", defaultValue: .vector2(.init(x: 1.0, y: 1.0)))
                    ],
                    outputs: [
                        .init(name: "Transform", type: .affineTransform)
                    ],
                )

                return .init(
                    schema: schema,
                    runImpl: { node, _ in
                        let s = node.inputs[0].vector2
                        let t = CGAffineTransform(scaleX: s.x, y: s.y)
                        node.outputs[0] = .affineTransform(.init(cgAffineTransform: t))
                    }
                )
            }
        }

        struct TransformScaleUniform: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Uniform Scale Transform",
                    inputs: [
                        .init(name: "Scale", defaultValue: .float(1.0))
                    ],
                    outputs: [
                        .init(name: "Transform", type: .affineTransform)
                    ],
                )

                return .init(
                    schema: schema,
                    runImpl: { node, _ in
                        let s = node.inputs[0].float
                        let t = CGAffineTransform(scaleX: s, y: s)
                        node.outputs[0] = .affineTransform(.init(cgAffineTransform: t))
                    }
                )
            }
        }

        struct TransformTranslate: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "Translate Transform",
                    inputs: [
                        .init(name: "Translation", type: .vector2)
                    ],
                    outputs: [
                        .init(name: "Transform", type: .affineTransform)
                    ],
                )

                return .init(
                    schema: schema,
                    runImpl: { node, _ in
                        let s = node.inputs[0].vector2
                        let t = CGAffineTransform(translationX: s.x, y: s.y)
                        node.outputs[0] = .affineTransform(.init(cgAffineTransform: t))
                    }
                )
            }
        }

        struct TransformSRT: NodeImplProvider {
            static func impl(_ param: ()) -> NodeImpl {
                let schema = NodeSchema(
                    name: "SRT Transform",
                    inputs: [
                        .init(name: "Scale", defaultValue: .vector2(.init(x: 1.0, y: 1.0))),
                        .init(name: "Angle", type: .float, semantics: .float(.angle(nil))),
                        .init(name: "Translation", type: .vector2),
                    ],
                    outputs: [
                        .init(name: "Transform", type: .affineTransform)
                    ],
                )

                return .init(
                    schema: schema,
                    runImpl: { node, _ in
                        let scale = node.inputs[0].vector2
                        let angle = node.inputs[1].float
                        let tr = node.inputs[2].vector2
                        let s = CGAffineTransform(scaleX: scale.x, y: scale.y)
                        let r = CGAffineTransform(rotationAngle: angle)
                        let t = CGAffineTransform(translationX: tr.x, y: tr.y)
                        let final = CGAffineTransformConcat(CGAffineTransformConcat(s, r), t)
                        node.outputs[0] = .affineTransform(.init(cgAffineTransform: final))
                    }
                )
            }
        }
    }
}
