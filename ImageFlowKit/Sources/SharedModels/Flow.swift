import Backend
import CoreGraphics
import Foundation
import Helpers
import Logging
import Values

public enum FlowEvent {
    case nodesDidChange([UUID: FlowNode])
    case edgesDidChange(Set<Edge>)
    case nodePositionsDidChange([UUID: CGPoint])
    case selectionDidChange(Set<UUID>)
    case didEndPortDragWithoutCreatingEdge(
        typedPortLocation: TypedPortLocation,
        canvasPosition: CGPoint?,
        travelDistance: CGFloat
    )
    case didDeleteNode(UUID)
}

public protocol FlowDelegate: AnyObject {
    func flow(nodesDidChange nodes: [UUID: FlowNode])
    func flow(edgesDidChange edges: Set<Edge>)
    func flow(nodePositionsDidChange nodePositions: [UUID: CGPoint])
}

/// Observable model backing the node-based flow editor, responsible for nodes,
/// edges, selection state, and related graph validation utilities.
@Observable
@MainActor
public final class Flow: ObservableObject {
    /// All nodes keyed by identifier.
    public var nodes: [UUID: FlowNode] {
        didSet {
            self.delegate?.flow(nodesDidChange: self.nodes)
            self.emitter.emit(.nodesDidChange(self.nodes))
        }
    }
    /// The positions of the nodes.
    public var nodePositions: [UUID: CGPoint] {
        didSet {
            self.delegate?.flow(nodePositionsDidChange: self.nodePositions)
            self.emitter.emit(.nodePositionsDidChange(self.nodePositions))
        }
    }
    /// The set of node identifiers that are currently selected.
    public var selection: Set<UUID> {
        didSet {
            self.emitter.emit(.selectionDidChange(self.selection))
        }
    }
    /// All edges currently present in the graph.
    public var edges: Set<Edge> {
        didSet {
            self.delegate?.flow(edgesDidChange: self.edges)
            self.emitter.emit(.edgesDidChange(self.edges))
        }
    }

    public var partialEdge: PartialEdge? = nil

    public weak var delegate: FlowDelegate? = nil

    public var emitter: EventEmitter<FlowEvent> = .init()

    public var liveMoveNodesSnapshot: [UUID: CGPoint]? = nil

    @ObservationIgnored
    var portDraggingState: PortDraggingState = .idle

    var liveSelectSnapshot: Set<UUID>? = nil

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

    /// Creates a new flow model.
    /// - Parameters:
    ///   - nodes: Initial node map.
    ///   - nodePositions: Initial positions keyed by node identifier.
    ///   - selection: Initial selection set.
    ///   - edges: Initial edge set.
    public init(
        nodes: [UUID: (FlowNode, CGPoint)] = [:],
        selection: Set<UUID> = [],
        edges: Set<Edge> = []
    ) {
        self.nodes = nodes.mapValues({ $0.0 })
        self.nodePositions = nodes.mapValues({ $0.1 })
        self.selection = selection
        self.edges = edges
    }

    convenience public init() {
        self.init(nodes: [:])
    }
}

// MARK: - Nodes, Ports and Edges - Querying

extension Flow {
    func hasNode(_ id: UUID) -> Bool {
        self.nodes[id] != nil
    }

    func edges(ofNode id: UUID) -> [Edge] {
        self.edges.filter({ edge in edge.from.node == id || edge.to.node == id })
    }

    func numberOfEdges(ofNode id: UUID) -> Int {
        self.edges.count(where: { edge in edge.from.node == id || edge.to.node == id })
    }

    func edges(ofPort port: PortLocation) -> [Edge] {
        self.edges.filter({ edge in edge.from == port || edge.to == port })
    }

    func numberOfEdges(ofPort port: PortLocation) -> Int {
        self.edges.count(where: { edge in edge.from == port || edge.to == port })
    }

    func isValidPort(_ port: PortLocation) -> Bool {
        return self.hasNode(port.node) && self.nodes[port.node]!.isValidPortSlot(port.slot)
    }
}

// MARK: - Nodes, Ports and Edges - Atomic Operations

