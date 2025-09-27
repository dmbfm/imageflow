import Backend
import Foundation
import Logging

@Observable
@MainActor
public final class Flow {
    /// All nodes keyed by identifier.
    public var nodes: [UUID: FlowNode]
    /// Canvas positions for each node identifier.
    public var nodePositions: [UUID: CGPoint]
    /// The set of node identifiers that are currently selected.
    public var selection: Set<UUID>
    /// All edges currently present in the graph.
    public var edges: Set<Edge>

    @ObservationIgnored
    private var liveSelectionSnapshot: Set<UUID>? = nil

    /// Creates a new flow model.
    /// - Parameters:
    ///   - nodes: Initial node map.
    ///   - nodePositions: Initial positions keyed by node identifier.
    ///   - selection: Initial selection set.
    ///   - edges: Initial edge set.
    public init(
        nodes: [UUID: FlowNode] = [:],
        nodePositions: [UUID: CGPoint] = [:],
        selection: Set<UUID> = [],
        edges: Set<Edge> = []
    ) {
        self.nodes = nodes
        self.nodePositions = nodePositions
        self.selection = selection
        self.edges = edges
    }
}

// MARK: - Nodes, Ports and Edges

extension Flow {
    /// Returns all edges that originate from or terminate at the supplied node identifier.
    /// - Parameter id: The node identifier.
    /// - Returns: All edges touching the node.
    public func edges(ofNode id: UUID) -> [Edge] {
        self.edges.filter({ edge in edge.from.node == id || edge.to.node == id })
    }

    /// Returns the number of edges of the given node.
    /// - Parameter id: The node's id.
    /// - Returns: The number of edges.
    public func numberOfEdges(ofNode id: UUID) -> Int {
        self.edges.count(where: { edge in edge.from.node == id || edge.to.node == id })
    }

    /// Returns the number of edges that touch a specific port location.
    /// - Parameter port: The port to inspect.
    /// - Returns: The number of edges whose start or end matches the port.
    public func numberOfEdges(ofPort port: PortLocation) -> Int {
        self.edges.count(where: { edge in edge.from == port || edge.to == port })
    }

    public func numberOfEdges(withSameDestinationAs edge: Edge) -> Int {
        self.edges.count(where: { $0.to == edge.to })
    }

    /// Inserts a node into the flow graph. The node is expected to have all of its ports set as not connected.
    /// - Parameters:
    ///   - node: Node model to insert.
    ///   - position: Canvas position for the node.
    /// - Throws: `FlowError.repeatedNodeId` when a node with the same identifier already exists, or `addingNodeWithConnectedPorts`
    ///            when trying to add a node with connected ports.
    public func addNode(_ node: FlowNode, at position: CGPoint) throws(FlowError) {
        if self.nodes[node.id] != nil || self.nodePositions[node.id] != nil {
            throw .repeatedNodeId
        }

        if node.hasConnectedSlots {
            throw .addingNodeWithConnectedPorts
        }

        self.nodes[node.id] = node
        self.nodePositions[node.id] = position
    }

    /// Removes a node and returns its model and position. If the node belongs
    /// to any edges, a `removedNodeWithExistingEdges` error is thrown; it it has any
    /// ports set as connected a `removedNodeWithConnectedPorts`
    /// error is thrown.
    /// - Parameter id: Node identifier to remove.
    /// - Returns: The removed node and its previous position.
    /// - Throws: `FlowError.nodeNotFound` if the node does not exist.
    @discardableResult
    public func deleteNode(_ id: UUID) throws(FlowError) -> (FlowNode, CGPoint) {
        guard let node = self.nodes.removeValue(forKey: id), let pos = self.nodePositions.removeValue(forKey: id) else {
            throw .nodeNotFound
        }

        if self.numberOfEdges(ofNode: node.id) > 0 {
            throw .removedNodeWithExistingEdges
        }

        if node.hasConnectedSlots {
            throw .removedNodeWithConnectedPorts
        }

        return (node, pos)
    }

