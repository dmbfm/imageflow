import Backend
import Logging
import SwiftUI
import Values

public struct FlowNode: Sendable, Equatable, Codable {

    // MARK: - Public Properties

    /// The node's unique identifier
    public var id: UUID
    /// The node's name
    public var name: String
    /// The kind of the node
    public var kind: NodeKind
    /// The node's inputs
    public var inputs: [Input]
    // /// The node's outputs
    public var outputs: [Output]

    // MARK: - Public Types

    public struct Input: Hashable, Sendable, Codable, Identifiable {
        public var label: String
        public var value: Value
        public var semantics: ValueSemantics
        public var connected: Bool
        public var id: String { self.label }

        public init(label: String, value: Value, semantics: ValueSemantics, connected: Bool) {
            self.label = label
            self.value = value
            self.semantics = semantics
            self.connected = connected
        }
    }

    public struct Output: Hashable, Sendable, Codable {
        public var label: String
        public var type: ValueType
        public var connected: Bool

        public init(label: String, type: ValueType, connected: Bool) {
            self.label = label
            self.connected = connected
            self.type = type
        }
    }

    // MARK: - Initialization

    public init(
        id: UUID,
        name: String,
        kind: NodeKind,
        inputs: [Input],
        outputs: [Output],
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.inputs = inputs
        self.outputs = outputs
    }

    /// Creates a node that is build according to the given `NodeKind` schema.
    ///
    /// - Parameters:
    ///   - id: The node's unique identifier.
    ///   - kind: The `NodeKind` of the node.
    ///   - name: The node's name.
    public init(id: UUID = UUID(), kind: NodeKind, name: String? = nil, ) {
        self.id = id
        self.name = name ?? kind.displayName
        self.kind = kind
        self.inputs = kind.schema.inputs.map { input in
            .init(
                label: input.name,
                value: input.defaultValue ?? Value.defaultValue(forType: input.type),
                semantics: input.semantics,
                connected: false
            )
        }
        self.outputs = kind.schema.outputs.map { output in
            .init(label: output.name, type: output.type, connected: false)
        }
    }

    // MARK: - Subscripts

    public subscript(valueAt slot: PortSlot) -> Value {
        get {
            switch slot {
            case .input(let idx):
                self.inputs[idx].value

            case .output:
                fatalError("Trying to get value of a output port.")
            }
        }
        set {
            switch slot {
            case .input(let idx):
                self.inputs[idx].value = newValue
            case .output:
                fatalError("Trying to set the value of a output port.")
            }
        }
    }

    public subscript(valueTypeAt slot: PortSlot) -> ValueType {
        switch slot {
        case .input(let idx):
            self.inputs[idx].value.type

        case .output(let idx):
            self.outputs[idx].type
        }
    }

    public subscript(labelAt slot: PortSlot) -> String {
        get {
            switch slot {
            case .input(let idx): self.inputs[idx].label
            case .output(let idx): self.outputs[idx].label
            }
        }

        set {
            switch slot {
            case .input(let idx): self.inputs[idx].label = newValue
            case .output(let idx): self.outputs[idx].label = newValue
            }
        }
    }

    public subscript(connectedAt slot: PortSlot) -> Bool {
        get {
            switch slot {
            case .input(let idx): self.inputs[idx].connected
            case .output(let idx): self.outputs[idx].connected
            }
        }
        set {
            switch slot {
            case .input(let idx): self.inputs[idx].connected = newValue
            case .output(let idx): self.outputs[idx].connected = newValue
            }
        }
    }

    // MARK: - Port Methods

    /// Returns an array with all the valid `PortSlot`s for this node, ordered
    /// from `input` to `output`, with increasing indices.
    public var slots: [PortSlot] {
        self.inputs.indices.map { .input($0) } + self.outputs.indices.map { .output($0) }
    }

    /// Checks if a give `PortSlot` is valid for the given node.
    ///
    /// - Parameters:
    ///   - slot: The `PortSlot`
    public func isValidPortSlot(_ slot: PortSlot) -> Bool {
        self.slots.contains(slot)
    }

    /// Returns the number of connected ports of the node.
    public var numConnectedSlots: Int {
        self.inputs.count { $0.connected }
            + self.outputs.count {
                $0.connected
            }
    }

