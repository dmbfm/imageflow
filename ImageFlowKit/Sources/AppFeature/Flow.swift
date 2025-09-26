import CanvasFeature
import CanvasView
import Foundation
import Models
import NodeDataStore
import NodeSelectionStore

import enum Models.Action

@MainActor
final class Flow {
    public var canvas: CanvasFeatureState = .init()
    public var nodeDataStore: NodeDataStore = .init()
    public var nodeSelectionStore: NodeSelectionStore = .init()

    public init(
        canvas: CanvasFeatureState = .init(),
        nodeDataStore: NodeDataStore = .init(),
        nodeSelectionStore: NodeSelectionStore = .init()
    ) {
        self.canvas = canvas
        self.nodeDataStore = nodeDataStore
        self.nodeSelectionStore = nodeSelectionStore
    }

    func dispatch(_ action: Action, canvasCenter: CGPoint, undoManager: UndoManager? = nil) {
        switch action {
        case .addNode(let data):
            let pos: CGPoint =
                switch data.position {
                case .center:
                    canvasCenter
                case .point(let point):
                    point
                }

            self.addNode(.init(kind: data.kind), at: pos)
        }
    }

    func addNode(_ node: FlowNode, at position: CGPoint) {
        self.nodeDataStore.createNode(node)
        try! self.canvas.addNode(node.id, at: position)
    }
}

extension Flow {
    static var sample: Flow {
        let flow = Flow()
        let ids: [UUID] = [.init(), .init(), .init()]
        flow.addNode(.init(id: ids[0], kind: .valueNode(.float)), at: .init(x: 200, y: 200))
        flow.addNode(.init(id: ids[1], kind: .valueNode(.float)), at: .init(x: 200, y: 400))
        flow.addNode(.init(id: ids[2], kind: .addNode(.float)), at: .init(x: 500, y: 300))
        _ = try! flow.nodeDataStore.createEdge(
            .init(.init(node: ids[0], port: .output(0)), .init(node: ids[2], port: .input(0)))!
        ).get()
        _ = try! flow.nodeDataStore.createEdge(
            .init(.init(node: ids[1], port: .output(0)), .init(node: ids[2], port: .input(1)))!
        ).get()
        assert(flow.nodeDataStore.validateEdges() == .ok)
        return flow
    }
}

extension Flow: Storable {
    public struct StorableData: Sendable, Codable {

        public var canvas: CanvasFeatureState.StorableData
        public var nodeDataStore: NodeDataStore.StorableData
        // public var nodeSelectionStore: NodeSelectionStore.StorableData

        public init() {
            self.canvas = .init()
            self.nodeDataStore = .init()
            // self.nodeSelectionStore = .init()
        }

        public init(
            canvas: CanvasFeatureState.StorableData,
            nodeDataStore: NodeDataStore.StorableData,
            // nodeSelectionStore: NodeSelectionStore.StorableData
        ) {
            self.canvas = canvas
            self.nodeDataStore = nodeDataStore
            // self.nodeSelectionStore = nodeSelectionStore
        }
    }

    public func snapshot() -> StorableData {
        .init(
            canvas: self.canvas.snapshot(),
            nodeDataStore: self.nodeDataStore.snapshot(),
        )
    }

    convenience init(_ data: StorableData) {
        self.init(
            canvas: .init(data.canvas),
            nodeDataStore: .init(data.nodeDataStore),
            // nodeSelectionStore: .init(data.nodeSelectionStore)
        )
    }

    func restore(_ snapshot: StorableData) {
        self.canvas.restore(snapshot.canvas)
        self.nodeDataStore.restore(snapshot.nodeDataStore)
        // self.nodeSelectionStore.restore(snapshot.nodeSelectionStore)
    }
}

// @Observable
// public class Flow: @unchecked Sendable {
//     public var nodes: [UUID: FlowNode]

//     public var edges: Set<Edge>

//     public var selection: Set<UUID>

//     public var nodePositions: [UUID: CGPoint]

//     public var viewport: CanvasViewport

