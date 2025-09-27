import Backend
import CoreGraphics
import Foundation
import Testing
import Values

import struct Models.Edge

@testable import Models

@MainActor
private func makeNode(
    id: UUID = UUID(),
    name: String = "Node",
    value: Value = .float(0.0),
    valueType: ValueType = .float
) -> FlowNode {
    FlowNode(
        id: id,
        name: name,
        kind: .valueNode(valueType),
        inputs: [
            .init(
                label: "input",
                index: 0,
                value: value,
                semantics: .default,
                connected: false
            )
        ],
        outputs: [
            .init(
                label: "output",
                index: 0,
                type: valueType,
                connected: false
            )
        ]
    )
}

private func makeEdge(
    from source: FlowNode,
    to destination: FlowNode
) -> Edge {
    let output = PortLocation(node: source.id, port: .output(0))
    let input = PortLocation(node: destination.id, port: .input(0))
    return Edge(output, input)!  // construction is validated by PortLocation.canConnectWith
}

private func makeEdge(
    from source: FlowNode,
    sourceSlot: PortSlot,
    to destination: FlowNode,
    destSlot: PortSlot
) -> Edge {
    Edge(
        PortLocation(node: source.id, port: sourceSlot),
        PortLocation(node: destination.id, port: destSlot)
    )!
}

@MainActor
private func makeFlow(nodes: [FlowNode], edges: Set<Edge> = []) -> Models.Flow {
    let nodeMap = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0) })
    let positions = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, CGPoint.zero) })
    return Models.Flow(
        nodes: nodeMap,
        nodePositions: positions,
        edges: edges
    )
}

private func expectValidationError(
    _ error: Error,
    handler: (Models.Flow.FlowValidationError) -> Void
) {
    guard let validationError = error as? Models.Flow.FlowValidationError else {
        #expect(Bool(false), "Unexpected error: \(error)")
        return
    }

    handler(validationError)
}

@MainActor
@Test("Adding a node stores node data and its position")
func addNodeStoresState() throws {
    let flow = Flow()
    let node = makeNode(name: "Source")
    let position = CGPoint(x: 42, y: -7)

    try flow.addNode(node, at: position)

    #expect(flow.nodes[node.id] == node)
    #expect(flow.nodePositions[node.id] == position)
}

@MainActor
@Test("Connecting nodes inserts the edge and marks both ports connected")
func addEdgeConnectingNodesMarksPorts() throws {
    let flow = Flow()
    let source = makeNode(name: "Producer")
    let destination = makeNode(name: "Consumer")
    try flow.addNode(source, at: .zero)
    try flow.addNode(destination, at: CGPoint(x: 120, y: 0))
    let edge = makeEdge(from: source, to: destination)

    try flow.addEdgeConnectingNodes(edge)

    #expect(flow.edges.contains(edge))
    #expect(flow.nodes[source.id]?[connectedAt: .output(0)] == true)
    #expect(flow.nodes[destination.id]?[connectedAt: .input(0)] == true)
}

@MainActor
@Test("Removing an edge disconnects the destination port and drops the edge")
func deleteEdgeDisconnectingNodesClearsDestinationPort() throws {
    let flow = Flow()
    let source = makeNode(name: "Producer")
    let destination = makeNode(name: "Consumer")
    try flow.addNode(source, at: .zero)
    try flow.addNode(destination, at: CGPoint(x: 120, y: 0))
    let edge = makeEdge(from: source, to: destination)
    try flow.addEdgeConnectingNodes(edge)

    try flow.deleteEdgeDisconnectingNodes(edge)

    #expect(!flow.edges.contains(edge))
    #expect(flow.nodes[destination.id]?[connectedAt: .input(0)] == false)
}

@MainActor
@Test("Deleting a node with edges removes connected edges and returns snapshot")
func deleteNodeRemovingEdgesRemovesState() throws {
    let flow = Flow()
    let source = makeNode(name: "Producer")
    let destination = makeNode(name: "Consumer")
    try flow.addNode(source, at: .zero)
    try flow.addNode(destination, at: CGPoint(x: 64, y: 0))
    let edge = makeEdge(from: source, to: destination)
    try flow.addEdgeConnectingNodes(edge)

    let result = try flow.deleteNodeRemovingEdges(destination.id)

    #expect(flow.nodes[destination.id] == nil)
    #expect(!flow.edges.contains(edge))
    #expect(result.node == destination)
    #expect(result.position == CGPoint(x: 64, y: 0))
    #expect(result.edges == [edge])
}

