import Foundation
import Logging

@Observable
@MainActor
final class Flow {
    public var nodes: [UUID: FlowNode]
    public var nodePositions: [UUID: CGPoint]
    public var selection: Set<UUID>
    public var edges: Set<Edge>

    init(
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
    func edges(ofNode id: UUID) -> [Edge] {
        self.edges.filter({ edge in edge.from.node == id || edge.to.node == id })
    }

    // func edges(ofPort port: PortLocation) -> [Edge] {
    //     self.edges.filter({ edge in edge.from == port || edge.to == port })
    // }

    func numberOfEdges(ofPort port: PortLocation) -> Int {
        self.edges.count(where: { edge in edge.from == port || edge.to == port })
    }

    /// Adds a new `FlowNode` to the graph.
    ///
    /// This method does not validate port connections to see it they match with
    /// the current `edges` set, so care must be taken when using this so that we don't
    /// end up with a invalid state.
    ///
    /// - Parameters:
    ///   - node: The `FlowNode` model to add.
    ///   - position: The position to place it.
    ///
    /// - Throws: `RepeatedNodeIdError` if the node's ID is already used.
    func addNode(_ node: FlowNode, at position: CGPoint) throws(FlowError) {
        if self.nodes[node.id] != nil || self.nodePositions[node.id] != nil {
            throw .repeatedNodeId
        }

        self.nodes[node.id] = node
        self.nodePositions[node.id] = position
    }

    /// Deletes the node with the given `id` from the flow graph.
    ///
    /// This will just remove the data from `nodes` and `nodePositions`, without
    /// deleting any connected edges,so care must be taken when using this so that we
    /// don't end up with a invalid state.
    ///
    /// - Parameter id: The node's identifier.
    /// - Throws: `NodeNotFoundError` when the id is missing.
    /// - Returns: The `FlowNode` data and position for the removed node.
    @discardableResult
    func deleteNode(_ id: UUID) throws(FlowError) -> (FlowNode, CGPoint) {
        guard let node = self.nodes.removeValue(forKey: id), let pos = self.nodePositions.removeValue(forKey: id) else {
            throw .nodeNotFound
        }

        return (node, pos)
    }

    /// Adds a new `FlowNode` to the graph, registering an undo operation.
    ///
    /// This method does not validate port connections to see it they match with
    /// the current `edges` set, so care must be taken when using this so that we don't
    /// end up with a invalid state.
    ///
    /// - Parameters:
    ///   - node: The `FlowNode` model to add.
    ///   - position: The position to place it.
    ///   - undoMaeager: The (optional) `UndoManager` used for registering the undo operation.
    ///   - undoTitle: The title to use for the undo operation.
    ///
    /// - Throws: `RepeatedNodeIdError` if the node's ID is already used.
    func addNode(
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

    /// Deletes the node with the given `id` from the flow graph.
    ///
    /// This will just remove the data from `nodes` and `nodePositions`, without
    /// deleting any connected edges,so care must be taken when using this so that we
    /// don't end up with a invalid state.
    ///
    /// - Parameters
    ///   - id: The node's identifier.
    ///   - undoMaeager: The (optional) `UndoManager` used for registering the undo operation.
    ///   - undoTitle: The title to use for the undo operation.
    ///
    /// - Throws: `NodeNotFoundError` when the id is missing.
    /// - Returns: The `FlowNode` data and position for the removed node.
    func deleteNode(
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

    /// Adds the given `edge` to the flow graph's set of edges. Does not check
    /// if the corresponding node/ports exist of are connected nor connects the ports.
    ///
    /// - Parameter edge: The `Edge` to be added.
    /// - Throws: `EdgeAlreadyExistsError` if the edge is already present in the graph.
    func addEdge(_ edge: Edge) throws(FlowError) {
        if self.edges.contains(edge) {
            throw .edgeAlreadyExists
        }

        self.edges.insert(edge)
    }

    /// Removes the given `edge` from the flow graph's set of edges. Does not
    /// disconnect the ports of the nodes that are connected by the edge.
    ///
    /// - Parameter edge:
    /// - Throws:
    func deleteEdge(_ edge: Edge) throws(FlowError) {
        guard let _ = self.edges.remove(edge) else {
            throw .edgeNotFound
        }
    }

    /// Adds the given `edge` to the flow graph's set of edges. Does not check
    /// if the corresponding node/ports exist of are connected. When a `UndoManager`
    /// is provided, registers an undo operation.
    ///
    /// - Parameters:
    ///   - edge:
    ///   - um:
    ///   - undoTitle:
    ///
    /// - Throws:
    func addEdge(
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

    /// Removes the given `edge` from the flow graph's set of edges. Does not
    /// disconnect the ports of the nodes that are connected by the edge. When a `UndoManager`
    /// is provided, registers an undo operation.
    ///
    /// - Parameters:
    ///   - edge:
    ///   - um:
    ///   - undoTitle:
    ///
    /// - Throws:
    func deleteEdge(
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

    @discardableResult
    func setNodePortConnected(_ port: PortLocation, _ value: Bool) throws(FlowError) -> Bool {
        if self.nodes[port.node] == nil {
            throw .nodeNotFound
        }

        let prev = self.nodes[port.node]![connectedAt: port.slot]

        if prev != value {
            self.nodes[port.node]![connectedAt: port.slot] = value
        }

        return prev
    }

    @discardableResult
    func setNodePortConnected(
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

    func deleteEdgeDisconnectingNodes(_ edge: Edge) throws(FlowError) {
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

    func deleteEdgeDisconnectingNodes(_ edge: Edge, undoManager um: UndoManager?) throws(FlowError) {
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

    func addEdgeConnectingNodes(_ edge: Edge) throws(FlowError) {
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

    func addEdgeConnectingNodes(_ edge: Edge, undoManager um: UndoManager?) throws(FlowError) {
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

    func deleteNodeRemovingEdges(_ id: UUID) throws(FlowError) -> DeleteNodeRemovingEdgesResult {
        let edges = self.edges(ofNode: id)

        for edge in edges {
            try self.deleteEdgeDisconnectingNodes(edge)
        }

        let (node, pos) = try self.deleteNode(id)

        return .init(node: node, position: pos, edges: edges)
    }

    @discardableResult
    func deleteNodeRemovingEdges(
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

    func addNodeWithEdges(_ node: FlowNode, at position: CGPoint, withEdges edges: Set<Edge>) throws(FlowError) {
        try self.addNode(node, at: position)

        for edge in edges {
            try self.addEdgeConnectingNodes(edge)
        }
    }

    func addNodeWithEdges(
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

}

// MARK: - Errors and Result Types

extension Flow {

    public enum FlowError: Error {
        case nodeNotFound
        case repeatedNodeId
        case edgeAlreadyExists
        case edgeNotFound
        case missingEdgeSourceNode
        case missingEdgeDestinationNode
        case portAlreadyDisconnected
        case edgeSourcePortNotConnected
        case edgeDestinationPortNotConnected
        case edgeDestinationPortAlreadyConnected
    }

    public enum DeleteEdgeDisconnectingNodesError: Error {
        case missingSourceNode
        case missingDestinationNode
    }

    public struct DeleteNodeRemovingEdgesResult {
        var node: FlowNode
        var position: CGPoint
        var edges: [Edge]
    }
}