//     public init(
//         nodes: [UUID: FlowNode] = [:],
//         nodePositions: [UUID: CGPoint] = [:],
//         edges: Set<Edge> = [],
//         selection: Set<UUID> = [],
//         viewport: CanvasViewport = .init()
//     ) {
//         self.nodes = nodes
//         self.nodePositions = nodePositions
//         self.edges = edges
//         self.selection = selection
//         self.viewport = viewport
//     }
// }

// extension Flow {
//     static var sample: Flow {
//         let ids: [UUID] = [.init(), .init(), .init()]
//         let flow = Flow()
//         Task { @MainActor in
//             flow._addNode(.init(id: ids[0], kind: .valueNode(.float)), .zero)
//             flow._addNode(.init(id: ids[1], kind: .valueNode(.float)), .init(x: 0, y: 200))
//             flow._addNode(.init(id: ids[2], kind: .addNode(.float)), .init(x: 200, y: 100))
//         }
//         return flow
//     }
// }

// // MARK: - Internal Node methods

// @MainActor
// extension Flow {

//     func _addNode(_ node: FlowNode, _ position: CGPoint = .zero, undoManager: UndoManager? = nil) {
//         if self.nodes[node.id] == nil {
//             assert(self.nodePositions[node.id] == nil)
//             self.nodes[node.id] = node
//             self.nodePositions[node.id] = position
//             undoManager?.registerUndo(
//                 withTarget: self,
//                 handler: { [weak undoManager] this in
//                     this._removeNode(id: node.id, undoManager: undoManager)
//                 }
//             )
//         }
//     }

//     func _removeNode(id: UUID, undoManager: UndoManager? = nil) {
//         if let node = self.nodes.removeValue(forKey: id) {
//             let pos = self.nodePositions.removeValue(forKey: id)!
//             undoManager?.registerUndo(
//                 withTarget: self,
//                 handler: { [weak undoManager] this in
//                     this._addNode(node, pos, undoManager: undoManager)
//                 }
//             )
//         }
//     }

//     func _addEdge(_ edge: Edge, undoManager: UndoManager? = nil) {
//         if self.edges.insert(edge).inserted {
//             undoManager?.registerUndo(
//                 withTarget: self,
//                 handler: { [weak undoManager] this in
//                     this._removeEdge(edge, undoManager: undoManager)
//                 }
//             )
//         }
//     }

//     func _removeEdge(_ edge: Edge, undoManager: UndoManager? = nil) {
//         if let removedEdge = self.edges.remove(edge) {
//             undoManager?.registerUndo(
//                 withTarget: self,
//                 handler: { [weak undoManager] this in
//                     this._addEdge(removedEdge, undoManager: undoManager)
//                 }
//             )
//         }
//     }
// }

// // MARK: - Selection Methods

// @MainActor
// extension Flow {

//     public func select(
//         _ nodes: Set<UUID>,
//         mode: SelectionMode,
//         undoManager: UndoManager? = nil,
//         undoTitle: String = "Selction"
//     ) {
//         switch mode {
//         case .replace:
//             self.setSelection(nodes, undoManager: undoManager, undoTitle: undoTitle)
//         case .union:
//             self.setSelection(nodes.union(self.selection), undoManager: undoManager, undoTitle: undoTitle)
//         }
//     }

//     public func setSelection(
//         _ nodes: Set<UUID>,
//         previous: Set<UUID>? = nil,
//         undoManager: UndoManager? = nil,
//         undoTitle: String = "Selection"
//     ) {
//         let prev = previous ?? self.selection
//         self.selection = nodes
//         if prev != nodes {
//             undoManager?.registerUndo(
//                 withTarget: self,
//                 handler: { [weak undoManager] this in
//                     this.setSelection(prev, previous: nodes, undoManager: undoManager)
//                 }
//             )
//         }
//         undoManager?.setActionName(undoTitle)
//     }

//     public func selectAll(undoManager: UndoManager? = nil, undoTitle: String = "Select All") {
//         self.setSelection(Set(self.nodes.keys), undoManager: undoManager, undoTitle: undoTitle)
//     }

//     public func deselectAll(undoManager: UndoManager? = nil, undoTitle: String = "Deselect App") {
//         self.setSelection([], undoManager: undoManager, undoTitle: undoTitle)
//     }

//     public func isSelected(_ node: UUID) -> Bool {
//         self.selection.contains(node)
//     }
// }

// // MARK: - Node Methods

