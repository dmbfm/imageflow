import Backend
import CoreGraphics
import Foundation
import Testing
import Values
@testable import Models

import struct Models.Edge

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
    return Edge(output, input)! // construction is validated by PortLocation.canConnectWith
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