@MainActor
@Test("Undoing addNode removes the node and redoing restores it")
func undoRedoAddNode() throws {
    let flow = Flow()
    let undoManager = UndoManager()
    undoManager.groupsByEvent = false
    let node = makeNode(name: "Undoable")
    let position = CGPoint(x: 10, y: 20)

    undoManager.beginUndoGrouping()
    try flow.addNode(node, at: position, undoManager: undoManager)
    undoManager.endUndoGrouping()
    #expect(flow.nodes[node.id] != nil)

    undoManager.undo()
    #expect(flow.nodes[node.id] == nil)

    undoManager.redo()
    #expect(flow.nodes[node.id] == node)
    #expect(flow.nodePositions[node.id] == position)
}

@MainActor
@Test("Undoing deleteNode restores the node and position")
func undoRedoDeleteNode() throws {
    let flow = Flow()
    let undoManager = UndoManager()
    undoManager.groupsByEvent = false
    let node = makeNode(name: "UndoDelete")
    let position = CGPoint(x: -30, y: 80)
    try flow.addNode(node, at: position)

    undoManager.beginUndoGrouping()
    try flow.deleteNode(node.id, undoManager: undoManager)
    undoManager.endUndoGrouping()
    #expect(flow.nodes[node.id] == nil)

    undoManager.undo()
    #expect(flow.nodes[node.id] == node)
    #expect(flow.nodePositions[node.id] == position)

    undoManager.redo()
    #expect(flow.nodes[node.id] == nil)
}

@MainActor
@Test("Undoing addEdgeConnectingNodes restores connection state after redo")
func undoRedoAddEdgeConnectingNodes() throws {
    let flow = Flow()
    let undoManager = UndoManager()
    undoManager.groupsByEvent = false
    let source = makeNode(name: "Producer")
    let destination = makeNode(name: "Consumer")
    try flow.addNode(source, at: .zero)
    try flow.addNode(destination, at: CGPoint(x: 120, y: 0))
    let edge = makeEdge(from: source, to: destination)

    undoManager.beginUndoGrouping()
    try flow.addEdgeConnectingNodes(edge, undoManager: undoManager)
    undoManager.endUndoGrouping()
    #expect(flow.edges.contains(edge))

    undoManager.undo()
    #expect(!flow.edges.contains(edge))
    #expect(flow.nodes[source.id]?[connectedAt: .output(0)] == false)
    #expect(flow.nodes[destination.id]?[connectedAt: .input(0)] == false)

    undoManager.redo()
    #expect(flow.edges.contains(edge))
    #expect(flow.nodes[source.id]?[connectedAt: .output(0)] == true)
    #expect(flow.nodes[destination.id]?[connectedAt: .input(0)] == true)
}

@MainActor
@Test("Undoing deleteEdgeDisconnectingNodes reinstates the edge and port flags")
func undoRedoDeleteEdgeDisconnectingNodes() throws {
    let flow = Flow()
    let undoManager = UndoManager()
    undoManager.groupsByEvent = false
    let source = makeNode(name: "Producer")
    let destination = makeNode(name: "Consumer")
    try flow.addNode(source, at: .zero)
    try flow.addNode(destination, at: CGPoint(x: 120, y: 0))
    let edge = makeEdge(from: source, to: destination)

    undoManager.beginUndoGrouping()
    try flow.addEdgeConnectingNodes(edge, undoManager: undoManager)
    undoManager.endUndoGrouping()

    undoManager.beginUndoGrouping()
    try flow.deleteEdgeDisconnectingNodes(edge, undoManager: undoManager)
    undoManager.endUndoGrouping()
    #expect(!flow.edges.contains(edge))

    undoManager.undo()
    #expect(flow.edges.contains(edge))
    #expect(flow.nodes[source.id]?[connectedAt: .output(0)] == true)
    #expect(flow.nodes[destination.id]?[connectedAt: .input(0)] == true)

    undoManager.redo()
    #expect(!flow.edges.contains(edge))
    #expect(flow.nodes[source.id]?[connectedAt: .output(0)] == false)
    #expect(flow.nodes[destination.id]?[connectedAt: .input(0)] == false)
}

