import Backend
import Foundation
import Values

extension FlowNode: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let repr = try container.decode(FlowNodeCodableRepresentation.self)
        switch repr {
        case .v0(let node):
            self.id = node.id
            self.name = node.name
            self.kind = node.kind
            self.inputs = node.inputs.map({
                .init(label: $0.label, index: $0.index, value: $0.value, connected: $0.connected)
            })
            self.outputs = node.outputs.map({
                .init(label: $0.label, index: $0.index, type: $0.type, connected: $0.connected)
            })
        }
    }

    public func encode(to encoder: any Encoder) throws {
        let repr = FlowNodeCodableRepresentation.v0(
            .init(
                id: self.id,
                name: self.name,
                kind: self.kind,
                inputs: self.inputs.map({
                    .init(label: $0.label, index: $0.index, value: $0.value, connected: $0.connected)
                }),
                outputs: self.outputs.map({
                    .init(label: $0.label, index: $0.index, type: $0.type, connected: $0.connected)
                })
            )
        )
        var container = encoder.singleValueContainer()
        try container.encode(repr)
    }

}

public enum FlowNodeCodableRepresentation: Sendable, Codable {

    case v0(V0)

    public struct V0: Sendable, Equatable, Codable {
        public var id: UUID
        /// The node's name
        public var name: String
        /// The kind of the node
        public var kind: NodeKind
        /// The node's inputs
        public var inputs: [Input]
        /// The node's outputs
        public var outputs: [Output]

        public struct Input: Hashable, Sendable, Codable {
            public var label: String
            public var index: Int
            public var value: Value
            public var connected: Bool
        }

        public struct Output: Hashable, Sendable, Codable {
            public var label: String
            public var index: Int
            public var type: ValueType
            public var connected: Bool
        }
    }
}
