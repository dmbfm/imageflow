import Backend
import Combine
import CommonUtils
import Foundation
import Logging
import Models
import SwiftUI
import Values

import struct Models.Edge

@Observable
@MainActor
public final class NodeDataStore {

    // MARK: - Public Properties

    /// The nodes
    public var nodes: [UUID: FlowNode] = [:] {
        didSet {
            self.validateEdgesCache = nil
            // self.nodesPublisher.send(oldValue)
        }
    }

    /// The edges
    public var edges: Set<Edge> = [] {
        didSet {
            self.validateEdgesCache = nil
            // self.edgesPublisher.send(oldValue)
        }
    }

    // MARK: - Initialization

    public init(_ nodes: [UUID: FlowNode] = [:]) {
        self.nodes = nodes
    }

    // MARK: - Edges

    /// Returns all the edges that start at the given location.
    ///
    /// - Parameter from: The source location.
    /// - Returns: The list of edges.
    public func edges(from: PortLocation) -> [Edge] {
        self.edges.filter { $0.from == from }
    }

    /// Returns all the edges that end at the given location.
    ///
    /// - Parameter to: The destination location.
    /// - Returns: The list of edges.
    public func edges(to: PortLocation) -> [Edge] {
        self.edges.filter { $0.to == to }
    }

    /// Returns all of the edges that either start or end
    /// in the node with the given id.
    ///
    /// - Parameter node: The `FlowNode`.
    /// - Returns: The list of edges.
    public func edges(ofNode node: UUID) -> [Edge] {
        self.edges.filter { e in
            e.from.node == node || e.to.node == node
        }
    }

    /// Attempts to type check the operation of adding the given `Edge` to the store,
    /// returning a `TypeCheckEdgeResult` value.
    ///
    /// - Parameter edge: The edge we want to type check adding to the store.
    /// - Returns: The `TypeCheckEdgeResult`.
    public func typeCheck(addingEdge edge: Edge) -> TypeCheckAddingEdgeResult {

        if self.edges.contains(edge) {
            return .edgeAlreadyExists
        }

        let sourceType: ValueType
        switch self.getPortType(edge.from) {
        case .missingNode: return .missingNode(edge.from.node)
        case .invalidSlot: return .invalidPort(edge.from)
        case .ok(let type): sourceType = type
        }

        let destType: ValueType
        switch self.getPortType(edge.to) {
        case .missingNode: return .missingNode(edge.from.node)
        case .invalidSlot: return .invalidPort(edge.from)
        case .ok(let type): destType = type
        }

        if sourceType != destType {

            let sourceNode = self.nodes[edge.from.node]!
            let destNode = self.nodes[edge.to.node]!

            if let variation = destNode.variation(soThatSlot: edge.to.slot, hasType: sourceType) {
                return .typeMismatch(.fixConvertingDestTo(variation))
            }

            if let variation = sourceNode.variation(soThatSlot: edge.from.slot, hasType: destType) {
                return .typeMismatch(.fixConvertingSourceTo(variation))
            }

            return .typeMismatch(.nofix)
        }

        return .ok
    }

    /// The result of the `typeCheck(addingEdge:)` method.
    public enum TypeCheckAddingEdgeResult {
        /// The type checking was successful and the edge can be added.
        case ok
        /// The edge already exists in the store.
        case edgeAlreadyExists
        /// The node is missing
        case missingNode(UUID)
        /// The port is invalid
        case invalidPort(PortLocation)
        /// There is a type mismatch with the given fix
        case typeMismatch(TypeMismatchFix)

        public enum TypeMismatchFix: Sendable {
            /// The mismatch hax no fix
            case nofix
            /// The mismatch can be fixed by converting the destination to the
            /// given variation.
            case fixConvertingDestTo(NodeKind)
            /// The mismatch can be fixed by converting the sourc to the
            /// given variation.
            case fixConvertingSourceTo(NodeKind)
        }
    }

