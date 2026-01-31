import Foundation
import Values

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
    /// The options for the node.
    public var options: [NodeOptionSchema]

    /// Creates a new `NodeSchema`.
    public init(
        name: String,
        displayName: String? = nil,
        inputs: [InputPropertySchema],
        outputs: [OutputPropertySchema],
        options: [NodeOptionSchema] = []
    ) {
        self.name = name
        self.displayName = displayName ?? name
        self.inputs = inputs
        self.outputs = outputs
        self.options = options
    }
}

extension NodeSchema {
    /// Checks wether a given node is compatible with the `NodeSchema`.
    ///
    /// - Parameter node: The `Node`.
    /// - Returns: The result of the validation. If it is `ValidateNodeResult.ok`
    ///            then the node is valid.
    public func validate(node: Node) -> ValidateNodeResult {
        if node.inputs.count != self.inputs.count {
            return .inputCountMismatch
        }

        if node.outputs.count != self.outputs.count {
            return .outputCountMismatch
        }

        for (idx, (a, b)) in zip(node.inputs, self.inputs).enumerated() where !a.is(b.type) {
            return .inputTypeMismatch(idx)
        }

        for (idx, (a, b)) in zip(node.outputs, self.outputs).enumerated() where !a.is(b.type) {
            return .outputTypeMismatch(idx)
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
    /// The options for this input.
    public var options: [NodeOptionSchema] = []

    /// Creates a new `InputPropertySchema` with the given name and type, without a default value.
    public init(name: String, type: ValueType, semantics: ValueSemantics = .default, options: [NodeOptionSchema] = []) {
        self.name = name
        self.type = type
        self.defaultValue = nil
        self.semantics = semantics
        self.options = options
    }

    /// Creates a new `InputPropertySchema` with the given name, and default value.
    public init(
        name: String,
        defaultValue: Value,
        semantics: ValueSemantics = .default,
        options: [NodeOptionSchema] = []
    ) {
        self.name = name
        self.type = defaultValue.type
        self.defaultValue = defaultValue
        self.semantics = semantics
        self.options = options
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

/// An `option` is basically just a `Value` with a `name`. In practice, it
/// should be used for additional node values that the user can set but are not
/// (usually) displayed prominently like node controls, but more likely on the
/// inspector panel. Currently ou can have per-node and per-input options.
///
/// Additionally, there is a `pickerOptions` array of strings. This should
/// be used when you want the user to be able to select one case out of several
/// labelled cases (e.g., but displaying a dropdown menu). When using the
/// `pickerOptions` (i.e., when it is not nil) you must use a `.int` value which
/// should be interpreted as the index of the chosen option.
public struct NodeOptionSchema: Sendable, Hashable {
    /// The name of the option.
    public var name: String
    /// The default value of this option. Must have type `Value.int` when `pickerOptions` is not nil.
    public var defaultValue: Value
    /// An optional array of strings denoting option values the user can choose from. When using this the `defaultValue` must be an `Value.int`.
    public var pickerOptions: [String]?

    /// Initializes an option schema with a `name` and `defaultValue`. In this case the `pickerOptions` is `nil`.
    /// - Parameters:
    ///   - name: The name of the option.
    ///   - defaultValue: The default value of the option.
    public init(name: String, defaultValue: Value) {
        self.name = name
        self.defaultValue = defaultValue
        self.pickerOptions = nil
    }

    /// Initializes an option schema with a given set of `pickerOptions` and a
    /// `Int` default value, which should be an index into the `pickerOptions` array.
    /// - Parameters:
    ///   - name: The name of the option.
    ///   - pickerOptions: The array of option labels.
    ///   - defaultValue: An index into the `pickerOptions` array marking the default option value.
    public init?(name: String, pickerOptions: [String], defaultValue: Int) {
        if !pickerOptions.indices.contains(defaultValue) {
            return nil
        }
        self.name = name
        self.defaultValue = .int(defaultValue)
        self.pickerOptions = pickerOptions
    }
}