extension Flow {
    /// Adds the given `node` to the flow graph.
    /// - Parameter node: The node to add.
    /// - Returns: `true` if the node was added; `false` if there was another node
    /// with the same `id`, in which case nothing is done.
    @discardableResult
    func addNode(_ node: FlowNode, at position: CGPoint) -> Bool {
        if !self.hasNode(node.id) {
            self.nodes[node.id] = node
            self.nodePositions[node.id] = position
            return true
        } else {
            return false
        }
    }

    @discardableResult
    func removeNode(_ id: UUID) -> (FlowNode, CGPoint)? {
        let node = self.nodes.removeValue(forKey: id)
        let pos = self.nodePositions.removeValue(forKey: id)

        assert(node != nil && pos != nil || node == nil && pos == nil)

        switch (node, pos) {
        case let (.some(node), .some(pos)): return (node, pos)
        case (.some(_), .none), (.none, .some(_)):
            log("Broken invariant: node = \(node, default: "nil"), pos = \(pos, default: "nil")", level: .error)
            return nil
        default: return nil
        }
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
    public func duplicateNode(
        _ id: UUID,
        offset: CGPoint = .init(x: 50, y: 50),
        undoManager um: UndoManager? = nil
    ) -> FlowNode? {
        guard var node = self.nodes[id], let pos = self.nodePositions[id] else { return nil }

        let id = UUID()
        node.id = id

        for i in node.inputs.indices { node.inputs[i].connected = false }
        for i in node.outputs.indices { node.outputs[i].connected = false }

        self.addNode(node, at: pos + offset, undoManager: um)
        um?.setActionName("Duplicate Node")

        return node
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
    func removeEdge(_ edge: Edge) -> Edge? {
        self.edges.remove(edge)
    }
}

// MARK: - Nodes, Ports and Edges - Atomic Operations (Undo)

extension Flow {
    @discardableResult
    func addNode(_ node: FlowNode, at position: CGPoint, undoManager um: UndoManager?) -> Bool {
        if self.addNode(node, at: position) {
            um?.registerUndo(
                withTarget: self,
                handler: { [weak um] this in
                    this.removeNode(node.id, undoManager: um)
                }
            )
            um?.setActionName("Create Node")
            return true
        }

        return false
    }

    @discardableResult
    func removeNode(_ id: UUID, undoManager um: UndoManager?) -> (FlowNode, CGPoint)? {
        guard let (previousNode, previousPos) = self.removeNode(id) else {
            return nil
        }

        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.addNode(previousNode, at: previousPos, undoManager: um)
            }
        )

        self.selection.remove(id)

        self.emitter.emit(.didDeleteNode(id))

        return (previousNode, previousPos)
    }

    @discardableResult
    func updateNode(_ node: FlowNode, undoManager um: UndoManager?) -> FlowNode? {
        guard let previous = self.updateNode(node) else {
            return nil
        }

        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] _ in
                self.updateNode(previous, undoManager: um)
            }
        )
        return previous
    }

    @discardableResult
    public func addEdge(_ edge: Edge, undoManager um: UndoManager?) -> Bool {
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
    func removeEdge(_ edge: Edge, undoManager um: UndoManager?) -> Edge? {
        if let edge = self.removeEdge(edge) {
            um?.registerUndo(
                withTarget: self,
                handler: { [weak um] this in
                    this.addEdge(edge, undoManager: um)
                }
            )
            return edge
        }

        return nil
    }
}

// MARK: - Nodes, Ports and Edges - Complex Actions

extension Flow {
    public func newNodeAction(kind: NodeKind, at position: CGPoint, undoManager um: UndoManager?) {
        self.newNodeAction(.init(kind: kind), at: position, undoManager: um)
    }

    public func newNodeAction(_ node: FlowNode, at position: CGPoint, undoManager um: UndoManager?) {
        precondition(node.numConnectedSlots == 0, "Can't add a node connected node.")
        precondition(!self.hasNode(node.id), "A node with the same ID already exists.")
        let result = self.addNode(node, at: position, undoManager: um)
        assert(result, "`addNode` unexpectedly failed.")
    }

    @discardableResult
    public func newNodeAction(
        kind: NodeKind,
        at position: CGPoint,
        connectingToExistingPort typedPortLocation: TypedPortLocation,
        undoManager um: UndoManager?
    ) -> PortSlot? {
        self.newNodeAction(
            .init(kind: kind),
            at: position,
            connectingToExistingPort: typedPortLocation,
            undoManager: um
        )
    }