    /// Inserts a node into the flow graph. The node is expected to have all of its ports set as not connected.
    /// If a `UndoManager` is provider, registers a undo action.
    /// - Parameters:
    ///   - node: Node model to insert.
    ///   - position: Canvas position for the node.
    ///   - um: Optional undo manager that will remove the node on undo.
    ///   - undoTitle: Human readable action name.
    /// - Throws: `FlowError.repeatedNodeId` when a node with the same identifier already exists.
    public func addNode(
        _ node: FlowNode,
        at position: CGPoint,
        undoManager um: UndoManager?,
        undoTitle: String = "Create Node"
    ) throws(FlowError) {
        try self.addNode(node, at: position)
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                do {
                    try this.deleteNode(node.id, undoManager: um)
                } catch {
                    log("Failed to undo `deleteNode`: \(error)")
                }
            }
        )
        um?.setActionName(undoTitle)
    }

    /// Removes a node and returns its model and position. If the node belongs
    /// to any edges, a `removedNodeWithExistingEdges` error is thrown; it it has any
    /// ports set as connected a `removedNodeWithConnectedPorts`
    /// error is thrown.
    ///
    /// If a `UndoManager` is provider, registers a undo action.
    /// - Parameters:
    ///   - id: Node identifier to remove.
    ///   - um: Optional undo manager used to restore the node.
    ///   - undoTitle: Human readable action name.
    /// - Throws: `FlowError.nodeNotFound` if the node does not exist.
    public func deleteNode(
        _ id: UUID,
        undoManager um: UndoManager?,
        undoTitle: String = "Delete Node"
    ) throws(FlowError) {
        let (node, pos) = try self.deleteNode(id)
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                do {
                    try this.addNode(node, at: pos, undoManager: um)
                } catch {
                    log("Failed to undo `deleteNode`: \(error)")
                }
            }
        )
        um?.setActionName(undoTitle)
    }

    /// Inserts an edge into the graph without touching port flags.
    /// - Parameter edge: Edge to insert.
    /// - Throws: `FlowError.edgeAlreadyExists` if the same edge is already present.
    public func addEdge(_ edge: Edge) throws(FlowError) {
        if self.edges.contains(edge) {
            throw .edgeAlreadyExists
        }

        self.edges.insert(edge)
    }

    /// Removes an edge from the graph without touching port flags.
    /// - Parameter edge: Edge to remove.
    /// - Throws: `FlowError.edgeNotFound` if the edge does not exist.
    public func deleteEdge(_ edge: Edge) throws(FlowError) {
        guard let _ = self.edges.remove(edge) else {
            throw .edgeNotFound
        }
    }

    /// Inserts an edge and registers an undo action that removes it again.
    /// - Parameters:
    ///   - edge: Edge to insert.
    ///   - um: Optional undo manager.
    ///   - undoTitle: Human readable action name.
    /// - Throws: `FlowError.edgeAlreadyExists` if the edge already exists.
    public func addEdge(
        _ edge: Edge,
        undoManager um: UndoManager?,
        undoTitle: String = "Create Edge"
    ) throws(FlowError) {
        try self.addEdge(edge)
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                do {
                    try self.deleteEdge(edge, undoManager: um)
                } catch {
                    log("Failed to undo `deleteNode`: \(error)")
                }
            }
        )
        um?.setActionName(undoTitle)
    }

    /// Removes an edge and registers an undo action that re-inserts it.
    /// - Parameters:
    ///   - edge: Edge to remove.
    ///   - um: Optional undo manager.
    ///   - undoTitle: Human readable action name.
    /// - Throws: `FlowError.edgeNotFound` if the edge does not exist.
    public func deleteEdge(
        _ edge: Edge,
        undoManager um: UndoManager?,
        undoTitle: String = "Delete Edge"
    ) throws(FlowError) {
        try self.deleteEdge(edge)
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                do {
                    try self.addEdge(edge, undoManager: um)
                } catch {
                    log("Failed to undo `deleteNode`: \(error)")
                }
            }
        )
        um?.setActionName(undoTitle)
    }

    /// Updates the `connected` flag for a given port slot without registering undo support.
    /// - Parameters:
    ///   - port: Port to update.
    ///   - value: New `connected` state.
    /// - Returns: The previous `connected` value.
    /// - Throws: `FlowError.nodeNotFound` if the node is missing.
    @discardableResult
    public func setNodePortConnected(_ port: PortLocation, _ value: Bool) throws(FlowError) -> Bool {
        if self.nodes[port.node] == nil {
            throw .nodeNotFound
        }

        let prev = self.nodes[port.node]![connectedAt: port.slot]

        if prev != value {
            self.nodes[port.node]![connectedAt: port.slot] = value
        }

        return prev
    }

    /// Updates the `connected` flag for a port and records the previous value on the undo stack.
    /// - Parameters:
    ///   - port: Port to update.
    ///   - value: New `connected` state.
    ///   - um: Optional undo manager used to restore the previous value.
    /// - Returns: The previous `connected` value.
    /// - Throws: `FlowError.nodeNotFound` if the node is missing.
    @discardableResult
    public func setNodePortConnected(
        _ port: PortLocation,
        _ value: Bool,
        undoManager um: UndoManager?
    ) throws(FlowError) -> Bool {
        let prev = try self.setNodePortConnected(port, value)

        if prev != value {
            um?.registerUndo(
                withTarget: self,
                handler: { [weak um] this in
                    do {
                        try this.setNodePortConnected(port, prev, undoManager: um)
                    } catch {
                        log("Failed to undo `setPortConnected`: \(error)")
                    }
                }
            )
        }

        return prev
    }

    /// Removes an edge and clears the `connected` flags for the involved ports.
    /// - Parameter edge: Edge to remove.
    /// - Throws: `FlowError` when the edge or referenced ports are invalid.
    public func deleteEdgeDisconnectingNodes(_ edge: Edge) throws(FlowError) {
        if !self.edges.contains(edge) {
            throw .edgeNotFound
        }

        if self.nodes[edge.from.node] == nil {
            throw .missingEdgeSourceNode
        }

        if self.nodes[edge.to.node] == nil {
            throw .missingEdgeDestinationNode
        }

        if !self.nodes[edge.from.node]![connectedAt: edge.from.slot] {
            throw .edgeSourcePortNotConnected
        }

        if !self.nodes[edge.to.node]![connectedAt: edge.to.slot] {
            throw .edgeDestinationPortNotConnected
        }

        try self.deleteEdge(edge)

        if self.numberOfEdges(ofPort: edge.from) < 2 {
            self.nodes[edge.from.node]![connectedAt: edge.from.slot] = false
        }

        self.nodes[edge.to.node]![connectedAt: edge.to.slot] = false
    }

    /// Removes an edge, clears port flags, and registers an undo action that restores the previous connection.
    /// - Parameters:
    ///   - edge: Edge to remove.
    ///   - um: Optional undo manager.
    /// - Throws: `FlowError` when the edge or referenced ports are invalid.
    public func deleteEdgeDisconnectingNodes(_ edge: Edge, undoManager um: UndoManager?) throws(FlowError) {
        try self.deleteEdgeDisconnectingNodes(edge)
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                do {
                    try this.addEdgeConnectingNodes(edge, undoManager: um)
                } catch {
                    log("\(error)", level: .error)
                }
            }
        )
    }

    /// Inserts an edge and marks both ports as connected.
    /// - Parameter edge: Edge to insert.
    /// - Throws: `FlowError` when the edge already exists or references invalid ports.
    public func addEdgeConnectingNodes(_ edge: Edge) throws(FlowError) {

        switch self.canAddEdge(edge) {
        case .ok:
            break
        case .failure(let failure):
            switch failure {
            case .causesCycle:
                throw .edgeCausesCycle
            case .destinationPortAlreadyConnected:
                throw .edgeDestinationPortAlreadyConnected
            case .duplicateEdge:
                throw .edgeAlreadyExists
            case .edgeWithSameDestinationAlreadyExists:
                throw .edgeDestinationPortAlreadyConnected
            case .invalidDestinationPortSlot:
                throw .edgeInvalidDestPort
            case .invalidSourcePortSlot:
                throw .edgeInvalidSourcePort
            case .missingDestinationNode:
                throw .missingEdgeDestinationNode
            case .missingSourceNode:
                throw .missingEdgeSourceNode
            case .typeMismatch(let fix):
                throw .edgeTypeError(fix)
            }
        }

        if self.edges.contains(edge) {
            throw .edgeAlreadyExists
        }

        if self.nodes[edge.from.node] == nil {
            throw .missingEdgeSourceNode
        }

        if self.nodes[edge.to.node] == nil {
            throw .missingEdgeDestinationNode
        }

        if self.nodes[edge.to.node]![connectedAt: edge.to.slot] {
            throw .edgeDestinationPortAlreadyConnected
        }

        try self.addEdge(edge)
        self.nodes[edge.from.node]![connectedAt: edge.from.slot] = true
        self.nodes[edge.to.node]![connectedAt: edge.to.slot] = true
    }

    /// Inserts an edge, marks ports as connected, and registers an undo action that disconnects it again.
    /// - Parameters:
    ///   - edge: Edge to insert.
    ///   - um: Optional undo manager.
    /// - Throws: `FlowError` when the edge already exists or references invalid ports.
    public func addEdgeConnectingNodes(_ edge: Edge, undoManager um: UndoManager?) throws(FlowError) {
        try self.addEdgeConnectingNodes(edge)
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                do {
                    try self.deleteEdgeDisconnectingNodes(edge, undoManager: um)
                } catch {
                    log("\(error)", level: .error)
                }
            }
        )
    }

    /// Removes a node together with all of its connected edges.
    /// - Parameter id: Node identifier to remove.
    /// - Returns: A snapshot containing the node, its position, and the removed edges.
    /// - Throws: `FlowError` when the node or one of its edges cannot be removed.
    public func deleteNodeRemovingEdges(_ id: UUID) throws(FlowError) -> DeleteNodeRemovingEdgesResult {
        let edges = self.edges(ofNode: id)

        for edge in edges {
            try self.deleteEdgeDisconnectingNodes(edge)
        }

        let (node, pos) = try self.deleteNode(id)

        return .init(node: node, position: pos, edges: edges)
    }

    /// Removes a node and its edges, recording an undo action that re-inserts everything.
    /// - Parameters:
    ///   - id: Node identifier to remove.
    ///   - um: Optional undo manager.
    /// - Returns: A snapshot containing the node, its position, and the removed edges.
    /// - Throws: `FlowError` when the node or one of its edges cannot be removed.
    @discardableResult
    public func deleteNodeRemovingEdges(
        _ id: UUID,
        undoManager um: UndoManager?
    ) throws(FlowError) -> DeleteNodeRemovingEdgesResult {
        let result = try self.deleteNodeRemovingEdges(id)

        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                do {
                    try this.addNodeWithEdges(
                        result.node,
                        at: result.position,
                        withEdges: Set(result.edges),
                        undoManager: um
                    )
                } catch {
                    log("\(error)", level: .error)
                }
            }
        )

        return result
    }

    public func addEdgeConnectingNodesConvertingIfNeeded(_ edge: Edge) throws(FlowError) -> AddEdgeReplaceNode {
        var result: AddEdgeReplaceNode = .none
        do {
            try self.addEdgeConnectingNodes(edge)
        } catch {
            switch error {
            case .edgeTypeError(let fix):
                switch fix {
                case .cantFix:
                    throw error
                case .fixConvertingDestTo(let kind):
                    let node = self.nodes[edge.to.node]!
                    result = .dest(node)
                    if !self.nodes[edge.to.node]!.convert(toVariation: kind) {
                        throw .failedToConvertNode(from: node.kind, to: kind)
                    }
                case .fixConvertingSourceTo(let kind):
                    let node = self.nodes[edge.from.node]!
                    result = .source(node)
                    if !self.nodes[edge.from.node]!.convert(toVariation: kind) {
                        throw .failedToConvertNode(from: node.kind, to: kind)
                    }
                }
                break
            default:
                throw error
            }
        }

        if result != .none {
            try self.addEdgeConnectingNodes(edge)
        }

        return result
    }

    private func restoreNode(_ node: FlowNode, undoManager um: UndoManager?) throws(FlowError) {
        guard let prev = self.nodes[node.id] else {
            throw .nodeNotFound
        }

        if prev != node {
            self.nodes[node.id] = node
            um?.registerUndo(
                withTarget: self,
                handler: { [weak um] this in
                    do {
                        try this.restoreNode(prev, undoManager: um)
                    } catch {
                        log("\(error)", level: .error)
                    }
                }
            )
        }
    }

    public func addEdgeConnectingNodesConvertingIfNeeded(
        _ edge: Edge,
        undoManager um: UndoManager?
    ) throws(FlowError) -> AddEdgeReplaceNode {
        let result = try addEdgeConnectingNodesConvertingIfNeeded(edge)

        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                do {
                    switch result {
                    case .none:
                        try this.deleteEdgeDisconnectingNodes(edge, undoManager: um)
                    case .dest(let node), .source(let node):
                        um?.beginUndoGrouping()
                        try this.deleteEdgeDisconnectingNodes(edge, undoManager: um)
                        try this.restoreNode(node, undoManager: um)
                        um?.endUndoGrouping()
                        break
                    }
                } catch {
                    log("\(error)", level: .error)
                }
            }
        )

        return result
    }

    /// Inserts a node and recreates the supplied edges, ensuring port state is consistent.
    /// - Parameters:
    ///   - node: Node model to insert.
    ///   - position: Canvas position for the node.
    ///   - edges: Edges to reconnect after the node is inserted.
    /// - Throws: `FlowError` when any operation fails.
    public func addNodeWithEdges(_ node: FlowNode, at position: CGPoint, withEdges edges: Set<Edge>) throws(FlowError) {
        try self.addNode(node, at: position)

        for edge in edges {
            try self.addEdgeConnectingNodes(edge)
        }
    }

    /// Inserts a node with edges and registers an undo action that removes them again.
    /// - Parameters:
    ///   - node: Node model to insert.
    ///   - position: Canvas position for the node.
    ///   - edges: Edges to reconnect after the node is inserted.
    ///   - um: Optional undo manager.
    /// - Throws: `FlowError` when any operation fails.
    public func addNodeWithEdges(
        _ node: FlowNode,
        at position: CGPoint,
        withEdges edges: Set<Edge>,
        undoManager um: UndoManager?
    ) throws(FlowError) {
        try self.addNodeWithEdges(node, at: position, withEdges: edges)
        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                do {
                    try self.deleteNodeRemovingEdges(node.id, undoManager: um)
                } catch {
                    log("\(error)", level: .error)
                }
            }
        )
    }
}