@MainActor
@Test("Selecting nodes replaces by default")
func selectionReplaceMode() throws {
    let flow = Flow()
    let nodeA = makeNode(name: "A")
    let nodeB = makeNode(name: "B")
    try flow.addNode(nodeA, at: .zero)
    try flow.addNode(nodeB, at: CGPoint(x: 10, y: 0))

    flow.select(node: nodeA.id)
    #expect(flow.selection == Set([nodeA.id]))

    flow.select(node: nodeB.id)
    #expect(flow.selection == Set([nodeB.id]))
}

@MainActor
@Test("Union selection keeps existing nodes and ignores missing ones")
func selectionUnionModeIgnoresMissing() throws {
    let flow = Flow()
    let nodeA = makeNode(name: "A")
    let nodeB = makeNode(name: "B")
    try flow.addNode(nodeA, at: .zero)
    try flow.addNode(nodeB, at: CGPoint(x: 10, y: 0))
    let missing = UUID()

    flow.select(node: nodeA.id)
    flow.select(nodes: [nodeB.id, missing], mode: .union)

    #expect(flow.selection == Set([nodeA.id, nodeB.id]))
    #expect(!flow.selection.contains(missing))
}

@MainActor
@Test("Selecting all and none updates selection set")
func selectionAllAndNone() throws {
    let flow = Flow()
    let nodes = (0..<3).map { index in
        makeNode(name: "Node \(index)")
    }
    for (offset, node) in nodes.enumerated() {
        try flow.addNode(node, at: CGPoint(x: offset * 10, y: 0))
    }

    flow.selectAll()
    #expect(flow.selection == Set(nodes.map(\.id)))

    flow.selectNone()
    #expect(flow.selection.isEmpty)
}

@MainActor
@Test("Deselect operations drop nodes from the selection")
func selectionDeselectNodes() throws {
    let flow = Flow()
    let nodeA = makeNode(name: "A")
    let nodeB = makeNode(name: "B")
    try flow.addNode(nodeA, at: .zero)
    try flow.addNode(nodeB, at: CGPoint(x: 10, y: 0))

    flow.selectAll()
    flow.deselect(node: nodeA.id)
    #expect(flow.selection == Set([nodeB.id]))

    flow.deselect(nodes: [nodeB.id, UUID()])
    #expect(flow.selection.isEmpty)
}

@MainActor
@Test("Live selection replace mode commits new selection on end")
func liveSelectionReplaceModeCommit() throws {
    let flow = Flow()
    let nodeA = makeNode(name: "A")
    let nodeB = makeNode(name: "B")
    try flow.addNode(nodeA, at: .zero)
    try flow.addNode(nodeB, at: CGPoint(x: 12, y: 0))

    flow.select(node: nodeA.id)

    flow.beginLiveSelection()
    flow.updateLiveSelection(nodes: [nodeB.id], mode: .replace)
    #expect(flow.selection == Set([nodeB.id]))

    flow.endLiveSelection()
    flow.cancelLiveSelection()
    #expect(flow.selection == Set([nodeB.id]))
}

@MainActor
@Test("Cancelling live selection restores snapshot for union mode")
func liveSelectionCancelRestoresSnapshot() throws {
    let flow = Flow()
    let nodeA = makeNode(name: "A")
    let nodeB = makeNode(name: "B")
    try flow.addNode(nodeA, at: .zero)
    try flow.addNode(nodeB, at: CGPoint(x: 18, y: 0))
    flow.select(node: nodeA.id)

    flow.beginLiveSelection()
    flow.updateLiveSelection(nodes: [nodeB.id, UUID()], mode: .union)
    #expect(flow.selection == Set([nodeA.id, nodeB.id]))

    flow.cancelLiveSelection()
    #expect(flow.selection == Set([nodeA.id]))
}

