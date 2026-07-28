//
//  FlowNode.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 19/01/26.
//

import Backend
import Helpers
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
    /// The node's outputs
    public var outputs: [Output]

    // MARK: - Public Types

    public struct Input: Hashable, Sendable, Codable, Identifiable {
        public var label: String
        public var index: Int
        public var value: Value
        public var connected: Bool
        public var id: Int { self.index }

        public init(
            label: String,
            index: Int,
            value: Value,
            connected: Bool,
        ) {
            self.label = label
            self.index = index
            self.value = value
            self.connected = connected
        }
    }

    public struct Output: Hashable, Sendable, Codable, Identifiable {
        public var label: String
        public var index: Int
        public var type: ValueType
        public var connected: Bool
        public var id: Int { self.index }

        public init(label: String, index: Int, type: ValueType, connected: Bool) {
            self.label = label
            self.index = index
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
    public init(id: UUID = UUID(), kind: NodeKind, name: String? = nil) {
        self.id = id
        self.name = name ?? kind.defaultNodeName
        self.kind = kind
        self.inputs = kind.schema.inputs.enumerated().map { (index, input) in
            .init(
                label: input.name,
                index: index,
                value: input.defaultValue ?? Value.defaultValue(forType: input.type),
                connected: false,
            )
        }
        self.outputs = kind.schema.outputs.enumerated().map { (index, output) in
            .init(label: output.name, index: index, type: output.type, connected: false)
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

    /// Returns `true` if this node has any connected port slots.
    public var hasConnectedSlots: Bool {
        self.numConnectedSlots > 0
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
            case .output(let idx) where schema.outputs.indices.contains(idx):
                if schema.outputs[idx].type == type { return kind }
            case .input(let idx) where schema.inputs.indices.contains(idx):
                if schema.inputs[idx].type == type { return kind }
            default:
                break
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

        for idx in node.inputs.indices where self.inputs.indices.contains(idx) {
            if let value = self.inputs[idx].value.convert(to: node.inputs[idx].value.type) {
                node.inputs[idx].value = value
            }
            node.inputs[idx].connected = self.inputs[idx].connected
        }

        for idx in node.outputs.indices where self.outputs.indices.contains(idx) {
            node.outputs[idx].connected = self.outputs[idx].connected
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

    public mutating func disconnectAllPorts() {
        for i in self.inputs.indices {
            self.inputs[i].connected = false
        }

        for i in self.outputs.indices {
            self.outputs[i].connected = false
        }
    }

    public func disconnectingAllPorts() -> Self {
        var node = self
        node.disconnectAllPorts()
        return node
    }

    public func defaultValue(forInput index: Int) -> Value? {

        let schema = self.kind.schema

        guard schema.inputs.indices.contains(index) else {
            return nil
        }

        let inputSchema = schema.inputs[index]
        return inputSchema.defaultValue ?? inputSchema.type.defaultValue
    }

    public func hasChanges(forInput index: Int) -> Bool {
        let schema = self.kind.schema

        guard schema.inputs.indices.contains(index), self.inputs.indices.contains(index) else {
            return false
        }

        let inputSchema = schema.inputs[index]
        let defaultValue = inputSchema.defaultValue ?? inputSchema.type.defaultValue

        return self.inputs[index].value != defaultValue
    }

    // MARK: - Filtering

    public func inputs(withNodeViewPlacement placement: NodeInputSchema.EditorPlacement.NodeView) -> [Input] {
        let schema = self.schema
        return self.inputs.filter({ schema.inputs[$0.index].editorPlacement.nodeView == placement })
    }

    public func inputs(withNodeViewPlacements placements: [NodeInputSchema.EditorPlacement.NodeView]) -> [Input] {
        let schema = self.schema
        return self.inputs.filter({ placements.contains(schema.inputs[$0.index].editorPlacement.nodeView) })
    }

    public func inputs(withInspectorPlacement placement: NodeInputSchema.EditorPlacement.Inspector) -> [Input] {
        let schema = self.schema
        return self.inputs.filter({ schema.inputs[$0.index].editorPlacement.inspector == placement })
    }

    // MARK: - Schema

    public var schema: NodeSchema {
        self.kind.schema
    }

    public func schema(forInput index: Int) -> NodeInputSchema? {
        self.schema.inputs[tryGetAt: index]
    }

    public func schemaWithFallback(forInput index: Int) -> NodeInputSchema {
        self.schema.inputs[tryGetAt: index] ?? .init(name: "Missing Schema", type: .float, semantics: .default)
    }

    public func schema(forOuptut index: Int) -> NodeOutputSchema? {
        self.schema.outputs[tryGetAt: index]
    }

    public func semantics(forInput index: Int) -> ValueSemantics? {
        self.schema(forInput: index)?.semantics
    }
}