// MARK: - Validation

extension Flow {
    /// Validates the flow graph, ensuring that:
    ///   - Each edge is connected to an existing node, and the port is marked as connected.
    ///   - Each node port marked as connected belongs to a edge.
    ///   - Each node port marked as disconnected does not belong to a edge.
    ///   - Each input port is connected to at most one edge.
    ///
    /// - Parameters:
    ///
    /// - Throws:
    public func validateNodeGraph() throws(FlowValidationError) {

        // Check that to every `nodePositions` entry there is a corresponding `nodes`
        // entry.
        for (id, _) in self.nodePositions {
            if self.nodes[id] == nil {
                throw .nodeWithNoData
            }
        }

        // For every node
        for (_, node) in self.nodes {

            // Check that the node position exists
            if self.nodePositions[node.id] == nil {
                throw .nodeWithNoPosition
            }

            // Check that every input has at most one edge
            for (idx, _) in node.inputs.enumerated() {
                if self.numberOfEdges(ofPort: .init(node: node.id, port: .input(idx))) > 1 {
                    throw .tooManyEdgesForInput(node.id, idx)
                }
            }

            // Chech that every port slot that is connected has a corresponding edge; and that disconnected slots have no edge.
            for slot in node.slots {
                let location = PortLocation(node: node.id, port: slot)
                let edgeCount = self.numberOfEdges(ofPort: location)
                if node[connectedAt: slot] {
                    if edgeCount <= 0 {
                        throw .connectedPortWithoutEdge(location)
                    }
                } else {
                    if edgeCount > 0 {
                        throw .disconnectedPortWithEdge(location)
                    }
                }
            }
        }

        // For every edge
        for edge in self.edges {
            guard let from = self.nodes[edge.from.node] else {
                throw .sourceNodeMissingForEdge(edge)
            }

            guard let to = self.nodes[edge.to.node] else {
                throw .destinationNodeMissingForEdge(edge)
            }

            if !from[connectedAt: edge.from.slot] {
                throw .edgeSourceNotConnected(edge)
            }

            if !to[connectedAt: edge.to.slot] {
                throw .edgeDestinationNotConnected(edge)
            }
        }

        if self.hasCycles() {
            throw .graphHasCycles
        }
    }