    /// Validates all the edge connection. Only checks to see if the edges and
    /// node connections match, and if there are no multiple edges incoming to the same
    /// port slot, or edges with missing nodes or ports. This makes no type-checking on
    /// the connections.
    ///
    /// - Returns: The `ValidateEdgesResult` value.
    public func validateEdges() -> ValidateEdgesResult {

        if let validateEdgesCache = self.validateEdgesCache {
            return validateEdgesCache
        }

        self.validateEdgesCache = {
            for edge in self.edges {
                let from = edge.from
                let to = edge.to

                guard let fromNode = self.nodes[from.node] else {
                    return .missingNode(from.node)
                }

                guard let toNode = self.nodes[to.node] else {
                    return .missingNode(to.node)
                }

                if !fromNode.isValidPortSlot(from.slot) {
                    return .invalidSlot(from)
                }

                if !toNode.isValidPortSlot(to.slot) {
                    return .invalidSlot(to)
                }

                if self.edges(to: to).count != 1 {
                    return .tooManyIncomingEdges(to)
                }
            }

            for (id, node) in self.nodes {
                for (idx, input) in node.inputs.enumerated() {
                    if input.connected {
                        if self.edges(to: .init(node: id, port: .input(idx))).count != 1 {
                            return .tooManyIncomingEdges(.init(node: id, port: .input(idx)))
                        }
                    }
                }
                for (idx, output) in node.outputs.enumerated() {
                    if output.connected {
                        if self.edges(from: .init(node: id, port: .output(idx))).count < 1 {
                            return .tooFewOutgointEdges(.init(node: id, port: .output(idx)))
                        }
                    }
                }
            }

            return .ok
        }()

        return self.validateEdgesCache!
    }

    /// The result of the `validateEdges` method.
    public enum ValidateEdgesResult: Equatable {
        /// Evertything ok :)
        case ok
        // The node with the given id is missing.
        case missingNode(UUID)
        // The given port slot is missing
        case invalidSlot(PortLocation)
        // Too may edges (more than one) are incoming to this port slot.
        case tooManyIncomingEdges(PortLocation)
        // Too few edges (zero) are outgoing from this port slot.
        case tooFewOutgointEdges(PortLocation)
    }

    /// We cache the validation results and invalidate when the store is changed.
    private var validateEdgesCache: ValidateEdgesResult? = nil

    /// Adds an edge between two node slots to the store. A number of checks are
    /// made to see if the edge is valid before inserting.
    ///
    /// - Parameter edge: The edge to be added.
    /// - Returns: The added edge (same as the input) or an `AddEdgeError` value.
    public func addEdge(_ edge: Edge) -> Result<Edge, AddEdgeError> {
        // First, check if the edge is valid in principle
        // (this is not strictly necessary since an `Edge` should,
        // by construction, be valid, but I will leave this as a precaution)
        if !edge.isValid() {
            return .failure(.invalidEdge)
        }

        // Check if the edge is already present
        if self.edges.contains(edge) {
            return .failure(.duplicatedEdge)
        }

        // Check if the destination port slot is already connected
        if self.edges(to: edge.to).count > 0 {
            return .failure(.destinationAlreadyConnected(edge.to))
        }

        let from = edge.from
        let to = edge.to

        // Check if the source node is present
        if self.nodes[from.node] == nil {
            return .failure(.missingNode(from.node))
        }

        // Check if the destination node is present
        if self.nodes[to.node] == nil {
            return .failure(.missingNode(to.node))
        }

        // Check if the source port slot exists
        if !self.nodes[from.node]!.isValidPortSlot(from.slot) {
            return .failure(.invalidSourceSlot(from.slot))
        }

        // Check if the destination port slot exitsts
        if !self.nodes[to.node]!.isValidPortSlot(to.slot) {
            return .failure(.invalidDestinationSlot(to.slot))
        }

        // Check if the destination port slot is not already set as connected
        if self.nodes[to.node]![connectedAt: to.slot] {
            return .failure(.destinationAlreadyConnected(to))
        }

        // Set the slots as connected
        self.nodes[from.node]![connectedAt: from.slot] = true
        self.nodes[to.node]![connectedAt: to.slot] = true

        // Check if the slots have the same type
        let sourceType = self.nodes[from.node]![valueTypeAt: from.slot]
        let destType = self.nodes[to.node]![valueTypeAt: to.slot]
        if sourceType != destType {
            return .failure(.typeMismatch(source: sourceType, dest: destType))

        }

        // Add the edge to the set
        self.edges.insert(edge)

        // Make sure we are in a valid state
        if self.validateEdges() != .ok {
            return .failure(.invalidEdgesState)
        }

        return .success(edge)
    }