@MainActor
@Test("Live selection responds to dynamic mode changes")
func liveSelectionDynamicModeSwitch() throws {
    let flow = Flow()
    let nodeA = makeNode(name: "A")
    let nodeB = makeNode(name: "B")
    let nodeC = makeNode(name: "C")
    try flow.addNode(nodeA, at: .zero)
    try flow.addNode(nodeB, at: CGPoint(x: 15, y: 0))
    try flow.addNode(nodeC, at: CGPoint(x: 30, y: 0))

    flow.select(node: nodeA.id)

    flow.beginLiveSelection()
    flow.updateLiveSelection(nodes: [nodeB.id], mode: .replace)
    #expect(flow.selection == Set([nodeB.id]))

    flow.updateLiveSelection(nodes: [nodeC.id], mode: .union)
    #expect(flow.selection == Set([nodeA.id, nodeC.id]))

    flow.updateLiveSelection(nodes: [nodeB.id], mode: .replace)
    #expect(flow.selection == Set([nodeB.id]))

    flow.endLiveSelection()
}

// MARK: - Validation

@MainActor
@Test("Validation accepts consistent graph state")
func validateNodeGraphAcceptsConsistentGraph() throws {
    let flow = Flow()
    let source = makeNode(name: "Source")
    let destination = makeNode(name: "Destination")
    try flow.addNode(source, at: .zero)
    try flow.addNode(destination, at: CGPoint(x: 120, y: 0))
    let edge = makeEdge(from: source, to: destination)

    try flow.addEdgeConnectingNodes(edge)

    try flow.validateNodeGraph()
}

@MainActor
@Test("Validation rejects multiple edges per input")
func validateNodeGraphRejectsMultipleEdgesPerInput() throws {
    var sourceA = makeNode(name: "Producer A")
    var sourceB = makeNode(name: "Producer B")
    var destination = makeNode(name: "Consumer")

    sourceA[connectedAt: .output(0)] = true
    sourceB[connectedAt: .output(0)] = true
    destination[connectedAt: .input(0)] = true

    let edgeA = makeEdge(from: sourceA, to: destination)
    let edgeB = Edge(
        PortLocation(node: sourceB.id, port: .output(0)),
        PortLocation(node: destination.id, port: .input(0))
    )!

    let flow = makeFlow(nodes: [sourceA, sourceB, destination], edges: Set([edgeA, edgeB]))

    do {
        try flow.validateNodeGraph()
        #expect(Bool(false), "Expected tooManyEdgesForInput error")
    } catch let error {
        expectValidationError(error) { validationError in
            switch validationError {
            case let .tooManyEdgesForInput(nodeId, index):
                #expect(nodeId == destination.id)
                #expect(index == 0)
            default:
                #expect(Bool(false), "Unexpected error: \(validationError)")
            }
        }
    }
}

@MainActor
@Test("Validation rejects connected ports without edges")
func validateNodeGraphRejectsConnectedPortWithoutEdge() throws {
    var node = makeNode(name: "Lonely")
    node[connectedAt: .input(0)] = true

    let flow = makeFlow(nodes: [node])

    do {
        try flow.validateNodeGraph()
        #expect(Bool(false), "Expected connectedPortWithoutEdge error")
    } catch let error {
        expectValidationError(error) { validationError in
            switch validationError {
            case let .connectedPortWithoutEdge(location):
                #expect(location.node == node.id)
                #expect(location.slot == PortSlot.input(0))
            default:
                #expect(Bool(false), "Unexpected error: \(validationError)")
            }
        }
    }
}

@MainActor
@Test("Validation rejects disconnected destination ports with edges")
func validateNodeGraphRejectsDisconnectedDestinationPort() throws {
    var source = makeNode(name: "Source")
    var destination = makeNode(name: "Destination")

    source[connectedAt: .output(0)] = true
    destination[connectedAt: .input(0)] = false

    let edge = makeEdge(from: source, to: destination)

    let flow = makeFlow(nodes: [source, destination], edges: Set([edge]))

    do {
        try flow.validateNodeGraph()
        #expect(Bool(false), "Expected disconnectedPortWithEdge error")
    } catch let error {
        expectValidationError(error) { validationError in
            switch validationError {
            case let .disconnectedPortWithEdge(location):
                #expect(location.node == destination.id)
                #expect(location.slot == PortSlot.input(0))
            default:
                #expect(Bool(false), "Unexpected error: \(validationError)")
            }
        }
    }
}