// @MainActor
// extension Flow {
//     func setNodeProperty<V: Equatable>(
//         _ id: UUID,
//         _ kp: WritableKeyPath<FlowNode, V>,
//         value: V,
//         previous: V? = nil,
//         undoManager: UndoManager?,
//         undoTitle: String?
//     ) {
//         if self.nodes[id] != nil {
//             let prev = previous ?? self.nodes[id]![keyPath: kp]
//             if prev != value {
//                 self.nodes[id]![keyPath: kp] = value
//                 undoManager?.registerUndo(
//                     withTarget: self,
//                     handler: { [weak undoManager] this in
//                         this.setNodeProperty(
//                             id,
//                             kp,
//                             value: prev,
//                             previous: value,
//                             undoManager: undoManager,
//                             undoTitle: undoTitle
//                         )
//                     }
//                 )
//                 if let undoTitle {
//                     undoManager?.setActionName(undoTitle)
//                 }
//             }
//         }
//     }

//     public func mapNodeProperty<V: Equatable>(
//         _ id: UUID,
//         _ kp: WritableKeyPath<FlowNode, V>,
//         f: (V) -> V,
//         undoManager: UndoManager?,
//         undoTitle: String?
//     ) {
//         self.setNodeProperty(
//             id,
//             kp,
//             value: f(self.nodes[id]![keyPath: kp]),
//             undoManager: undoManager,
//             undoTitle: undoTitle
//         )
//     }

//     public func nodePortConnected(_ port: PortLocation) -> Bool? {
//         self.nodes[port.node]?[connectedAt: port.slot]
//     }

//     private func setNodePortConnected(_ port: PortLocation, value: Bool, undoManager: UndoManager? = nil) {
//         if self.nodes[port.node] == nil {
//             return
//         }

//         let prev = self.nodePortConnected(port)!
//         if prev != value {
//             self.nodes[port.node]![connectedAt: port.slot] = value
//             undoManager?.registerUndo(
//                 withTarget: self,
//                 handler: { [weak undoManager] this in
//                     this.setNodePortConnected(port, value: prev, undoManager: undoManager)
//                 }
//             )
//         }
//     }

//     public func moveNode(
//         _ node: UUID,
//         to position: CGPoint,
//         previous: CGPoint? = nil,
//         undoManager: UndoManager? = nil,
//         undoTitle: String = "Move Node"
//     ) {
//         let prev = previous ?? self.nodePositions[node]!
//         if prev != position {
//             self.nodePositions[node] = position
//             undoManager?.registerUndo(
//                 withTarget: self,
//                 handler: { [weak undoManager] this in
//                     this.moveNode(
//                         node,
//                         to: prev,
//                         previous: position,
//                         undoManager: undoManager,
//                         undoTitle: undoTitle
//                     )
//                 }
//             )
//             undoManager?.setActionName(undoTitle)
//         }
//     }

//     public func setNodePositions(
//         _ nodePositions: [UUID: CGPoint],
//         previous: [UUID: CGPoint]? = nil,
//         undoManager: UndoManager? = nil,
//         undoTitle: String = "Mode Node"
//     ) {
//         let prev = previous ?? self.nodePositions
//         self.nodePositions = nodePositions
//         undoManager?.registerUndo(
//             withTarget: self,
//             handler: { [weak undoManager] this in
//                 this.setNodePositions(
//                     prev,
//                     previous: nodePositions,
//                     undoManager: undoManager,
//                     undoTitle: undoTitle
//                 )
//             }
//         )
//     }

//     public func mapNodePosition(
//         _ id: UUID,
//         f: (CGPoint) -> CGPoint,
//         undoManager: UndoManager?,
//         undoTitle: String = "Move Node"
//     ) {
//         if let prev = self.nodePositions[id] {
//             self.moveNode(id, to: f(prev), undoManager: undoManager, undoTitle: undoTitle)
//         }
//     }
// }

// // MARK: - Edge Management Methods
// @MainActor
// extension Flow {
//     /// Returns all the edges that start at the given location.
//     ///
//     /// - Parameter from: The source location.
//     /// - Returns: The list of edges.
//     public func edges(from: PortLocation) -> [Edge] {
//         self.edges.filter { $0.from == from }
//     }