    public enum FlowValidationError: Error {
        case nodeWithNoPosition
        case nodeWithNoData
        case tooManyEdgesForInput(UUID, Int)
        case connectedPortWithoutEdge(PortLocation)
        case disconnectedPortWithEdge(PortLocation)
        case sourceNodeMissingForEdge(Edge)
        case destinationNodeMissingForEdge(Edge)
        case edgeSourceNotConnected(Edge)
        case edgeDestinationNotConnected(Edge)
        case graphHasCycles
    }

    /// Detects if the flow graph has any cycles in it.
    private func hasCycles(addingEdge edge: Edge? = nil) -> Bool {
        let graph = FlowGraph(.init())
        for (id, _) in nodes {
            graph.addNode(id)
        }
        for edge in self.edges {
            graph.addEdge(
                .init(
                    from: .init(node: edge.from.node, slot: edge.from.slot.index),
                    end: .init(node: edge.to.node, slot: edge.to.slot.index)
                )
            )
        }

        if let edge {
            graph.addEdge(
                .init(
                    from: .init(node: edge.from.node, slot: edge.from.slot.index),
                    end: .init(node: edge.to.node, slot: edge.to.slot.index)
                )
            )
        }

        return graph.detectCycles() == .hasCycles
    }

    /// Checkes if the given edge can be safely added to the graph; if not, returns
    /// the reason it can't be added.
    /// - Parameter edge:
    /// - Returns:
    public func canAddEdge(_ edge: Edge) -> CanAddEdgeResult {
        // Check if the edge already exists
        if self.edges.contains(edge) {
            return .failure(.duplicateEdge)
        }

        // Check if another edge has the same destination
        if self.numberOfEdges(withSameDestinationAs: edge) > 0 {
            return .failure(.edgeWithSameDestinationAlreadyExists)
        }

        // Check if source node exists.
        guard let sourceNode = self.nodes[edge.from.node] else {
            return .failure(.missingSourceNode)
        }

        // Check if destination node exists.
        guard let destNode = self.nodes[edge.to.node] else {
            return .failure(.missingDestinationNode)
        }

        // Check if source port exists
        if !sourceNode.isValidPortSlot(edge.from.slot) {
            return .failure(.invalidSourcePortSlot)
        }

        // Check if destination port exists
        if !destNode.isValidPortSlot(edge.to.slot) {
            return .failure(.invalidDestinationPortSlot)
        }

        // Check if destination port is already connected
        if destNode[connectedAt: edge.to.slot] {
            return .failure(.destinationPortAlreadyConnected)
        }

        // Typecheck the ports
        let sourceType = self.nodes[edge.from.node]![valueTypeAt: edge.from.slot]
        let destType = self.nodes[edge.to.node]![valueTypeAt: edge.to.slot]
        if sourceType != destType {
            if let variation = destNode.variation(soThatSlot: edge.to.slot, hasType: sourceType) {
                return .failure(.typeMismatch(.fixConvertingDestTo(variation)))
            } else if let variation = sourceNode.variation(soThatSlot: edge.from.slot, hasType: destType) {
                return .failure(.typeMismatch(.fixConvertingSourceTo(variation)))
            } else {
                return .failure(.typeMismatch(.cantFix))
            }
        }

        // Check if a cycle is created
        if self.hasCycles(addingEdge: edge) {
            return .failure(.causesCycle)
        }

        return .ok
    }