    @discardableResult
    public func newNodeAction(
        _ node: FlowNode,
        at position: CGPoint,
        connectingToExistingPort typedPortLocation: TypedPortLocation,
        undoManager um: UndoManager?
    ) -> PortSlot? {
        um?.beginUndoGrouping()

        self.newNodeAction(node, at: position, undoManager: um)

        let schema = node.kind.schema

        var slot: PortSlot?
        switch typedPortLocation.direction {
        case .input:
            if let idx = schema.outputs.firstIndex(where: { $0.type == typedPortLocation.type }) {
                slot = .output(idx)
            }
        case .output:
            if let idx = schema.inputs.firstIndex(where: { $0.type == typedPortLocation.type }) {
                slot = .input(idx)
            }
        }

        if let slot, let edge = Edge(typedPortLocation.port, .init(node: node.id, port: slot)) {
            self.newEdgeAction(edge, undoManager: um)
        }

        um?.endUndoGrouping()
        um?.setActionName("Create Node")

        return slot
    }

    private func withSelectedNodes(_ um: UndoManager?, perform: (UUID, UndoManager?) -> ()) {
        um?.beginUndoGrouping()
        for id in self.selection {
            perform(id, um)
        }
        um?.endUndoGrouping()
    }

    public func deleteSelectedNodesAction(undoManager um: UndoManager?) {
        let actionName = "Delete Node" + (self.selection.count > 1 ? "s" : "")
        self.withSelectedNodes(um) { id, um in
            self.deleteNodeAction(id, undoManager: um)
            um?.setActionName(actionName)
        }
    }

    public func duplidateSelectedNodesAction(undoManager um: UndoManager?) {
        var newSelection: Set<UUID> = []
        self.withSelectedNodes(um) { id, um in
            if let id = self.duplicateNode(id, undoManager: um)?.id {
                newSelection.insert(id)
            }
        }
        um?.setActionName("Duplicate Node" + (self.selection.count > 1 ? "s" : ""))
        self.select(newSelection)
    }

    public func deleteNodeAction(_ id: UUID, undoManager um: UndoManager?) {
        precondition(self.hasNode(id), "Can't delete a non-existing node.")

        um?.beginUndoGrouping()

        for edge in self.edges(ofNode: id) {
            self.deleteEdgeAction(edge, undoManager: um)
        }

        self.removeNode(id, undoManager: um)

        um?.endUndoGrouping()
        um?.setActionName("Delete Node")
    }

    func deleteEdgeAction(_ edge: Edge, undoManager um: UndoManager?) {
        precondition(self.edges.contains(edge))
        precondition(self.isValidPort(edge.from))
        precondition(self.isValidPort(edge.to))

        um?.beginUndoGrouping()

        self.removeEdge(edge, undoManager: um)

        self.setNodePortConnected(edge.to, false, undoManager: um)

        if self.numberOfEdges(ofPort: edge.from) == 0 {
            self.setNodePortConnected(edge.from, false, undoManager: um)
        }

        if let node = self.nodes[edge.to.node] {
            if node[valueTypeAt: edge.to.slot] == .image {
                if case .nodeOutput = node[valueAt: edge.to.slot].image {
                    self.nodes[edge.to.node]![valueAt: edge.to.slot] = .image(nil)
                }
            }
        }

        um?.endUndoGrouping()
        um?.setActionName("Delete Edge")
    }

    public func newEdgeAction(_ edge: Edge, undoManager um: UndoManager? = nil) {
        precondition(self.isValidPort(edge.from))
        precondition(self.isValidPort(edge.to))

        um?.beginUndoGrouping()

        self.addEdge(edge, undoManager: um)
        self.setNodePortConnected(edge.from, true, undoManager: um)
        self.setNodePortConnected(edge.to, true, undoManager: um)

        um?.endUndoGrouping()
        um?.setActionName("Create Edge")
    }

    func newEdgeWithTypeErrorFixAction(_ edge: Edge, _ fix: TypeError.Fix, undoManager um: UndoManager?) {
        precondition(self.isValidPort(edge.from))
        precondition(self.isValidPort(edge.to))

        um?.beginUndoGrouping()
        defer { um?.endUndoGrouping() }

        if let ((portToFix, kind)) =
            switch fix {
            case .canFixConvertingDestNodeTo(let kind):
                (edge.to, kind)
            case .canFixConvertingSourceNodeTo(let kind):
                (edge.from, kind)
            }
        {
            let converted = self.nodes[portToFix.node]!.convert(toVariation: kind)
            precondition(converted)
        }

        self.newEdgeAction(edge, undoManager: um)
    }
}