//     /// Returns all the edges that end at the given location.
//     ///
//     /// - Parameter to: The destination location.
//     /// - Returns: The list of edges.
//     public func edges(to: PortLocation) -> [Edge] {
//         self.edges.filter { $0.to == to }
//     }

//     /// Returns all of the edges that either start or end
//     /// in the node with the given id.
//     ///
//     /// - Parameter node: The `FlowNode`.
//     /// - Returns: The list of edges.
//     public func edges(ofNode node: UUID) -> [Edge] {
//         self.edges.filter { e in
//             e.from.node == node || e.to.node == node
//         }
//     }

//     /// Adds an edge between two node slots to the store. A number of checks are
//     /// made to see if the edge is valid before inserting.
//     ///
//     /// - Parameter edge: The edge to be added.
//     /// - Returns: The added edge (same as the input) or an `AddEdgeError` value.
//     public func addEdge(_ edge: Edge, undoManager: UndoManager? = nil) -> Result<Edge, AddEdgeError> {

//         if case let .failure(reason) = self.canAddEdge(edge) {
//             return .failure(reason)
//         }

//         undoManager?.beginUndoGrouping()

//         // Set the slots as connected
//         self.setNodePortConnected(edge.from, value: true, undoManager: undoManager)
//         self.setNodePortConnected(edge.to, value: true, undoManager: undoManager)

//         // Add the edge to the set
//         // self.edges.insert(edge)
//         self._addEdge(edge, undoManager: undoManager)

//         undoManager?.endUndoGrouping()
//         undoManager?.setActionName("Add Edge")

//         // Make sure we are in a valid state
//         if self.validateEdges() != .ok {
//             return .failure(.invalidEdgesState)
//         }

//         return .success(edge)
//     }

//     public enum AddEdgeError: Error, Equatable {
//         case invalidEdge
//         case duplicatedEdge
//         case typeMismatch(source: ValueType, dest: ValueType)
//         case missingNode(UUID)
//         case invalidSourceSlot(PortSlot)
//         case invalidDestinationSlot(PortSlot)
//         case destinationAlreadyConnected(PortLocation)
//         case invalidEdgesState
//     }

//     /// Removes the give `edge` from the stor, if it is present. Removing
//     /// and edge will change the `connected` flag of the edges` slots
//     /// accordingly.
//     ///
//     /// - Parameter edge: The edge to be removed.
//     /// - Returns: In case of failure, a `RemoveEdgeError` and a `Void` if successful.
//     public func deleteEdge(
//         _ edge: Edge,
//         undoManager: UndoManager? = nil,
//         undoTitle: String = "Delete Edge"
//     ) -> Result<(), DeleteEdgeError> {

//         // Check if edge is present
//         if !self.edges.contains(edge) {
//             return .failure(.edgeNotPresent)
//         }

//         // Check if source node is present
//         if self.nodes[edge.from.node] == nil {
//             return .failure(.missingSourceNode)
//         }

//         // Check if destination node is present
//         if self.nodes[edge.to.node] == nil {
//             return .failure(.missingDestinationNode)
//         }

//         // Check if source node port slot is valid
//         if !self.nodes[edge.from.node]!.isValidPortSlot(edge.from.slot) {
//             return .failure(.invalidSourcePortSlot)
//         }

//         // Check if destination node port slot is valid
//         if !self.nodes[edge.to.node]!.isValidPortSlot(edge.to.slot) {
//             return .failure(.invalidDestinationPortSlot)
//         }

//         var needsToDisconnectSource: Bool = false

//         // Check how many edges are outgoing from the source.
//         switch self.edges(from: edge.from).count {
//         case 0:
//             // Note: this case should not really happen
//             return .failure(.unreachable)
//         case 1:
//             // Should not happen but check just in case
//             if self.edges(from: edge.from).first! != edge {
//                 return .failure(.unreachable)
//             }
//             // Since only the edge we are removing is connetced to the source,
//             // attempt to disconect it.
//             // if case .notConnected = self.nodes[edge.from.node]!.disconnect(edge.from.slot) {
//             //     return .failure(.sourceNotConnected)
//             // }
//             if self.nodePortConnected(edge.from) != true {
//                 return .failure(.sourceNotConnected)
//             } else {
//                 needsToDisconnectSource = true
//             }