@MainActor
@Test("Validation rejects disconnected source ports with edges")
func validateNodeGraphRejectsDisconnectedSourcePort() throws {
    var source = makeNode(name: "Source")
    var destination = makeNode(name: "Destination")

    source[connectedAt: .output(0)] = false
    destination[connectedAt: .input(0)] = true

    let edge = makeEdge(from: source, to: destination)

    let flow = makeFlow(nodes: [source, destination], edges: Set([edge]))

    do {
        try flow.validateNodeGraph()
        #expect(Bool(false), "Expected disconnectedPortWithEdge error")
    } catch let error {
        expectValidationError(error) { validationError in
            switch validationError {
            case let .disconnectedPortWithEdge(location):
                #expect(location.node == source.id)
                #expect(location.slot == PortSlot.output(0))
            default:
                #expect(Bool(false), "Unexpected error: \(validationError)")
            }
        }
    }
}

@MainActor
@Test("Validation rejects edges with missing source nodes")
func validateNodeGraphRejectsMissingSourceNode() throws {
    var destination = makeNode(name: "Destination")
    destination[connectedAt: .input(0)] = true

    let missingSource = UUID()
    let edge = Edge(
        PortLocation(node: missingSource, port: .output(0)),
        PortLocation(node: destination.id, port: .input(0))
    )!

    let flow = makeFlow(nodes: [destination], edges: Set([edge]))

    do {
        try flow.validateNodeGraph()
        #expect(Bool(false), "Expected sourceNodeMissingForEdge error")
    } catch let error {
        expectValidationError(error) { validationError in
            switch validationError {
            case let .sourceNodeMissingForEdge(missingEdge):
                #expect(missingEdge == edge)
            default:
                #expect(Bool(false), "Unexpected error: \(validationError)")
            }
        }
    }
}

@MainActor
@Test("Validation rejects edges with missing destination nodes")
func validateNodeGraphRejectsMissingDestinationNode() throws {
    var source = makeNode(name: "Source")
    source[connectedAt: .output(0)] = true

    let missingDestination = UUID()
    let edge = Edge(
        PortLocation(node: source.id, port: .output(0)),
        PortLocation(node: missingDestination, port: .input(0))
    )!

    let flow = makeFlow(nodes: [source], edges: Set([edge]))

    do {
        try flow.validateNodeGraph()
        #expect(Bool(false), "Expected destinationNodeMissingForEdge error")
    } catch let error {
        expectValidationError(error) { validationError in
            switch validationError {
            case let .destinationNodeMissingForEdge(missingEdge):
                #expect(missingEdge == edge)
            default:
                #expect(Bool(false), "Unexpected error: \(validationError)")
            }
        }
    }
}

@MainActor
@Test("Validation rejects simple cycles")
func validateNodeGraphRejectsSimpleCycle() throws {
    let flow = Flow()
    let nodeA = makeNode(name: "A")
    let nodeB = makeNode(name: "B")
    try flow.addNode(nodeA, at: .zero)
    try flow.addNode(nodeB, at: CGPoint(x: 120, y: 0))

    let edgeAB = makeEdge(from: nodeA, to: nodeB)
    let edgeBA = makeEdge(from: nodeB, to: nodeA)

    try flow.addEdgeConnectingNodes(edgeAB)
    try flow.addEdgeConnectingNodes(edgeBA)

    do {
        try flow.validateNodeGraph()
        #expect(Bool(false), "Expected graphHasCycles error")
    } catch let error {
        expectValidationError(error) { validationError in
            switch validationError {
            case .graphHasCycles:
                break
            default:
                #expect(Bool(false), "Unexpected error: \(validationError)")
            }
        }
    }
}