    /// Attemps to disconnect a givent port slot.
    /// - Parameter slot: The `PortSlot`
    /// - Returns: `DisconnectResult.notConnected` if the port is not connected,
    ///            `DisconnectResult.ok` otherwise.
    public mutating func disconnect(_ slot: PortSlot) -> DisconnectResult {
        if !self[connectedAt: slot] {
            return .notConnected
        }

        self[connectedAt: slot] = false

        return .ok
    }

    public enum DisconnectResult {
        case ok
        case notConnected
    }

    /// Attemps to connect a givent port slot.
    /// - Parameter slot: The `PortSlot`
    /// - Returns: `ConnectResult.alreadyConnected` if the port is alreacy connected,
    ///             `ConnectResult.ok` otherwise.
    public mutating func connect(_ slot: PortSlot) -> ConnectResult {
        if self[connectedAt: slot] {
            return .alreadyConnected
        }

        self[connectedAt: slot] = true

        return .ok
    }

    public enum ConnectResult {
        case ok
        case alreadyConnected
    }

    // MARK: - Variations

    /// `true` if the node has (more than one) variations.
    public var hasVariations: Bool {
        self.variations.count > 1
    }

    /// Returns an array with all the possible variations contigent on the
    /// current connected ports. For instance, a `passthroughNode` with no
    /// connections will have all the available variations; but, if a single
    /// slot is connected, this will constraint the variations so that only
    /// one (the current variation) will be available.
    public var variations: [NodeKind] {
        self.kind.allowedVariations(self.inputs.map { $0.connected }, self.outputs.map { $0.connected })
    }

    /// Returns the available variation, if any, other than the current one,
    /// that makes the `slot` have type `type`. It there are more than one,
    /// it will return the first one found.
    ///
    /// - Parameters:
    ///   - slot: The port slot.
    ///   - type: The disired type.
    ///
    /// - Returns:
    public func variation(soThatSlot slot: PortSlot, hasType type: ValueType) -> NodeKind? {
        // The current node kind already has `slot` with `type`
        if self[valueTypeAt: slot] == type {
            return self.kind
        }

        for variation in self.variations
            .filter({ $0 != self.kind })
        {
            let kind = variation
            let schema = kind.schema
            switch slot {
            case .output(let idx):
                if schema.outputs[idx].type == type { return kind }
            case .input(let idx):
                if schema.inputs[idx].type == type { return kind }
            }
        }

        return nil
    }

    /// Returns a `FlowModel` which is the given variation of the current node.
    /// If the given `variation` is not available for the node, returns nil.
    ///
    /// The returned node will have the same `name` and `id` from the current
    /// node. All the input values of the current node will be, if possible,
    /// converted and transferred to the variation node.
    ///
    /// - Parameter variation: The `Variation`.
    /// - Returns: The correnponding created `FlowNode`.
    public func variation(_ variation: NodeKind) -> Self? {
        if !self.variations.contains(variation) {
            return nil
        }

        var node = FlowNode(id: self.id, kind: variation, name: self.name)

        for idx in node.inputs.indices {
            if self.inputs.indices.contains(idx) {
                if let value = self.inputs[idx].value.convert(to: node.inputs[idx].value.type) {
                    node.inputs[idx].value = value
                }
                node.inputs[idx].connected = self.inputs[idx].connected
            }
        }

        for idx in node.outputs.indices {
            if self.outputs.indices.contains(idx) {
                node.outputs[idx].connected = self.outputs[idx].connected
            }
        }

        return node
    }

    /// Converts the current node to the node corresponding to the given
    /// `variation`. The variation node is obtained via the `variation`
    ///  method.
    ///
    /// - Parameter variation: The `Variation`.
    /// - Returns: `true` if the `variation` is available and the conversion
    ///            is successful and `false` otherwise.
    public mutating func convert(toVariation variation: NodeKind) -> Bool {
        guard let node = self.variation(variation) else { return false }
        self = node
        return true
    }

    // MARK: - Backend

    public var backendNode: Backend.Node {
        .init(
            id: self.id,
            kind: self.kind,
            inputs: self.inputs.map { $0.value },
            outputs: self.outputs.map { $0.type.defaultValue }
        )
    }
}
