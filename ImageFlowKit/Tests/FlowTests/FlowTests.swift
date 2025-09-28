import Backend
import CoreGraphics
import Foundation
import Testing
import Values

import struct Models.Edge

@testable import Models

// MARK: - Helpers

@MainActor
let um: UndoManager = {
    let um = UndoManager()
    um.groupsByEvent = false
    return um
}()

extension UndoManager {
    func withGroup(_ perform: () -> ()) {
        self.beginUndoGrouping()
        perform()
        self.endUndoGrouping()
    }
}

// MARK: - Nodes, Ports and Edges - Atomic Operations

@MainActor
@Test("`addNode` should correctly add one node to `nodes`")
func testAddNode() {
    let flow = Flow()
    let node = FlowNode(kind: .valueNode(.float))
    flow.addNode(node)
    #expect(flow.nodes.count == 1)
    #expect(flow.nodes[node.id] == node)
}

@MainActor
@Test("`removeNode` should correctly remove one node from `nodes`")
func testRemoveNode() {
    let flow = Flow()
    let node1 = FlowNode(kind: .valueNode(.float))
    let node2 = FlowNode(kind: .valueNode(.float))
    flow.addNode(node1)
    flow.addNode(node2)
    #expect(flow.nodes.count == 2)
    flow.removeNode(node2.id)
    #expect(flow.nodes.count == 1)
    #expect(flow.nodes[node1.id] == node1)
    #expect(flow.nodes[node2.id] == nil)
}

@MainActor
@Test("`updateNode` should correctly modify a node from `nodes`")
func testUpdateNode() {
    let flow = Flow()
    let id = UUID()
    let node = FlowNode(kind: .addNode(.vector2))
    let node1 = FlowNode(id: id, kind: .valueNode(.float))
    let node2 = FlowNode(id: id, kind: .valueNode(.int))
    flow.addNode(node)
    flow.addNode(node1)
    #expect(flow.nodes.count == 2)
    #expect(flow.nodes[id] == node1)
    #expect(flow.nodes[node.id] == node)
    flow.updateNode(node2)
    #expect(flow.nodes.count == 2)
    #expect(flow.nodes[id] == node2)
    #expect(flow.nodes[node.id] == node)
}

@MainActor
@Test("`addEdge` should correctly add an edge")
func testAddEdge() {
    let flow = Flow()
    #expect(flow.edges.isEmpty)
    let edge = Edge(.init(node: .init(), port: .output(0)), .init(node: .init(), port: .input(0)))!
    flow.addEdge(edge)
    #expect(flow.edges.count == 1)
    #expect(flow.edges.contains(edge))
}

@MainActor
@Test("`removeEdge` should correctly add an edge")
func testRemoveEdge() {
    let flow = Flow()
    #expect(flow.edges.isEmpty)
    let edge = Edge(.init(node: .init(), port: .output(0)), .init(node: .init(), port: .input(0)))!
    flow.addEdge(edge)
    #expect(flow.edges.count == 1)
    #expect(flow.edges.contains(edge))
    flow.removeEdge(edge)
    #expect(flow.edges.isEmpty)
}

// MARK: - Nodes, Ports and Edges - Atomic Operations (Undo)

@MainActor
@Test("`addNode` should correctly add one node to `nodes`, remove with `undo` and add again with `redo`.")
func testAddNodeUndoRedo() {
    let flow = Flow()
    let node = FlowNode(kind: .valueNode(.float))
    um.withGroup { flow.addNode(node, undoManager: um) }
    #expect(flow.nodes.count == 1)
    #expect(flow.nodes[node.id] == node)
    um.undo()
    #expect(flow.nodes.count == 0)
    #expect(flow.nodes[node.id] == nil)
    um.redo()
    #expect(flow.nodes.count == 1)
    #expect(flow.nodes[node.id] == node)
}

@MainActor
@Test(
    "`removeNode` should correctly remove one node from `nodes`, add the node again with `undo` and remove again with `redo`."
)
func testRemoveNodeUndoRedo() {
    let flow = Flow()
    let node1 = FlowNode(kind: .valueNode(.float))
    let node2 = FlowNode(kind: .valueNode(.float))
    um.withGroup { flow.addNode(node1, undoManager: um) }
    um.withGroup { flow.addNode(node2, undoManager: um) }
    #expect(flow.nodes.count == 2)
    um.withGroup { flow.removeNode(node2.id, undoManager: um) }
    #expect(flow.nodes.count == 1)
    #expect(flow.nodes[node1.id] == node1)
    #expect(flow.nodes[node2.id] == nil)
    um.undo()
    #expect(flow.nodes.count == 2)
    #expect(flow.nodes[node1.id] == node1)
    #expect(flow.nodes[node2.id] == node2)
    um.redo()
    #expect(flow.nodes.count == 1)
    #expect(flow.nodes[node1.id] == node1)
    #expect(flow.nodes[node2.id] == nil)
}