@MainActor
@Test("Validation rejects longer cycles")
func validateNodeGraphRejectsLongerCycle() throws {
    let flow = Flow()
    let nodeA = makeNode(name: "A")
    let nodeB = makeNode(name: "B")
    let nodeC = makeNode(name: "C")
    let nodeD = makeNode(name: "D")

    try flow.addNode(nodeA, at: .zero)
    try flow.addNode(nodeB, at: CGPoint(x: 120, y: 0))
    try flow.addNode(nodeC, at: CGPoint(x: 240, y: 0))
    try flow.addNode(nodeD, at: CGPoint(x: 360, y: 0))

    let edgeAB = makeEdge(from: nodeA, to: nodeB)
    let edgeBC = makeEdge(from: nodeB, to: nodeC)
    let edgeCA = makeEdge(from: nodeC, to: nodeA)
    let edgeCD = makeEdge(from: nodeC, to: nodeD)

    try flow.addEdgeConnectingNodes(edgeAB)
    try flow.addEdgeConnectingNodes(edgeBC)
    try flow.addEdgeConnectingNodes(edgeCA)
    try flow.addEdgeConnectingNodes(edgeCD)

    do {
        try flow.validateNodeGraph()
        #expect(Bool(false), "Expected graphHasCycles error")
    } catch let error {
        expectValidationError(error) { validationError in
            switch validationError {
            case .graphHasCycles:
                break
            default:
                #expect(Bool(false), "Unexpected error: \(validationError)")
            }
        }
    }
}

// MARK: - canAddEdge

@MainActor
@Test("canAddEdge allows valid connection")
func canAddEdgeAcceptsValidEdge() throws {
    let source = makeNode(name: "Source")
    let dest = makeNode(name: "Dest")
    let flow = makeFlow(nodes: [source, dest])
    let candidate = makeEdge(from: source, to: dest)

    switch flow.canAddEdge(candidate) {
    case .ok:
        break
    case .failure(let failure):
        #expect(Bool(false), "Expected .ok, got failure: \(failure)")
    }
}

@MainActor
@Test("canAddEdge rejects duplicate edge")
func canAddEdgeRejectsDuplicateEdge() throws {
    var source = makeNode(name: "Source")
    var dest = makeNode(name: "Dest")
    source[connectedAt: .output(0)] = true
    dest[connectedAt: .input(0)] = true
    let existing = makeEdge(from: source, to: dest)
    let flow = makeFlow(nodes: [source, dest], edges: Set([existing]))

    switch flow.canAddEdge(existing) {
    case .failure(.duplicateEdge):
        break
    default:
        #expect(Bool(false), "Expected duplicateEdge failure")
    }
}

@MainActor
@Test("canAddEdge rejects edges targeting occupied input")
func canAddEdgeRejectsEdgeWithSameDestination() throws {
    var nodeA = makeNode(name: "A")
    var nodeB = makeNode(name: "B")
    let nodeC = makeNode(name: "C")
    nodeA[connectedAt: .output(0)] = true
    nodeB[connectedAt: .input(0)] = true
    let existing = makeEdge(from: nodeA, to: nodeB)
    let flow = makeFlow(nodes: [nodeA, nodeB, nodeC], edges: Set([existing]))
    let candidate = makeEdge(from: nodeC, to: nodeB)

    switch flow.canAddEdge(candidate) {
    case .failure(.edgeWithSameDestinationAlreadyExists):
        break
    default:
        #expect(Bool(false), "Expected edgeWithSameDestinationAlreadyExists failure")
    }
}

@MainActor
@Test("canAddEdge rejects unknown source nodes")
func canAddEdgeRejectsMissingSourceNode() throws {
    let source = makeNode(name: "Missing")
    let dest = makeNode(name: "Present")
    let flow = makeFlow(nodes: [dest])
    let candidate = makeEdge(from: source, to: dest)

    switch flow.canAddEdge(candidate) {
    case .failure(.missingSourceNode):
        break
    default:
        #expect(Bool(false), "Expected missingSourceNode failure")
    }
}

@MainActor
@Test("canAddEdge rejects unknown destination nodes")
func canAddEdgeRejectsMissingDestinationNode() throws {
    let source = makeNode(name: "Present")
    let dest = makeNode(name: "Missing")
    let flow = makeFlow(nodes: [source])
    let candidate = makeEdge(from: source, to: dest)

    switch flow.canAddEdge(candidate) {
    case .failure(.missingDestinationNode):
        break
    default:
        #expect(Bool(false), "Expected missingDestinationNode failure")
    }
}

@MainActor
@Test("canAddEdge rejects invalid source slots")
func canAddEdgeRejectsInvalidSourcePortSlot() throws {
    let source = makeNode(name: "Source")
    let dest = makeNode(name: "Dest")
    let flow = makeFlow(nodes: [source, dest])
    let candidate = makeEdge(from: source, sourceSlot: .output(3), to: dest, destSlot: .input(0))

    switch flow.canAddEdge(candidate) {
    case .failure(.invalidSourcePortSlot):
        break
    default:
        #expect(Bool(false), "Expected invalidSourcePortSlot failure")
    }
}