//         default:
//             // Since there are other edges coming out of the source, just check if
//             // the `connected` property is valid.
//             if !self.nodes[edge.from.node]![connectedAt: edge.from.slot] {
//                 return .failure(.sourceNotConnected)
//             }
//         }

//         if self.nodePortConnected(edge.to) != true {
//             return .failure(.destinationNotConnected)
//         }

//         // Attempt to disconnect the destination port slot
//         // if case .notConnected = self.nodes[edge.to.node]!.disconnect(edge.to.slot) {
//         //     return .failure(.destinationNotConnected)
//         // }

//         undoManager?.beginUndoGrouping()

//         if needsToDisconnectSource {
//             self.setNodePortConnected(edge.from, value: false, undoManager: undoManager)
//         }

//         self.setNodePortConnected(edge.to, value: false, undoManager: undoManager)

//         // Remove the edge from the set
//         self._removeEdge(edge, undoManager: undoManager)

//         undoManager?.endUndoGrouping()
//         undoManager?.setActionName(undoTitle)

//         // Check if we are in a valid state
//         if self.validateEdges() != .ok {
//             return .failure(.validateEdges)
//         }

//         return .success(())
//     }

//     public enum DeleteEdgeError: Error {
//         case edgeNotPresent
//         case missingSourceNode
//         case missingDestinationNode
//         case invalidSourcePortSlot
//         case invalidDestinationPortSlot
//         case sourceNotConnected
//         case destinationNotConnected
//         case unreachable
//         case validateEdges
//     }

//     public func canAddEdge(_ edge: Edge) -> Result<(), AddEdgeError> {
//         // First, check if the edge is valid in principle
//         // (this is not strictly necessary since an `Edge` should,
//         // by construction, be valid, but I will leave this as a precaution)
//         if !edge.isValid() {
//             return .failure(.invalidEdge)
//         }

//         // Check if the edge is already present
//         if self.edges.contains(edge) {
//             return .failure(.duplicatedEdge)
//         }

//         // Check if the destination port slot is already connected
//         if self.edges(to: edge.to).count > 0 {
//             return .failure(.destinationAlreadyConnected(edge.to))
//         }

//         let from = edge.from
//         let to = edge.to

//         // Check if the source node is present
//         if self.nodes[from.node] == nil {
//             return .failure(.missingNode(from.node))
//         }

//         // Check if the destination node is present
//         if self.nodes[to.node] == nil {
//             return .failure(.missingNode(to.node))
//         }

//         // Check if the source port slot exists
//         if !self.nodes[from.node]!.isValidPortSlot(from.slot) {
//             return .failure(.invalidSourceSlot(from.slot))
//         }

//         // Check if the destination port slot exitsts
//         if !self.nodes[to.node]!.isValidPortSlot(to.slot) {
//             return .failure(.invalidDestinationSlot(to.slot))
//         }

//         // Check if the destination port slot is not already set as connected
//         if self.nodes[to.node]![connectedAt: to.slot] {
//             return .failure(.destinationAlreadyConnected(to))
//         }

//         // Check if the slots have the same type
//         let sourceType = self.nodes[from.node]![valueTypeAt: from.slot]
//         let destType = self.nodes[to.node]![valueTypeAt: to.slot]
//         if sourceType != destType {
//             return .failure(.typeMismatch(source: sourceType, dest: destType))

//         }

//         return .success(())
//     }

// }

// @MainActor
// extension Flow {

//     /// Gets the `ValueType` of the port slot at the give `PortLocation`,
//     /// or will fail with a reason defined in `GetPortTypeResult`.
//     ///
//     /// - Parameter loc: The location of the port slot.
//     /// - Returns: The result.
//     public func getPortType(_ loc: PortLocation) -> GetPortTypeResult {
//         guard let node = self.nodes[loc.node] else {
//             return .missingNode
//         }

//         if !node.isValidPortSlot(loc.slot) {
//             return .invalidSlot
//         }

//         return .ok(node[valueTypeAt: loc.slot])
//     }

//     public enum GetPortTypeResult {
//         case ok(ValueType)
//         case missingNode
//         case invalidSlot
//     }

