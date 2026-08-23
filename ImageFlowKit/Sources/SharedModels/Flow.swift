import Backend
import Combine
import CoreGraphics
import Foundation
import Helpers
import OSLog
import Values

let signposter = OSSignposter(subsystem: "com.dmbfm.imageflow", category: .pointsOfInterest)
let logger = Logger(subsystem: "com.dmbfm.imageflow", category: "shared-models")

public enum FlowEvent {
    case partialEdgeDidChange(PartialEdge?)
    case nodesDidChange([UUID: FlowNode])
    case edgesDidChange(Set<Edge>)
    case nodePositionsDidChange([UUID: CGPoint])
    case selectionDidChange(Set<UUID>, liveSelect: Bool)
    case liveMoveNodesSnapshotDidChange
    case didEndPortDragWithoutCreatingEdge(
        typedPortLocation: TypedPortLocation,
        canvasPosition: CGPoint?,
        travelDistance: CGFloat
    )
    case didDeleteNode(UUID)
    case didDeleteEdge(Edge)
}

public protocol FlowDelegate: AnyObject {
    func flow(nodesDidChange nodes: [UUID: FlowNode])
    func flow(edgesDidChange edges: Set<Edge>)
    func flow(nodePositionsDidChange nodePositions: [UUID: CGPoint])
}

/// Observable model backing the node-based flow editor, responsible for nodes,
/// edges, selection state, and related graph validation utilities.
@MainActor
public final class Flow {
    /// All nodes keyed by identifier.
    public var nodes: [UUID: FlowNode] {
        didSet {
            self.delegate?.flow(nodesDidChange: self.nodes)
            self.emitter.emit(.nodesDidChange(self.nodes))
            self.nodesDidChangePublisher.send(())
            if self.nodeCount != self.nodes.count {
                self.nodeCount = self.nodes.count
            }
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
            if self.selection != oldValue {
                self.emitter.emit(.selectionDidChange(self.selection, liveSelect: self.liveSelectSnapshot != nil))
                self.selectionCount = self.selection.count
                self.selectionDidChangePublisher.send(self.selection)
            }
        }
    }
    /// All edges currently present in the graph.
    public var edges: Set<Edge> {
        didSet {
            self.delegate?.flow(edgesDidChange: self.edges)
            self.emitter.emit(.edgesDidChange(self.edges))
            self.edgesDidChangePublisher.send(())
            if self.edgeCount != self.edges.count {
                self.edgeCount = self.edges.count
            }
        }
    }

    @PublishedEx public var nodeCount: Int
    @PublishedEx public var edgeCount: Int

    public var selectionCount: Int

    public var partialEdge: PartialEdge? = nil {
        didSet {
            if self.partialEdge != oldValue {
                self.emitter.emit(.partialEdgeDidChange(self.partialEdge))
            }
        }
    }

    public weak var delegate: FlowDelegate? = nil

    public var emitter: EventEmitter<FlowEvent> = .init()

    public var liveMoveNodesSnapshot: [UUID: CGPoint]? = nil {
        didSet {
            self.emitter.emit(.liveMoveNodesSnapshotDidChange)
        }
    }

    public var nodesDidChangePublisher: PassthroughSubject<(), Never> = .init()
    public var edgesDidChangePublisher: PassthroughSubject<(), Never> = .init()
    public var selectionDidChangePublisher: CurrentValueSubject<Set<UUID>, Never>

    var portDraggingState: PortDraggingState = .idle

    var liveSelectSnapshot: Set<UUID>? = nil

    let duplicateOrPasteOffset: CGPoint = .init(x: 100, y: 100)

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
        self.nodeCount = nodes.count
        self.edgeCount = edges.count
        self.selectionCount = selection.count
        self.selectionDidChangePublisher = .init(selection)
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
        self.nodeCount = nodes.count
        self.edgeCount = edges.count
        self.selectionCount = selection.count
        self.selectionDidChangePublisher = .init(selection)
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

    public func edges(ofPort port: PortLocation) -> [Edge] {
        self.edges.filter({ edge in edge.from == port.outputPortLocation || edge.to == port.inputPortLocation })
    }

    public func edge(incoming port: InputPortLocation) -> Edge? {
        self.edges.first(where: { $0.to == port })
    }