    public enum CanAddEdgeResult {
        case ok
        case failure(Failure)

        public enum Failure {
            case duplicateEdge
            case edgeWithSameDestinationAlreadyExists
            case missingSourceNode
            case missingDestinationNode
            case invalidSourcePortSlot
            case invalidDestinationPortSlot
            case destinationPortAlreadyConnected
            case causesCycle
            case typeMismatch(TypeMismatch)
        }

        public enum TypeMismatch: Sendable {
            case cantFix
            case fixConvertingDestTo(NodeKind)
            case fixConvertingSourceTo(NodeKind)
        }
    }

}

// MARK: - Selection

extension Flow {

    /// Modes available for selection changes.
    public enum SelectionMode {
        /// Replace the existing selection with the provided identifiers.
        case replace
        /// Merge the provided identifiers into the existing selection.
        case union
    }

    /// Returns whether the supplied node identifier is currently selected.
    /// - Parameter id: Node identifier to test.
    public func isNodeSelected(_ id: UUID) -> Bool {
        self.selection.contains(id)
    }

    /// Selects a single node using the supplied mode.
    /// - Parameters:
    ///   - id: Node identifier to select.
    ///   - mode: Selection behavior (`replace` by default).
    public func select(node id: UUID, mode: SelectionMode = .replace) {
        self.select(nodes: [id], mode: mode)
    }