@MainActor
@Test("`addNode` and `removeNode` mixed undo operations")
func testAddRemoveNodeUndoRedo() {
    let flow = Flow()
    let node1 = FlowNode(kind: .valueNode(.float))
    let node2 = FlowNode(kind: .valueNode(.float))
    um.withGroup { flow.addNode(node1, undoManager: um) }
    um.withGroup { flow.addNode(node2, undoManager: um) }
    #expect(flow.nodes.count == 2)
    um.withGroup { flow.removeNode(node2.id, undoManager: um) }
    #expect(flow.nodes.count == 1)
    #expect(flow.nodes[node1.id] == node1)
    #expect(flow.nodes[node2.id] == nil)
    um.undo()
    #expect(flow.nodes.count == 2)
    #expect(flow.nodes[node1.id] == node1)
    #expect(flow.nodes[node2.id] == node2)
    um.redo()
    #expect(flow.nodes.count == 1)
    #expect(flow.nodes[node1.id] == node1)
    #expect(flow.nodes[node2.id] == nil)
    um.undo()
    um.undo()
    #expect(flow.nodes.count == 1)
    #expect(flow.nodes[node1.id] == node1)
    #expect(flow.nodes[node2.id] == nil)
    um.undo()
    #expect(flow.nodes.count == 0)
    um.redo()
    #expect(flow.nodes.count == 1)
    #expect(flow.nodes[node1.id] == node1)
    #expect(flow.nodes[node2.id] == nil)
    um.redo()
    #expect(flow.nodes.count == 2)
    #expect(flow.nodes[node1.id] == node1)
    #expect(flow.nodes[node2.id] == node2)
}

@MainActor
@Test(
    "`updateNode` should correctly modify a node from `nodes`, `undo` should restore the previous value, and `redo` update again."
)
func testUpdateNodeUndoRedo() {
    let flow = Flow()
    let id = UUID()
    let node = FlowNode(kind: .addNode(.vector2))
    let node1 = FlowNode(id: id, kind: .valueNode(.float))
    let node2 = FlowNode(id: id, kind: .valueNode(.int))
    um.withGroup { flow.addNode(node, undoManager: um) }
    um.withGroup { flow.addNode(node1, undoManager: um) }
    #expect(flow.nodes.count == 2)
    #expect(flow.nodes[id] == node1)
    #expect(flow.nodes[node.id] == node)
    um.withGroup { flow.updateNode(node2, undoManager: um) }
    #expect(flow.nodes.count == 2)
    #expect(flow.nodes[id] == node2)
    #expect(flow.nodes[node.id] == node)
    um.undo()
    #expect(flow.nodes.count == 2)
    #expect(flow.nodes[id] == node1)
    #expect(flow.nodes[node.id] == node)
    um.redo()
    #expect(flow.nodes.count == 2)
    #expect(flow.nodes[id] == node2)
    #expect(flow.nodes[node.id] == node)
}

@MainActor
@Test("`addEdge` should correctly add an edge, and `undo` should remove it.")
func testAddEdgeUndo() {
    let flow = Flow()
    #expect(flow.edges.isEmpty)
    let edge = Edge(.init(node: .init(), port: .output(0)), .init(node: .init(), port: .input(0)))!
    um.withGroup { flow.addEdge(edge, undoManager: um) }
    #expect(flow.edges.count == 1)
    #expect(flow.edges.contains(edge))
    um.undo()
    #expect(flow.edges.isEmpty)
}

@MainActor
@Test("`removeEdge` should correctly add an edge")
func testRemoveEdgeUndo() {
    let flow = Flow()
    #expect(flow.edges.isEmpty)
    let edge = Edge(.init(node: .init(), port: .output(0)), .init(node: .init(), port: .input(0)))!
    um.withGroup { flow.addEdge(edge, undoManager: um) }
    #expect(flow.edges.count == 1)
    #expect(flow.edges.contains(edge))
    um.withGroup { flow.removeEdge(edge, undoManager: um) }
    #expect(flow.edges.isEmpty)
    um.undo()
    #expect(flow.edges.count == 1)
    #expect(flow.edges.contains(edge))
    um.redo()
    #expect(flow.edges.isEmpty)
    um.undo()
    #expect(flow.edges.count == 1)
    #expect(flow.edges.contains(edge))
    um.undo()
    #expect(flow.edges.isEmpty)
}