    func numberOfEdges(ofPort port: PortLocation) -> Int {
        self.edges.count(where: { edge in edge.from == port.outputPortLocation || edge.to == port.inputPortLocation })
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
    public func addNode(_ node: FlowNode, at position: CGPoint) -> UUID? {
        if !self.hasNode(node.id) {
            self.nodes[node.id] = node
            self.nodePositions[node.id] = position
            return node.id
        } else {
            return nil
        }
    }

    @discardableResult
    public func removeNode(_ id: UUID) -> (FlowNode, CGPoint)? {
        let node = self.nodes.removeValue(forKey: id)
        let pos = self.nodePositions.removeValue(forKey: id)

        assert(node != nil && pos != nil || node == nil && pos == nil)

        switch (node, pos) {
        case let (.some(node), .some(pos)): return (node, pos)
        case (.some(_), .none), (.none, .some(_)):
            logger.error("Broken invariant: node = \("\(node, default: "nil"))"), pos = \("\(pos, default: "nil"))")")
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
        undoService: UndoService? = nil
    ) -> FlowNode? {
        guard var node = self.nodes[id], let pos = self.nodePositions[id] else { return nil }

        let id = UUID()
        node.id = id

        for i in node.inputs.indices { node.inputs[i].connected = false }
        for i in node.outputs.indices { node.outputs[i].connected = false }

        self.addNode(node, at: pos + self.duplicateOrPasteOffset, undoService: undoService)

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
        if let edge = self.edges.remove(edge) {
            self.emitter.emit(.didDeleteEdge(edge))
            return edge
        }

        return nil
    }
}

// MARK: - Nodes, Ports and Edges - Atomic Operations (Undo)

extension Flow {
    @discardableResult
    func addNode(_ node: FlowNode, at position: CGPoint, undoService: UndoService?) -> Bool {
        if self.addNode(node, at: position) != nil {
            undoService?.register(
                withTarget: self,
                title: nil,
                icon: nil,
                handler: { [weak undoService] this in
                    this.removeNode(node.id, undoService: undoService)
                }
            )
            return true
        }

        return false
    }

    @discardableResult
    func removeNode(_ id: UUID, undoService: UndoService?) -> (FlowNode, CGPoint)? {
        guard let (previousNode, previousPos) = self.removeNode(id) else {
            return nil
        }

        undoService?.register(
            withTarget: self,
            title: nil,
            icon: nil,
            handler: { [weak undoService] this in
                this.addNode(previousNode, at: previousPos, undoService: undoService)
            }
        )

        self.selection.remove(id)

        self.emitter.emit(.didDeleteNode(id))

        return (previousNode, previousPos)
    }

    @discardableResult
    func updateNode(_ node: FlowNode, undoService: UndoService?) -> FlowNode? {
        guard let previous = self.updateNode(node) else {
            return nil
        }

        undoService?.register(
            withTarget: self,
            title: nil,
            icon: nil,
            handler: { [weak undoService] _ in
                self.updateNode(previous, undoService: undoService)
            }
        )
        return previous
    }

    @discardableResult
    public func addEdge(_ edge: Edge, undoService: UndoService?) -> Bool {
        if self.addEdge(edge) {
            undoService?.register(
                withTarget: self,
                title: nil,
                icon: nil,
                handler: { [weak undoService] this in
                    this.removeEdge(edge, undoService: undoService)
                }
            )
            return true
        }

        return false
    }

    @discardableResult
    func removeEdge(_ edge: Edge, undoService: UndoService?) -> Edge? {
        if let edge = self.removeEdge(edge) {
            undoService?.register(
                withTarget: self,
                title: nil,
                icon: nil,
                handler: { [weak undoService] this in
                    this.addEdge(edge, undoService: undoService)
                }
            )
            return edge
        }

        return nil
    }
}

// MARK: - Nodes, Ports and Edges - Complex Actions

extension Flow {
    public func newNodeAction(kind: NodeKind, at position: CGPoint, undoService: UndoService?) {
        self.newNodeAction(.init(kind: kind), at: position, undoService: undoService)
    }

    public func newNodeAction(_ node: FlowNode, at position: CGPoint, undoService: UndoService?) {
        precondition(node.numConnectedSlots == 0, "Can't add a node connected node.")
        precondition(!self.hasNode(node.id), "A node with the same ID already exists.")
        let result = self.addNode(node, at: position, undoService: undoService)
        assert(result, "`addNode` unexpectedly failed.")
    }

