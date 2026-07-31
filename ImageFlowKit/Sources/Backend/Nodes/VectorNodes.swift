import Foundation
import Values

public enum VectorValueType: Sendable, Hashable, Codable, CaseIterable {
    case vector2
    case vector3
    case vector4

    func dot(_ a: Value, _ b: Value) -> Value {
        switch self {
        case .vector2:
            switch (a, b) {
            case (.vector2(let a), .vector2(let b)): .float(a.dot(b))
            default: .float(0.0)
            }
        case .vector3:
            switch (a, b) {
            case (.vector3(let a), .vector3(let b)): .float(a.dot(b))
            default: .float(0.0)
            }
        case .vector4:
            switch (a, b) {
            case (.vector4(let a), .vector4(let b)): .float(a.dot(b))
            default: .float(0.0)
            }
        }
    }

    func distance(_ a: Value, _ b: Value) -> Value {
        switch self {
        case .vector2:
            switch (a, b) {
            case (.vector2(let a), .vector2(let b)): .float(a.distance(b))
            default: .float(0.0)
            }
        case .vector3:
            switch (a, b) {
            case (.vector3(let a), .vector3(let b)): .float(a.distance(b))
            default: .float(0.0)
            }
        case .vector4:
            switch (a, b) {
            case (.vector4(let a), .vector4(let b)): .float(a.distance(b))
            default: .float(0.0)
            }
        }
    }

    func length(_ v: Value) -> Value {
        switch self {
        case .vector2:
            switch v {
            case .vector2(let v): .float(v.lenght)
            default: .float(0.0)
            }
        case .vector3:
            switch v {
            case .vector3(let v): .float(v.lenght)
            default: .float(0.0)
            }
        case .vector4:
            switch v {
            case .vector4(let v): .float(v.lenght)
            default: .float(0.0)
            }
        }
    }

    func normalize(_ v: Value) -> Value {
        switch self {
        case .vector2:
            switch v {
            case .vector2(let v): .vector2(v.normalized)
            default: .vector2(.zero)
            }
        case .vector3:
            switch v {
            case .vector3(let v): .vector3(v.normalized)
            default: .vector3(.zero)
            }
        case .vector4:
            switch v {
            case .vector4(let v): .vector4(v.normalized)
            default: .vector4(.zero)
            }
        }
    }

    public var valueType: ValueType {
        switch self {
        case .vector2: .vector2
        case .vector3: .vector3
        case .vector4: .vector4
        }
    }
}

extension Nodes {
    public static func vectorDotNodeImpl(_ type: VectorValueType) -> NodeImpl {
        let schema = NodeSchema(
            name: "Dot Product (\(type.valueType))",
            inputs: [
                .init(name: "A", type: type.valueType),
                .init(name: "B", type: type.valueType),
            ],
            outputs: [
                .init(name: "Result", type: .float)
            ]
        )

        return .init(schema: schema) { node, context in
            node.outputs[0] = type.dot(node.inputs[0], node.inputs[1])
        }
    }

    public static func vectorDistanceNodeImpl(_ type: VectorValueType) -> NodeImpl {
        let schema = NodeSchema(
            name: "Point Distance (\(type.valueType))",
            inputs: [
                .init(name: "A", type: type.valueType),
                .init(name: "B", type: type.valueType),
            ],
            outputs: [
                .init(name: "Result", type: .float)
            ]
        )

        return .init(schema: schema) { node, context in
            node.outputs[0] = type.distance(node.inputs[0], node.inputs[1])
        }
    }

    public static var vectorCrossNodeImpl: NodeImpl {
        let schema = NodeSchema(
            name: "Cross Product",
            inputs: [
                .init(name: "A", type: .vector3),
                .init(name: "B", type: .vector3),
            ],
            outputs: [
                .init(name: "Result", type: .vector3)
            ]
        )

        return .init(schema: schema) { node, context in
            node.outputs[0].vector3 = node.inputs[0].vector3.cross(node.inputs[1].vector3)
        }
    }

    public static func vectorLengthNodeImpl(_ type: VectorValueType) -> NodeImpl {
        let schema = NodeSchema(
            name: "Vector Length (\(type.valueType))",
            inputs: [
                .init(name: "Vector", type: type.valueType)
            ],
            outputs: [
                .init(name: "Result", type: .float)
            ]
        )

        return .init(schema: schema) { node, context in
            node.outputs[0] = type.length(node.inputs[0])
        }
    }

    public static func vectorNormalizeNodeImpl(_ type: VectorValueType) -> NodeImpl {
        let schema = NodeSchema(
            name: "Normalize Vector (\(type.valueType))",
            inputs: [
                .init(name: "Vector", type: type.valueType)
            ],
            outputs: [
                .init(name: "Result", type: type.valueType)
            ]
        )

        return .init(schema: schema) { node, context in
            node.outputs[0] = type.normalize(node.inputs[0])
        }
    }
}
