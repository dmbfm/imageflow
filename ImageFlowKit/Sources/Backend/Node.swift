import Foundation
import Values

public struct Node: Sendable {
    public var id: UUID
    public var kind: NodeKind
    public var inputs: [Value]
    public var outputs: [Value]

    public init(id: UUID, kind: NodeKind, inputs: [Value], outputs: [Value]) {
        self.id = id
        self.kind = kind
        self.inputs = inputs
        self.outputs = outputs

        assert(self.validateSchema())
    }

    public init(id: UUID = UUID(), kind: NodeKind) {
        self.id = id
        self.kind = kind
        self.inputs = kind.schema.inputs.map { $0.defaultValue ?? $0.type.defaultValue }
        self.outputs = kind.schema.outputs.map { $0.type.defaultValue }

        assert(self.validateSchema())
    }

    func validateSchema() -> Bool {
        self.kind.schema.validate(node: self) == .ok
    }
}