    @discardableResult
    public func newNodeAction(
        kind: NodeKind,
        at position: CGPoint,
        connectingToExistingPort typedPortLocation: TypedPortLocation,
        undoService: UndoService?
    ) -> PortSlot? {
        self.newNodeAction(
            .init(kind: kind),
            at: position,
            connectingToExistingPort: typedPortLocation,
            undoService: undoService
        )
    }

    @discardableResult
    public func newNodeAction(
        _ node: FlowNode,
        at position: CGPoint,
        connectingToExistingPort typedPortLocation: TypedPortLocation,
        undoService: UndoService?
    ) -> PortSlot? {
        undoService?.beginUndoGrouping()

        self.newNodeAction(node, at: position, undoService: undoService)

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

        if let slot, case let .success(edge) = Edge.fromPorts(typedPortLocation.port, .init(node: node.id, port: slot))
        {
            self.newEdgeAction(edge, undoService: undoService)
        }

        undoService?.endUndoGrouping()

        return slot
    }

    private func withNodes(_ nodes: Set<UUID>, undoService: UndoService?, perform action: (UUID, UndoService?) -> ()) {
        if nodes.isEmpty { return }

        undoService?.beginUndoGrouping()
        for id in nodes {
            action(id, undoService)
        }
        undoService?.endUndoGrouping()
    }

    public func deleteSelectedNodesAction(undoService: UndoService?) {
        self.deleteNodesAction(self.selection, undoService: undoService)
    }

    public func deleteNodesAction(_ nodes: Set<UUID>, undoService: UndoService?) {
        self.withNodes(nodes, undoService: undoService) { id, um in
            self.deleteNodeAction(id, undoService: undoService)
        }
    }

    public func duplidateSelectedNodesAction(undoService: UndoService?) {
        guard let data = self.pasteboardData(forNodes: self.selection) else {
            return
        }

        guard let center = Array(data.nodePositions.values).centerPoint else { return }
        let newCenter = center + self.duplicateOrPasteOffset

        self.paste(
            pasteboardData: data,
            at: newCenter,
            undoService: undoService
        )
    }

    public func deleteNodeAction(_ id: UUID, undoService: UndoService?, undoTitle: String? = nil) {
        precondition(self.hasNode(id), "Can't delete a non-existing node.")

        undoService?.beginUndoGrouping()

        for edge in self.edges(ofNode: id) {
            self.deleteEdgeAction(edge, undoService: undoService)
        }

        self.removeNode(id, undoService: undoService)

        undoService?.endUndoGrouping()
    }

    public func convertNodeAction(_ id: UUID, kind: NodeKind, undoService: UndoService?) {
        guard let node = self.nodes[id] else { return }
        if self.nodes[id]?.convert(toVariation: kind) == true {
            undoService?.register(
                withTarget: self,
                title: nil,
                icon: nil,
                handler: { [weak undoService] this in
                    this.convertNodeAction(node.id, kind: node.kind, undoService: undoService)
                }
            )
        }
    }

    public func deleteEdgeAction(_ edge: Edge, undoService: UndoService?) {
        precondition(self.edges.contains(edge))

        undoService?.beginUndoGrouping()

        self.removeEdge(edge, undoService: undoService)

        self.setNodePortConnected(edge.toPort, false, undoService: undoService)

        if self.numberOfEdges(ofPort: edge.fromPort) == 0 {
            self.setNodePortConnected(edge.fromPort, false, undoService: undoService)
        }

        if let node = self.nodes[edge.to.node] {
            if node[valueTypeAt: edge.toPort.slot] == .image {
                if case .nodeOutput = node[valueAt: edge.toPort.slot].image {
                    self.nodes[edge.to.node]![valueAt: edge.toPort.slot] = .image(nil)
                }
            }
        }

        undoService?.endUndoGrouping()
    }

    public func deleteEdge(connectedToInput port: InputPortLocation, undoService: UndoService?) {
        if let edge = self.edges(ofPort: .init(node: port.node, port: .input(port.index))).first {
            self.deleteEdgeAction(edge, undoService: undoService)
        }
    }

    public func newEdgeAction(_ edge: Edge, undoService: UndoService? = nil) {
        guard !self.edges.contains(edge) else {
            logger.warning("[Flow][newEdgeAction]: edge already exists: \("\(edge)")")
            return
        }

        undoService?.beginUndoGrouping()

        // If the port is already connected, we need to remove the old edge first
        // to replace it with a new one.
        if let edge = self.edge(incoming: edge.to) {
            self.deleteEdgeAction(edge, undoService: undoService)
        }

        self.addEdge(edge, undoService: undoService)
        self.setNodePortConnected(edge.fromPort, true, undoService: undoService)
        self.setNodePortConnected(edge.toPort, true, undoService: undoService)

        undoService?.endUndoGrouping()
    }