//     /// Attempts to type check the operation of adding the given `Edge` to the store,
//     /// returning a `TypeCheckEdgeResult` value.
//     ///
//     /// - Parameter edge: The edge we want to type check adding to the store.
//     /// - Returns: The `TypeCheckEdgeResult`.
//     public func typeCheck(addingEdge edge: Edge) -> TypeCheckAddingEdgeResult {

//         if self.edges.contains(edge) {
//             return .edgeAlreadyExists
//         }

//         let sourceType: ValueType
//         switch self.getPortType(edge.from) {
//         case .missingNode: return .missingNode(edge.from.node)
//         case .invalidSlot: return .invalidPort(edge.from)
//         case .ok(let type): sourceType = type
//         }

//         let destType: ValueType
//         switch self.getPortType(edge.to) {
//         case .missingNode: return .missingNode(edge.from.node)
//         case .invalidSlot: return .invalidPort(edge.from)
//         case .ok(let type): destType = type
//         }

//         if sourceType != destType {

//             let sourceNode = self.nodes[edge.from.node]!
//             let destNode = self.nodes[edge.to.node]!

//             if let variation = destNode.variation(soThatSlot: edge.to.slot, hasType: sourceType) {
//                 return .typeMismatch(.fixConvertingDestTo(variation))
//             }

//             if let variation = sourceNode.variation(soThatSlot: edge.from.slot, hasType: destType) {
//                 return .typeMismatch(.fixConvertingSourceTo(variation))
//             }

//             return .typeMismatch(.nofix)
//         }

//         return .ok
//     }

//     /// The result of the `typeCheck(addingEdge:)` method.
//     public enum TypeCheckAddingEdgeResult {
//         /// The type checking was successful and the edge can be added.
//         case ok
//         /// The edge already exists in the store.
//         case edgeAlreadyExists
//         /// The node is missing
//         case missingNode(UUID)
//         /// The port is invalid
//         case invalidPort(PortLocation)
//         /// There is a type mismatch with the given fix
//         case typeMismatch(TypeMismatchFix)

//         public enum TypeMismatchFix: Sendable {
//             /// The mismatch hax no fix
//             case nofix
//             /// The mismatch can be fixed by converting the destination to the
//             /// given variation.
//             case fixConvertingDestTo(NodeKind)
//             /// The mismatch can be fixed by converting the sourc to the
//             /// given variation.
//             case fixConvertingSourceTo(NodeKind)
//         }
//     }

//     /// Attempts to add the given `node` to the store. Fails if
//     ///   - the a node with the same `id` is alrady in the store, or,
//     ///   - the `node` has any of its slots set to `connected`.
//     ///
//     /// - Parameters:
//     ///   - node: The node to add.
//     ///
//     /// - Returns: The result of the operation.
//     @discardableResult
//     public func createNewNode(_ node: FlowNode, undoManager: UndoManager?) -> Result<(), CreateNewNodeError> {
//         if self.nodes[node.id] != nil {
//             return .failure(.repeatedNodeID(node.id))
//         }

//         if node.inputs.filter({ $0.connected }).count > 0
//             || node.outputs.filter({ $0.connected }).count > 0
//         {
//             return .failure(.addingConnectedNode)
//         }

//         self._addNode(node, undoManager: undoManager)
//         undoManager?.setActionName("Create '\(node.kind.displayName)' Node")

//         return .success(())
//     }

//     public enum CreateNewNodeError: Error {
//         case repeatedNodeID(UUID)
//         case addingConnectedNode
//     }

//     /// Attembs to remove the node with the given `id` from the store. Fails if
//     /// the `id` is not found, or if the removal of any of the node's edges fails.
//     ///
//     /// - Parameter id: The id of the node.
//     /// - Returns: The result of the operation.
//     @discardableResult
//     public func deleteNode(
//         _ id: UUID,
//         undoManager: UndoManager? = nil,
//         undoTitle: String = "Delete Node"
//     ) -> Result<(), DeleteNodeError> {
//         if self.nodes[id] == nil {
//             return .failure(.invalidNodeID(id))
//         }

//         undoManager?.beginUndoGrouping()

//         var deleteEdgeErrors: [DeleteEdgeError] = []