    public enum AddEdgeError: Error, Equatable {
        case invalidEdge
        case duplicatedEdge
        case typeMismatch(source: ValueType, dest: ValueType)
        case missingNode(UUID)
        case invalidSourceSlot(PortSlot)
        case invalidDestinationSlot(PortSlot)
        case destinationAlreadyConnected(PortLocation)
        case invalidEdgesState
    }

    /// Removes the give `edge` from the stor, if it is present. Removing
    /// and edge will change the `connected` flag of the edges` slots
    /// accordingly.
    ///
    /// - Parameter edge: The edge to be removed.
    /// - Returns: In case of failure, a `RemoveEdgeError` and a `Void` if successful.
    public func removeEdge(_ edge: Edge) -> Result<(), RemoveEdgeError> {

        // Check if edge is present
        if !self.edges.contains(edge) {
            return .failure(.edgeNotPresent)
        }

        // Check if source node is present
        if self.nodes[edge.from.node] == nil {
            return .failure(.missingSourceNode)
        }

        // Check if destination node is present
        if self.nodes[edge.to.node] == nil {
            return .failure(.missingDestinationNode)
        }

        // Check if source node port slot is valid
        if !self.nodes[edge.from.node]!.isValidPortSlot(edge.from.slot) {
            return .failure(.invalidSourcePortSlot)
        }

        // Check if destination node port slot is valid
        if !self.nodes[edge.to.node]!.isValidPortSlot(edge.to.slot) {
            return .failure(.invalidDestinationPortSlot)
        }

        // Check how many edges are outgoing from the source.
        switch self.edges(from: edge.from).count {
        case 0:
            // Note: this case should not really happen
            return .failure(.unreachable)
        case 1:
            // Should not happen but check just in case
            if self.edges(from: edge.from).first! != edge {
                return .failure(.unreachable)
            }
            // Since only the edge we are removing is connetced to the source,
            // attempt to disconect it.
            if case .notConnected = self.nodes[edge.from.node]!.disconnect(edge.from.slot) {
                return .failure(.sourceNotConnected)
            }
        default:
            // Since there are other edges coming out of the source, just check if
            // the `connected` property is valid.
            if !self.nodes[edge.from.node]![connectedAt: edge.from.slot] {
                return .failure(.sourceNotConnected)
            }
        }

        // Attempt to disconnect the destination port slot
        if case .notConnected = self.nodes[edge.to.node]!.disconnect(edge.to.slot) {
            return .failure(.destinationNotConnected)
        }

        // Remove the edge from the set
        self.edges.remove(edge)

        // Check if we are in a valid state
        if self.validateEdges() != .ok {
            return .failure(.validateEdges)
        }

        return .success(())
    }

    public enum RemoveEdgeError: Error {
        case edgeNotPresent
        case missingSourceNode
        case missingDestinationNode
        case invalidSourcePortSlot
        case invalidDestinationPortSlot
        case sourceNotConnected
        case destinationNotConnected
        case unreachable
        case validateEdges
    }

    // MARK: - Ports

    /// Gets the `ValueType` of the port slot at the give `PortLocation`,
    /// or will fail with a reason defined in `GetPortTypeResult`.
    ///
    /// - Parameter loc: The location of the port slot.
    /// - Returns: The result.
    public func getPortType(_ loc: PortLocation) -> GetPortTypeResult {
        guard let node = self.nodes[loc.node] else {
            return .missingNode
        }

        if !node.isValidPortSlot(loc.slot) {
            return .invalidSlot
        }

        return .ok(node[valueTypeAt: loc.slot])
    }

    public enum GetPortTypeResult {
        case ok(ValueType)
        case missingNode
        case invalidSlot
    }