    func newEdgeWithTypeErrorFixAction(_ edge: Edge, _ fix: TypeError.Fix, undoService: UndoService?) {
        undoService?.beginUndoGrouping()
        defer { undoService?.endUndoGrouping() }

        if let ((portToFix, kind)) =
            switch fix {
            case .canFixConvertingDestNodeTo(let kind):
                (edge.toPort, kind)
            case .canFixConvertingSourceNodeTo(let kind):
                (edge.fromPort, kind)
            }
        {
            let converted = self.nodes[portToFix.node]!.convert(toVariation: kind)
            precondition(converted)
        }

        self.newEdgeAction(edge, undoService: undoService)
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

        let sourceType = self.getPortType(edge.fromPort)
        let destType = self.getPortType(edge.toPort)

        if sourceType == destType {
            return .success(())
        }

        if let kind = self.nodes[edge.from.node]!.variation(soThatSlot: edge.fromPort.slot, hasType: destType) {
            return .failure(.fixable(.canFixConvertingSourceNodeTo(kind)))
        }

        if let kind = self.nodes[edge.to.node]!.variation(soThatSlot: edge.toPort.slot, hasType: sourceType) {
            return .failure(.fixable(.canFixConvertingDestNodeTo(kind)))
        }

        if sourceType.castable(to: destType) {
            return .success(())
        }

        return .failure(.cantFix(from: sourceType, to: destType))
    }

    public func canCreateEdge(from: PortLocation, to: PortLocation) -> Result<Edge, CanCreateEdgeError> {
        fatalError("TODO")
    }

    public func canCreateEdge(_ edge: Edge) -> Result<(), CanCreateEdgeError> {
        if !self.isValidPort(edge.fromPort) {
            return .failure(.invalidPort(edge.fromPort))
        }

        if !self.isValidPort(edge.toPort) {
            return .failure(.invalidPort(edge.toPort))
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

    public enum CanCreateEdgeError: Error, Equatable {
        case edge(Edge.FromPortsError)
        case invalidPort(PortLocation)
        case destPortAlreadyConnected
        case graphCycle
        case typeError(TypeError)
    }

    public enum TypeError: Error, Equatable {
        case cantFix(from: ValueType, to: ValueType)
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

// MARK: - setNodeValue

extension Flow {
    public func restoreDefaultValue(
        id: UUID,
        index: Int,
        undoService: UndoService?,
    ) {
        guard let node = self.nodes[id], let defaultValue = node.defaultValue(forInput: index) else {
            return
        }
        self.setNodeValue(id: id, index: index, oldValue: nil, newValue: defaultValue, undoService: undoService)
    }

    public func setNodeValue(
        id: UUID,
        index: Int,
        oldValue: Value? = nil,
        newValue: Value,
        undoService: UndoService?,
    ) {
        guard let node = self.nodes[id] else {
            logger.error("Node not found: \(id)")
            return
        }

        guard node.inputs.indices.contains(index) else {
            logger.error("Node input index out of range: \(index)")
            return
        }

        let existingValue = node.inputs[index].value

        let oldValue = oldValue ?? existingValue

        self.nodes[id]?.inputs[index].value = newValue

        undoService?.register(
            withTarget: self,
            title: nil,
            icon: nil,
            handler: { [weak undoService] this in
                this.setNodeValue(
                    id: id,
                    index: index,
                    oldValue: newValue,
                    newValue: oldValue,
                    undoService: undoService,
                )
            }
        )
    }
}

// MARK: - Node Properties (Undo)

extension Flow {
    @discardableResult
    func setNodePortConnected(_ port: PortLocation, _ value: Bool, undoService: UndoService?) -> Bool? {
        guard let prev = self.setNodePortConnected(port, value) else {
            return nil
        }

        undoService?.register(
            withTarget: self,
            title: nil,
            icon: nil,
            handler: { [weak undoService] this in
                this.setNodePortConnected(port, prev, undoService: undoService)
            }
        )

        return prev
    }
}

// MARK: - Helpers

extension Backend.Edge {
    init(edge: Edge) {
        self.init(
            from: .init(node: edge.from.node, slot: edge.fromPort.slot.index),
            end: .init(node: edge.to.node, slot: edge.toPort.slot.index)
        )
    }
}
