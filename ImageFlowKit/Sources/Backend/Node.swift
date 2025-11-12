import Foundation
import Values

public struct Node: Sendable {
    public var id: UUID
    public var kind: NodeKind
    public var inputs: [Value]
    public var inputOptions: [[Value]]
    public var outputs: [Value]
    public var options: [Value]

    public init(
        id: UUID,
        kind: NodeKind,
        inputs: [Value],
        outputs: [Value],
        inputOptions: [[Value]] = [[]],
        options: [Value] = []
    ) {
        self.id = id
        self.kind = kind
        self.inputs = inputs
        self.outputs = outputs
        self.options = options
        self.inputOptions = inputOptions

        assert(self.validateSchema())
    }

    public init(id: UUID = UUID(), kind: NodeKind) {
        self.id = id
        self.kind = kind
        self.inputs = kind.schema.inputs.map { $0.defaultValue ?? $0.type.defaultValue }
        self.outputs = kind.schema.outputs.map { $0.type.defaultValue }
        self.options = kind.schema.options.map { $0.defaultValue }
        self.inputOptions = kind.schema.inputs.map {
            $0.options.map { $0.defaultValue }
        }
        assert(self.validateSchema())
    }

    func validateSchema() -> Bool {
        self.kind.schema.validate(node: self) == .ok
    }
}