    /// Attempts to set the input value for the given `port` slot index of the
    /// node with the give `id` to `value`. Fails if the node does not exists or if the
    /// port index is invalid.
    ///
    /// - Parameters:
    ///   - id: The id of the node.
    ///   - port: The index of the input port slot.
    ///   - value: The value to be set.
    ///
    /// - Returns: The previous `Value` if successful, a `SetInputValueError` otherwise.
    @discardableResult
    public func setInputValue(_ id: UUID, _ port: Int, _ value: Value) -> Result<Value, SetInputValueError> {
        if self.nodes[id] == nil {
            return .failure(.invalidNodeID)
        }

        if !self.nodes[id]!.isValidPortSlot(.input(port)) {
            return .failure(.invalidPort)
        }

        let oldValue = self.nodes[id]!.inputs[port].value

        if !oldValue.is(sameTypeAs: value) {
            return .failure(.typeMismatch(old: oldValue.type, new: value.type))
        }

        if oldValue != value {
            self.nodes[id]!.inputs[port].value = value
        }

        return .success(oldValue)
    }

    public enum SetInputValueError: Error {
        case invalidNodeID
        case invalidPort
        case typeMismatch(old: ValueType, new: ValueType)
    }

    /// A description
    /// - Parameters:
    ///   - id: The id of the node.
    ///   - slot: The port slot to set.
    ///   - connected: The value to set it to.
    ///
    /// - Returns: The previous value if successful or the failure reason via
    ///            `SetPortConnectedError` on failure.
    @discardableResult
    public func setPortConnected(_ id: UUID, slot: PortSlot, connected: Bool) -> Result<Bool, SetPortConnectedError> {
        if self.nodes[id] == nil {
            return .failure(.invalidNodeID)
        }

        if !self.nodes[id]!.isValidPortSlot(slot) {
            return .failure(.invalidPort)
        }

        let oldValue = self.nodes[id]![connectedAt: slot]

        if connected != oldValue {
            self.nodes[id]![connectedAt: slot] = connected
        }

        return .success(oldValue)
    }

    public enum SetPortConnectedError: Error {
        case invalidNodeID
        case invalidPort
    }

    /// Returns the value of the port slot's `connected` flag.
    ///
    /// - Parameter location: The `PortLocation`
    /// - Returns: The value of the flag, or a `GetPortConnectedError` value.
    public func getPortConnected(_ location: PortLocation) -> Result<Bool, GetPortConnectedError> {
        let id = location.node
        let slot = location.slot

        if self.nodes[id] == nil {
            return .failure(.invalidNodeID)
        }

        if !self.nodes[id]!.isValidPortSlot(slot) {
            return .failure(.invalidPort)
        }

        return .success(self.nodes[id]![connectedAt: slot])
    }

    public enum GetPortConnectedError: Error {
        case invalidNodeID
        case invalidPort
    }

    // MARK: - Nodes

    /// Attempts to add the given `node` to the store. Fails if
    ///   - the a node with the same `id` is alrady in the store, or,
    ///   - the `node` has any of its slots set to `connected`.
    ///
    /// - Parameters:
    ///   - node: The node to add.
    ///
    /// - Returns: The result of the operation.
    @discardableResult
    public func addNode(_ node: FlowNode) -> Result<(), AddNodeError> {
        if self.nodes[node.id] != nil {
            return .failure(.repeatedNodeID(node.id))
        }

        if node.inputs.filter({ $0.connected }).count > 0
            || node.outputs.filter({ $0.connected }).count > 0
        {
            return .failure(.addingConnectedNode)
        }

        self.nodes[node.id] = node

        return .success(())
    }

    public enum AddNodeError: Error {
        case repeatedNodeID(UUID)
        case addingConnectedNode
    }

    /// Attembs to remove the node with the given `id` from the store. Fails if
    /// the `id` is not found, or if the removal of any of the node's edges fails.
    ///
    /// - Parameter id: The id of the node.
    /// - Returns: The result of the operation.
    @discardableResult
    public func removeNode(_ id: UUID) -> Result<(), RemoveNodeError> {
        if self.nodes[id] == nil {
            return .failure(.invalidNodeID(id))
        }

        for edge in self.edges(ofNode: id) {
            if case let .failure(err) = self.removeEdge(edge) {
                return .failure(.removeEdge(err))
            }
        }

        self.nodes.removeValue(forKey: id)

        return .success(())
    }

    public enum RemoveNodeError: Error {
        case invalidNodeID(UUID)
        case removeEdge(RemoveEdgeError)
    }
}

extension NodeDataStore: @preconcurrency Equatable {
    public static func == (lhs: NodeDataStore, rhs: NodeDataStore) -> Bool {
        rhs.nodes == lhs.nodes && rhs.edges == lhs.edges
    }
}