@MainActor
@Test("canAddEdge rejects invalid destination slots")
func canAddEdgeRejectsInvalidDestinationPortSlot() throws {
    let source = makeNode(name: "Source")
    let dest = makeNode(name: "Dest")
    let flow = makeFlow(nodes: [source, dest])
    let candidate = makeEdge(from: source, sourceSlot: .output(0), to: dest, destSlot: .input(5))

    switch flow.canAddEdge(candidate) {
    case .failure(.invalidDestinationPortSlot):
        break
    default:
        #expect(Bool(false), "Expected invalidDestinationPortSlot failure")
    }
}

@MainActor
@Test("canAddEdge rejects already connected destination ports")
func canAddEdgeRejectsConnectedDestinationPort() throws {
    let source = makeNode(name: "Source")
    var dest = makeNode(name: "Dest")
    dest[connectedAt: .input(0)] = true
    let flow = makeFlow(nodes: [source, dest])
    let candidate = makeEdge(from: source, to: dest)

    switch flow.canAddEdge(candidate) {
    case .failure(.destinationPortAlreadyConnected):
        break
    default:
        #expect(Bool(false), "Expected destinationPortAlreadyConnected failure")
    }
}

@MainActor
@Test("canAddEdge suggests converting destination variation")
func canAddEdgeSuggestsDestVariation() throws {
    let source = makeNode(name: "Source", valueType: .float)
    let dest = makeNode(name: "Dest", value: .int(0), valueType: .int)
    let flow = makeFlow(nodes: [source, dest])
    let candidate = makeEdge(from: source, to: dest)

    switch flow.canAddEdge(candidate) {
    case .failure(.typeMismatch(.fixConvertingDestTo(let variation))):
        #expect(variation == NodeKind.valueNode(.float))
    default:
        #expect(Bool(false), "Expected typeMismatch.fixConvertingDestTo failure")
    }
}

@MainActor
@Test("canAddEdge suggests converting source variation")
func canAddEdgeSuggestsSourceVariation() throws {
    let source = makeNode(name: "Source", valueType: .float)
    var dest = makeNode(name: "Dest", value: .int(0), valueType: .int)
    dest.outputs[0].connected = true
    let flow = makeFlow(nodes: [source, dest])
    let candidate = makeEdge(from: source, to: dest)

    switch flow.canAddEdge(candidate) {
    case .failure(.typeMismatch(.fixConvertingSourceTo(let variation))):
        #expect(variation == NodeKind.valueNode(.int))
    default:
        #expect(Bool(false), "Expected typeMismatch.fixConvertingSourceTo failure")
    }
}

@MainActor
@Test("canAddEdge detects unresolvable type mismatches")
func canAddEdgeRejectsUnfixableTypeMismatch() throws {
    var source = makeNode(name: "Source", valueType: .float)
    var dest = makeNode(name: "Dest", value: .int(0), valueType: .int)
    source.outputs[0].connected = true
    dest.outputs[0].connected = true
    let flow = makeFlow(nodes: [source, dest])
    let candidate = makeEdge(from: source, to: dest)

    switch flow.canAddEdge(candidate) {
    case .failure(.typeMismatch(.cantFix)):
        break
    default:
        #expect(Bool(false), "Expected typeMismatch.cantFix failure")
    }
}

@MainActor
@Test("canAddEdge rejects edges that introduce cycles")
func canAddEdgeRejectsCycle() throws {
    var nodeA = makeNode(name: "A")
    var nodeB = makeNode(name: "B")
    nodeB[connectedAt: .output(0)] = true
    nodeA[connectedAt: .input(0)] = true
    let existing = makeEdge(from: nodeB, to: nodeA)
    let flow = makeFlow(nodes: [nodeA, nodeB], edges: Set([existing]))
    let candidate = makeEdge(from: nodeA, to: nodeB)

    switch flow.canAddEdge(candidate) {
    case .failure(.causesCycle):
        break
    default:
        #expect(Bool(false), "Expected causesCycle failure")
    }
}