//         for edge in self.edges(ofNode: id) {
//             if case let .failure(err) = self.deleteEdge(edge) {
//                 deleteEdgeErrors.append(err)
//                 continue
//             }
//         }

//         if self.isSelected(id) {
//             self.deleteNodes([id], undoManager: undoManager, undoTitle: "")
//         }

//         self._removeNode(id: id, undoManager: undoManager)

//         undoManager?.endUndoGrouping()
//         undoManager?.setActionName(undoTitle)

//         if deleteEdgeErrors.isEmpty {
//             return .success(())
//         } else {
//             return .failure(.removeEdge(deleteEdgeErrors))
//         }
//     }

//     @discardableResult
//     public func deleteNodes(
//         _ ids: Set<UUID>,
//         undoManager: UndoManager? = nil,
//         undoTitle: String = "Delete Node"
//     ) -> Result<(), DeleteNodesError> {
//         var err = DeleteNodesError()

//         if ids.isEmpty { return .success(()) }

//         undoManager?.beginUndoGrouping()

//         self.setSelection(self.selection.subtracting(ids), undoManager: undoManager, undoTitle: "")

//         for id in ids {
//             switch self.deleteNode(id, undoManager: undoManager, undoTitle: "") {
//             case .success:
//                 break
//             case .failure(let deletNodeErr):
//                 err.errors.append(deletNodeErr)
//             }
//         }

//         undoManager?.endUndoGrouping()
//         undoManager?.setActionName(undoTitle)

//         if err.errors.isEmpty {
//             return .success(())
//         } else {
//             return .failure(err)
//         }
//     }

//     public enum DeleteNodeError: Error {
//         case invalidNodeID(UUID)
//         case removeEdge([DeleteEdgeError])
//     }

//     public struct DeleteNodesError: Error {
//         public var errors: [DeleteNodeError] = []
//     }
// }

// @MainActor
// extension Flow {
//     /// Validates all the edge connection. Only checks to see if the edges and
//     /// node connections match, and if there are no multiple edges incoming to the same
//     /// port slot, or edges with missing nodes or ports. This makes no type-checking on
//     /// the connections.
//     ///
//     /// - Returns: The `ValidateEdgesResult` value.
//     public func validateEdges() -> ValidateEdgesResult {
//         let result: ValidateEdgesResult? = {
//             for edge in self.edges {
//                 let from = edge.from
//                 let to = edge.to

//                 guard let fromNode = self.nodes[from.node] else {
//                     return .missingNode(from.node)
//                 }

//                 guard let toNode = self.nodes[to.node] else {
//                     return .missingNode(to.node)
//                 }

//                 if !fromNode.isValidPortSlot(from.slot) {
//                     return .invalidSlot(from)
//                 }

//                 if !toNode.isValidPortSlot(to.slot) {
//                     return .invalidSlot(to)
//                 }

//                 if self.edges(to: to).count != 1 {
//                     return .tooManyIncomingEdges(to)
//                 }
//             }

//             for (id, node) in self.nodes {
//                 for (idx, input) in node.inputs.enumerated() {
//                     if input.connected {
//                         if self.edges(to: .init(node: id, port: .input(idx))).count != 1 {
//                             return .tooManyIncomingEdges(.init(node: id, port: .input(idx)))
//                         }
//                     }
//                 }
//                 for (idx, output) in node.outputs.enumerated() {
//                     if output.connected {
//                         if self.edges(from: .init(node: id, port: .output(idx))).count < 1 {
//                             return .tooFewOutgointEdges(.init(node: id, port: .output(idx)))
//                         }
//                     }
//                 }
//             }

//             return .ok
//         }()

//         return result!
//     }

//     /// The result of the `validateEdges` method.
//     public enum ValidateEdgesResult: Sendable, Equatable {
//         /// Evertything ok :)
//         case ok
//         // The node with the given id is missing.
//         case missingNode(UUID)
//         // The given port slot is missing
//         case invalidSlot(PortLocation)
//         // Too may edges (more than one) are incoming to this port slot.
//         case tooManyIncomingEdges(PortLocation)
//         // Too few edges (zero) are outgoing from this port slot.
//         case tooFewOutgointEdges(PortLocation)
//     }
// }