    /// Selects a collection of nodes using the supplied mode.
    /// Nodes that do not exist in the graph are ignored.
    /// - Parameters:
    ///   - ids: Node identifiers to select.
    ///   - mode: Selection behavior (`replace` by default).
    public func select<NodeIDs: Sequence>(nodes ids: NodeIDs, mode: SelectionMode = .replace)
    where NodeIDs.Element == UUID {
        let validNodes = Set(ids.filter { self.nodes[$0] != nil })

        switch mode {
        case .replace:
            self.selection = validNodes
        case .union:
            self.selection.formUnion(validNodes)
        }
    }

    /// Removes the supplied node from the selection (if present).
    /// - Parameter id: Node identifier to deselect.
    public func deselect(node id: UUID) {
        self.selection.remove(id)
    }

    /// Removes a collection of nodes from the selection, ignoring nodes that do not exist.
    /// - Parameter ids: Node identifiers to deselect.
    public func deselect<NodeIDs: Sequence>(nodes ids: NodeIDs) where NodeIDs.Element == UUID {
        let validNodes = ids.filter { self.nodes[$0] != nil }
        self.selection.subtract(validNodes)
    }

    /// Selects all known nodes.
    public func selectAll() {
        self.selection = Set(self.nodes.keys)
    }

    /// Clears the current selection.
    public func selectNone() {
        self.selection.removeAll()
    }