// MARK: - Nodes, Ports and Edges - Validation

extension Flow {

    public func validateNodeGraph() {
        fatalError("TODO: Implement this method")
    }

    public func hasCycles(addingEdge edge: Edge? = nil) -> Bool {
        let flow = FlowGraph(.init())
        for (node, _) in self.nodes {
            flow.addNode(node)
        }

        for edge in self.edges {
            flow.addEdge(.init(edge: edge))
        }

        if let edge {
            flow.addEdge(.init(edge: edge))
        }

        if flow.detectCycles() == .hasCycles {
            return true
        } else {
            return false
        }
    }

    public func typeCheckEdge(_ edge: Edge) -> Result<(), TypeError> {
        precondition(self.hasNode(edge.from.node))
        precondition(self.hasNode(edge.to.node))

        let sourceType = self.getPortType(edge.from)
        let destType = self.getPortType(edge.to)

        if sourceType == destType {
            return .success(())
        }

        if let kind = self.nodes[edge.to.node]!.variation(soThatSlot: edge.to.slot, hasType: sourceType) {
            return .failure(.fixable(.canFixConvertingDestNodeTo(kind)))
        }

        if let kind = self.nodes[edge.from.node]!.variation(soThatSlot: edge.from.slot, hasType: destType) {
            return .failure(.fixable(.canFixConvertingSourceNodeTo(kind)))
        }

        return .failure(.cantFix)
    }

    public func canCreateEdge(_ edge: Edge) -> Result<(), CanAddEdgeError> {
        if !self.isValidPort(edge.from) {
            return .failure(.invalidPort(edge.from))
        }

        if !self.isValidPort(edge.to) {
            return .failure(.invalidPort(edge.to))
        }

        if self.getPortConnected(edge.to) {
            return .failure(.destPortAlreadyConnected)
        }

        switch self.typeCheckEdge(edge) {
        case .success():
            break
        case .failure(let err):
            return .failure(.typeError(err))
        }

        if self.hasCycles(addingEdge: edge) {
            return .failure(.graphCycle)
        }

        return .success(())
    }

    public enum CanAddEdgeError: Error, Equatable {
        case invalidPort(PortLocation)
        case destPortAlreadyConnected
        case graphCycle
        case typeError(TypeError)
    }

    public enum TypeError: Error, Equatable {
        case cantFix
        case fixable(Fix)

        public enum Fix: Error, Equatable {
            case canFixConvertingSourceNodeTo(NodeKind)
            case canFixConvertingDestNodeTo(NodeKind)
        }
    }
}

// MARK: - Node Properties

extension Flow {
    func getPortConnected(_ port: PortLocation) -> Bool {
        self.nodes[port.node]![connectedAt: port.slot]
    }

    func getPortType(_ port: PortLocation) -> ValueType {
        self.nodes[port.node]![valueTypeAt: port.slot]
    }

    @discardableResult
    func setNodePortConnected(_ port: PortLocation, _ value: Bool) -> Bool? {
        precondition(self.hasNode(port.node))
        precondition(self.nodes[port.node]!.isValidPortSlot(port.slot))

        let prev = self.nodes[port.node]![connectedAt: port.slot]

        if prev != value {
            self.nodes[port.node]![connectedAt: port.slot] = value
            return prev
        }

        return nil
    }
}

// MARK: - Node Properties (Undo)

extension Flow {
    @discardableResult
    func setNodePortConnected(_ port: PortLocation, _ value: Bool, undoManager um: UndoManager?) -> Bool? {
        guard let prev = self.setNodePortConnected(port, value) else {
            return nil
        }

        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.setNodePortConnected(port, prev, undoManager: um)
            }
        )

        return prev
    }
}

// MARK: - Helpers

extension Backend.Edge {
    init(edge: Edge) {
        self.init(
            from: .init(node: edge.from.node, slot: edge.from.slot.index),
            end: .init(node: edge.to.node, slot: edge.to.slot.index)
        )
    }
}
