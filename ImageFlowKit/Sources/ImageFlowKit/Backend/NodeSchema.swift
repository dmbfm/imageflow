import Foundation

/// A schema for a node.
///
/// A `NodeSchema` describes the inputs and outputs of a node. It is used to
/// validate the inputs and outputs of a node when creating it from a
/// `NodeDescriptor`, or when trying to connect nodes, set values to properties, etc.
///
/// A `NodeSchema` is not tied to a particular `NodeKind`. Instead, each `NodeKind` has
/// a `NodeSchema` that describes its nodes.
public struct NodeSchema: Sendable {
    /// The name of the node.
    public var name: String
    /// The display name of the node.
    public var displayName: String
    /// The input properties of the node.
    public var inputs: [InputPropertySchema]
    /// The output properties of the node.
    public var outputs: [OutputPropertySchema]

    /// Creates a new `NodeSchema`.
    public init(
        name: String,
        displayName: String? = nil,
        inputs: [InputPropertySchema],
        outputs: [OutputPropertySchema]
    ) {
        self.name = name
        self.displayName = displayName ?? name
        self.inputs = inputs
        self.outputs = outputs
    }
}

extension NodeSchema {
    /// Checks wether a given node is compatible with the `NodeSchema`.
    ///
    /// - Parameter node: The backend node instance being validated.
    /// - Returns: The result of the validation. If it is `ValidateNodeResult.ok`
    ///            then the node is valid.
    public func validate(node: BackendNode) -> ValidateNodeResult {
        if node.inputs.count != self.inputs.count {
            return .inputCountMismatch
        }

        if node.outputs.count != self.outputs.count {
            return .outputCountMismatch
        }

        for (idx, (a, b)) in zip(node.inputs, self.inputs).enumerated() {
            if !a.is(b.type) {
                return .inputTypeMismatch(idx)
            }
        }

        for (idx, (a, b)) in zip(node.outputs, self.outputs).enumerated() {
            if !a.is(b.type) {
                return .outputTypeMismatch(idx)
            }
        }

        return .ok
    }

    public enum ValidateNodeResult: Equatable {
        case ok
        case inputCountMismatch
        case outputCountMismatch
        case inputTypeMismatch(Int)
        case outputTypeMismatch(Int)
    }
}

/// A schema for a node's input property.
public struct InputPropertySchema: Sendable, Hashable {
    /// The name of the property.
    public var name: String
    /// The type of the property.
    public var type: ValueType
    /// The default value of the property, if any.
    public var defaultValue: Value?
    /// An optional range for numerical values.
    public var range: ClosedRange<Double>?
    /// The `ValueSemantics` associated with this input.
    public var semantics: ValueSemantics

    /// Creates a new `InputPropertySchema` with the given name and type, without a default value.
    public init(name: String, type: ValueType, semantics: ValueSemantics = .default) {
        self.name = name
        self.type = type
        self.defaultValue = nil
        self.semantics = semantics
    }

    /// Creates a new `InputPropertySchema` with the given name, and default value.
    public init(name: String, defaultValue: Value, semantics: ValueSemantics = .default) {
        self.name = name
        self.type = defaultValue.type
        self.defaultValue = defaultValue
        self.semantics = semantics
    }
}

/// A schema for a node's output property. Different from `InputPropertySchema`
/// in that it doesn't have a default value, only a name and a type.
public struct OutputPropertySchema: Sendable, Hashable {
    /// The name of the property.
    public var name: String
    /// The type of the property.
    public var type: ValueType

    /// Creates a new `OutputPropertySchema` with the given name and type.
    public init(name: String, type: ValueType) {
        self.name = name
        self.type = type
    }
}
