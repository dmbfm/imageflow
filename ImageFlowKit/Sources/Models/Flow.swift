import Backend
import Foundation
import Logging

/// Observable model backing the node-based flow editor, responsible for nodes,
/// edges, selection state, and related graph validation utilities.
@Observable
@MainActor
public final class Flow {
    /// All nodes keyed by identifier.
    public var nodes: [UUID: FlowNode]
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
        selection: Set<UUID> = [],
        edges: Set<Edge> = []
    ) {
        self.nodes = nodes
        self.selection = selection
        self.edges = edges
    }
}

// MARK: - Nodes, Ports and Edges - Querying

extension Flow {
    func hasNode(_ id: UUID) -> Bool {
        self.nodes[id] != nil
    }
}

// MARK: - Nodes, Ports and Edges - Atomic Operations

extension Flow {
    @discardableResult
    func addNode(_ node: FlowNode) -> Bool {
        if !self.hasNode(node.id) {
            self.nodes[node.id] = node
            return true
        } else {
            return false
        }
    }

    @discardableResult
    func removeNode(_ id: UUID) -> FlowNode? {
        self.nodes.removeValue(forKey: id)
    }

    @discardableResult
    func updateNode(_ node: FlowNode) -> FlowNode? {
        guard let previous = self.nodes.removeValue(forKey: node.id) else {
            return nil
        }

        self.nodes[node.id] = node

        return previous
    }

    @discardableResult
    func addEdge(_ edge: Edge) -> Bool {
        if !self.edges.contains(edge) {
            self.edges.insert(edge)
            return true
        }

        return false
    }

    @discardableResult
    func removeEdge(_ edge: Edge) -> Bool {
        if self.edges.contains(edge) {
            self.edges.remove(edge)
            return true
        }

        return false
    }
}

// MARK: - Nodes, Ports and Edges - Atomic Operations (Undo)

extension Flow {
    func addNode(_ node: FlowNode, undoManager um: UndoManager?) {
        if self.addNode(node) {
            um?.registerUndo(
                withTarget: self,
                handler: { [weak um] this in
                    this.removeNode(node.id, undoManager: um)
                }
            )
        }
    }

    @discardableResult
    func removeNode(_ id: UUID, undoManager um: UndoManager?) -> FlowNode? {
        guard let previous = self.removeNode(id) else {
            return nil
        }

        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.addNode(previous, undoManager: um)
            }
        )

        return previous
    }

    @discardableResult
    func updateNode(_ node: FlowNode, undoManager um: UndoManager?) -> FlowNode? {
        guard let previous = self.updateNode(node) else {
            return nil
        }

        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                self.updateNode(previous, undoManager: um)
            }
        )
        return previous
    }

    @discardableResult
    func addEdge(_ edge: Edge, undoManager um: UndoManager?) -> Bool {
        if self.addEdge(edge) {
            um?.registerUndo(
                withTarget: self,
                handler: { [weak um] this in
                    this.removeEdge(edge, undoManager: um)
                }
            )
            return true
        }

        return false
    }

    @discardableResult
    func removeEdge(_ edge: Edge, undoManager um: UndoManager?) -> Bool {
        if self.removeEdge(edge) {
            um?.registerUndo(
                withTarget: self,
                handler: { [weak um] this in
                    this.addEdge(edge, undoManager: um)
                }
            )
            return true
        }

        return false
    }
}