    /// Captures the current selection so that live selection updates can be previewed and cancelled.
    /// Call `updateLiveSelection(nodes:mode:)` to preview changes followed by either
    /// `endLiveSelection()` to commit or `cancelLiveSelection()` to roll back.
    public func beginLiveSelection() {
        self.liveSelectionSnapshot = self.selection
    }

    /// Updates the selection while a live-selection gesture is active.
    /// - Parameters:
    ///   - ids: Node identifiers currently inside the drag rectangle.
    ///   - mode: Selection behavior to apply for this update.
    public func updateLiveSelection<NodeIDs: Sequence>(nodes ids: NodeIDs, mode: SelectionMode)
    where NodeIDs.Element == UUID {
        let validNodes = Set(ids.filter { self.nodes[$0] != nil })

        guard let snapshot = self.liveSelectionSnapshot else {
            self.select(nodes: validNodes, mode: mode)
            return
        }

        switch mode {
        case .replace:
            self.selection = validNodes
        case .union:
            self.selection = snapshot.union(validNodes)
        }
    }

    /// Commits the current live-selection preview and clears the snapshot.
    public func endLiveSelection() {
        self.liveSelectionSnapshot = nil
    }

    /// Restores the selection snapshot captured at the start of a live-selection gesture.
    public func cancelLiveSelection() {
        if let snapshot = self.liveSelectionSnapshot {
            self.selection = snapshot
        }
        self.liveSelectionSnapshot = nil
    }
}

// MARK: - Errors and Result Types

extension Flow {

    /// Errors thrown by the flow graph operations.
    public enum FlowError: Error {
        case addingNodeWithConnectedPorts
        case removedNodeWithConnectedPorts
        case removedNodeWithExistingEdges
        case nodeNotFound
        case repeatedNodeId
        case edgeAlreadyExists
        case edgeNotFound
        case edgeCausesCycle
        case missingEdgeSourceNode
        case missingEdgeDestinationNode
        case portAlreadyDisconnected
        case edgeSourcePortNotConnected
        case edgeDestinationPortNotConnected
        case edgeDestinationPortAlreadyConnected
        case edgeInvalidDestPort
        case edgeInvalidSourcePort
        case edgeTypeError(CanAddEdgeResult.TypeMismatch)
        case failedToConvertNode(from: NodeKind, to: NodeKind)
    }

    /// Errors thrown while attempting to disconnect an edge from its ports.
    public enum DeleteEdgeDisconnectingNodesError: Error {
        case missingSourceNode
        case missingDestinationNode
    }

    /// Snapshot describing the node and edges removed by `deleteNodeRemovingEdges`.
    public struct DeleteNodeRemovingEdgesResult {
        /// Node that was removed from the flow.
        var node: FlowNode
        /// Position the node occupied before removal.
        var position: CGPoint
        /// Edges that were connected to the node at removal time.
        var edges: [Edge]
    }

    public enum AddEdgeReplaceNode: Equatable {
        case none
        case source(FlowNode)
        case dest(FlowNode)
    }
}
