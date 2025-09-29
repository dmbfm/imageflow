import Backend
import CoreGraphics
import Foundation
import Testing
import Values

@testable import ImageFlowKit

import struct ImageFlowKit.Edge
import class ImageFlowKit.Flow

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

@MainActor
func makeFlow(_ nodes: [NodeKind], _ edges: [((Int, Int), (Int, Int))] = []) -> (Flow, [UUID]) {
    var ids = [UUID]()
    let flow = Flow()
    for kind in nodes {
        let id = UUID()
        flow.nodes[id] = .init(id: id, kind: kind)
        ids.append(id)
    }
    for edge in edges {
        let source = edge.0
        let dest = edge.1
        let sourceId = ids[source.0]
        let destId = ids[dest.0]
        var sourceNode = flow.nodes[sourceId]!
        var destNode = flow.nodes[destId]!

        sourceNode[connectedAt: .output(source.1)] = true
        destNode[connectedAt: .input(dest.1)] = true

        flow.nodes[sourceNode.id] = sourceNode
        flow.nodes[destNode.id] = destNode

        flow.edges.insert(
            Edge(
                .init(
                    node: sourceNode.id,
                    port: .output(source.1)
                ),
                .init(
                    node: destNode.id,
                    port: .input(dest.1)
                )
            )!
        )
    }
    return (flow, ids)
}

extension Edge {
    init(_ pairs: ((UUID, Int), (UUID, Int))) {
        self.init(.init(node: pairs.0.0, port: .output(pairs.0.1)), .init(node: pairs.1.0, port: .input(pairs.1.1)))!
    }
}

extension Collection where Element == UUID, Index == Int {
    func edge(src: (Int, Int), dst: (Int, Int)) -> Edge {
        .init(.init(node: self[src.0], port: .output(src.1)), .init(node: self[dst.0], port: .input(dst.1)))!
    }
}
// MARK: - Node Positions

@MainActor
@Test("nodePositions should correctly return the positions of the nodes")
func testNodePositions() {
    let ids: [UUID] = (0..<5).map { _ in UUID() }
    let positions = [CGPoint(x: 0, y: 0), .init(x: 100, y: 0), .init(x: 200, y: 0), .init(x: 300, y: 0), .init(x: 400, y: 0)]
    let flow = Flow()
    for (index, id) in ids.enumerated() {
        flow.addNode(.init(id: id, kind: .valueNode(.float), position: positions[index]))
    }
    
    #expect(flow.nodePositions == .init(uniqueKeysWithValues: zip(ids, positions)))
}

// MARK: - Nodes, Ports and Edges - Querying

@MainActor
@Test
func testIsValidPort() {
    let (flow, ids) = makeFlow([.valueNode(.float), .valueNode(.float), .addNode(.float)], [])
    #expect(flow.isValidPort(.init(node: ids[0], port: .input(0))))
    #expect(flow.isValidPort(.init(node: ids[0], port: .output(0))))
    #expect(!flow.isValidPort(.init(node: ids[0], port: .output(1))))
    #expect(flow.isValidPort(.init(node: ids[1], port: .input(0))))
    #expect(flow.isValidPort(.init(node: ids[1], port: .output(0))))
    #expect(!flow.isValidPort(.init(node: ids[1], port: .output(1))))
    #expect(flow.isValidPort(.init(node: ids[2], port: .input(0))))
    #expect(flow.isValidPort(.init(node: ids[2], port: .input(1))))
    #expect(flow.isValidPort(.init(node: ids[2], port: .output(0))))
    #expect(!flow.isValidPort(.init(node: ids[2], port: .output(1))))
    #expect(!flow.isValidPort(.init(node: UUID(), port: .output(0))))
}

@MainActor
@Test
func testHasNode() {
    let (flow, ids) = makeFlow(.init(repeating: .valueNode(.float), count: 50))
    for id in ids {
        #expect(flow.hasNode(id))
    }
    #expect(!flow.hasNode(UUID()))
}

@MainActor
@Test
func testEdgesOfNode() {
    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.float),
            .addNode(.float),
        ],
        [
            ((0, 0), (2, 0)),
            ((1, 0), (2, 1)),
        ]
    )

    #expect(Set(flow.edges(ofNode: ids[0])) == Set([ids.edge(src: (0, 0), dst: (2, 0))]))
    #expect(Set(flow.edges(ofNode: ids[1])) == Set([ids.edge(src: (1, 0), dst: (2, 1))]))
    #expect(
        Set(flow.edges(ofNode: ids[2]))
            == Set([ids.edge(src: (1, 0), dst: (2, 1)), ids.edge(src: (0, 0), dst: (2, 0))])
    )
}

@MainActor
@Test
func testNumberOfEdgesOfNode() {
    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.float),
            .addNode(.float),
        ],
        [
            ((0, 0), (2, 0)),
            ((1, 0), (2, 1)),
        ]
    )

    #expect(flow.numberOfEdges(ofNode: ids[0]) == 1)
    #expect(flow.numberOfEdges(ofNode: ids[1]) == 1)
    #expect(flow.numberOfEdges(ofNode: ids[2]) == 2)
}

@MainActor
@Test
func testEdgesOfPort() {
    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.float),
            .addNode(.float),
        ],
        [
            ((0, 0), (2, 0)),
            ((1, 0), (2, 1)),
        ]
    )

    #expect(Set(flow.edges(ofPort: .init(node: ids[0], port: .output(0)))) == Set([ids.edge(src: (0, 0), dst: (2, 0))]))
    #expect(Set(flow.edges(ofPort: .init(node: ids[0], port: .input(0)))) == [])
    #expect(Set(flow.edges(ofPort: .init(node: ids[1], port: .output(0)))) == Set([ids.edge(src: (1, 0), dst: (2, 1))]))
    #expect(Set(flow.edges(ofPort: .init(node: ids[1], port: .input(0)))) == [])
    #expect(Set(flow.edges(ofPort: .init(node: ids[2], port: .input(0)))) == Set([ids.edge(src: (0, 0), dst: (2, 0))]))
    #expect(Set(flow.edges(ofPort: .init(node: ids[2], port: .input(1)))) == Set([ids.edge(src: (1, 0), dst: (2, 1))]))
    #expect(Set(flow.edges(ofPort: .init(node: ids[2], port: .output(0)))) == [])
}

@MainActor
@Test
func testNumberEdgesOfPort() {
    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.float),
            .addNode(.float),
        ],
        [
            ((0, 0), (2, 0)),
            ((1, 0), (2, 1)),
        ]
    )

    #expect(flow.numberOfEdges(ofPort: .init(node: ids[0], port: .output(0))) == 1)
    #expect(flow.numberOfEdges(ofPort: .init(node: ids[0], port: .input(0))) == 0)
    #expect(flow.numberOfEdges(ofPort: .init(node: ids[1], port: .output(0))) == 1)
    #expect(flow.numberOfEdges(ofPort: .init(node: ids[1], port: .input(0))) == 0)
    #expect(flow.numberOfEdges(ofPort: .init(node: ids[2], port: .input(0))) == 1)
    #expect(flow.numberOfEdges(ofPort: .init(node: ids[2], port: .input(1))) == 1)
    #expect(flow.numberOfEdges(ofPort: .init(node: ids[2], port: .output(0))) == 0)
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

// MARK: - Nodes, Ports and Edges - Complex Actions

@MainActor
@Test("`newNodeAction` should create a new node and register undo item")
func newNodeActionShouldCreateNewNode() {
    let flow = Flow()
    um.withGroup {
        flow.newNodeAction(.init(kind: .valueNode(.float)), undoManager: um)
    }
    #expect(flow.nodes.count == 1)
    #expect(um.canUndo)
}

@MainActor
@Test("`newNodeAction` should be able to undo its operation")
func newNodeActionShouldUndo() {
    let flow = Flow()
    um.withGroup {
        flow.newNodeAction(.init(kind: .valueNode(.float)), undoManager: um)
    }
    #expect(flow.nodes.count == 1)
    #expect(um.canUndo)
    um.undo()
    #expect(flow.nodes.isEmpty)
}

@MainActor
@Test("`newNodeAction` should be able to undo its operation then redo it")
func newNodeActionShouldUndoThenRedo() {
    let flow = Flow()
    um.withGroup {
        flow.newNodeAction(.init(kind: .valueNode(.float)), undoManager: um)
    }
    #expect(flow.nodes.count == 1)
    #expect(um.canUndo)
    um.undo()
    #expect(flow.nodes.isEmpty)
    #expect(um.canRedo)
    um.redo()
    #expect(flow.nodes.count == 1)
    #expect(um.canUndo)
}

@MainActor
@Test("`deleteNodeAction` should delete a node and register a undo item")
func deletNodeActionShouldDeleteNode() {
    let flow = Flow()
    let id = UUID()
    flow.newNodeAction(.init(id: id, kind: .valueNode(.float)), undoManager: nil)
    #expect(flow.nodes.count == 1)
    um.withGroup {
        flow.deleteNodeAction(id, undoManager: um)
    }
    #expect(um.canUndo)
    #expect(flow.nodes.isEmpty)
}

@MainActor
@Test("`deleteNodeAction` should be able to undo its operation.")
func deletNodeActionShouldUndo() {
    let flow = Flow()
    let id = UUID()
    flow.newNodeAction(.init(id: id, kind: .valueNode(.float)), undoManager: nil)
    #expect(flow.nodes.count == 1)
    um.withGroup {
        flow.deleteNodeAction(id, undoManager: um)
    }
    #expect(um.canUndo)
    #expect(flow.nodes.isEmpty)
    um.undo()
    #expect(flow.nodes.count == 1)
}

@MainActor
@Test("`deleteNodeAction` should be able to undo its operation and then redo it.")
func deletNodeActionShouldUndoThenRedo() {
    let flow = Flow()
    let id = UUID()
    flow.newNodeAction(.init(id: id, kind: .valueNode(.float)), undoManager: nil)
    #expect(flow.nodes.count == 1)
    um.withGroup {
        flow.deleteNodeAction(id, undoManager: um)
    }
    #expect(um.canUndo)
    #expect(flow.nodes.isEmpty)
    um.undo()
    #expect(flow.nodes.count == 1)
    um.redo()
    #expect(flow.nodes.isEmpty)
}

@MainActor
@Test("`deleteEdgeAction` should delete an edge and register a undo item.")
func deleteEdgeActionShouldRegisterUndo() {
    let (flow, ids) = makeFlow(
        [.valueNode(.float), .valueNode(.float)],
        [((0, 0), (1, 0))]
    )
    let edge = Edge(.init(node: ids[0], port: .output(0)), .init(node: ids[1], port: .input(0)))!
    #expect(flow.edges.contains(edge))
    um.withGroup {
        flow.deleteEdgeAction(edge, undoManager: um)
    }
    #expect(flow.edges.isEmpty)
    #expect(um.canUndo)
}

@MainActor
@Test("`deleteEdgeAction` should corretly undo")
func deleteEdgeActionShouldUndo() {
    let (flow, ids) = makeFlow(
        [.valueNode(.float), .valueNode(.float)],
        [((0, 0), (1, 0))]
    )
    let edge = Edge(.init(node: ids[0], port: .output(0)), .init(node: ids[1], port: .input(0)))!
    #expect(flow.edges.contains(edge))
    um.withGroup {
        flow.deleteEdgeAction(edge, undoManager: um)
    }
    #expect(flow.edges.isEmpty)
    #expect(um.canUndo)
    um.undo()
    #expect(flow.edges.contains(edge))
}

@MainActor
@Test("`deleteEdgeAction` should corretly undo")
func deleteEdgeActionShouldUndoThenRedo() {
    let (flow, ids) = makeFlow(
        [.valueNode(.float), .valueNode(.float)],
        [((0, 0), (1, 0))]
    )
    let edge = Edge(.init(node: ids[0], port: .output(0)), .init(node: ids[1], port: .input(0)))!
    #expect(flow.edges.contains(edge))
    um.withGroup {
        flow.deleteEdgeAction(edge, undoManager: um)
    }
    #expect(flow.edges.isEmpty)
    #expect(um.canUndo)
    um.undo()
    #expect(flow.edges.contains(edge))
    um.redo()
    #expect(flow.edges.isEmpty)
}

@MainActor
@Test("`newEdgeAction` should create a new edge, mark ports as connected, and register an undo item.")
func newEdgeActionShouldCreateNewEdge() {
    let (flow, ids) = makeFlow(
        [.valueNode(.float), .valueNode(.float)],
        []
    )
    let edge = Edge(.init(node: ids[0], port: .output(0)), .init(node: ids[1], port: .input(0)))!
    #expect(flow.edges.isEmpty)
    #expect(!flow.nodes[ids[0]]!.outputs[0].connected)
    #expect(!flow.nodes[ids[1]]!.inputs[0].connected)
    um.withGroup {
        flow.newEdgeAction(edge, undoManager: um)
    }
    #expect(um.canUndo)
    #expect(flow.edges.contains(edge))
    #expect(flow.nodes[ids[0]]!.outputs[0].connected)
    #expect(flow.nodes[ids[1]]!.inputs[0].connected)
}

@MainActor
@Test("`newEdgeAction` should corretly undo.")
func newEdgeActionShouldUndo() {
    let (flow, ids) = makeFlow(
        [.valueNode(.float), .valueNode(.float)],
        []
    )
    let edge = Edge(.init(node: ids[0], port: .output(0)), .init(node: ids[1], port: .input(0)))!
    #expect(flow.edges.isEmpty)
    #expect(!flow.nodes[ids[0]]!.outputs[0].connected)
    #expect(!flow.nodes[ids[1]]!.inputs[0].connected)
    um.withGroup {
        flow.newEdgeAction(edge, undoManager: um)
    }
    #expect(flow.edges.contains(edge))
    #expect(flow.nodes[ids[0]]!.outputs[0].connected)
    #expect(flow.nodes[ids[1]]!.inputs[0].connected)
    #expect(um.canUndo)
    um.undo()
    #expect(flow.edges.isEmpty)
    #expect(!flow.nodes[ids[0]]!.outputs[0].connected)
    #expect(!flow.nodes[ids[1]]!.inputs[0].connected)
}

@MainActor
@Test("`newEdgeAction` should corretly undo then redo.")
func newEdgeActionShouldUndoThenRedo() {
    let (flow, ids) = makeFlow(
        [.valueNode(.float), .valueNode(.float)],
        []
    )
    let edge = Edge(.init(node: ids[0], port: .output(0)), .init(node: ids[1], port: .input(0)))!
    #expect(flow.edges.isEmpty)
    #expect(!flow.nodes[ids[0]]!.outputs[0].connected)
    #expect(!flow.nodes[ids[1]]!.inputs[0].connected)
    um.withGroup {
        flow.newEdgeAction(edge, undoManager: um)
    }
    #expect(um.canUndo)
    #expect(flow.nodes[ids[0]]!.outputs[0].connected)
    #expect(flow.nodes[ids[1]]!.inputs[0].connected)
    #expect(flow.edges.contains(edge))
    um.undo()
    #expect(flow.edges.isEmpty)
    #expect(!flow.nodes[ids[0]]!.outputs[0].connected)
    #expect(!flow.nodes[ids[1]]!.inputs[0].connected)
    um.redo()
    #expect(flow.edges.contains(edge))
    #expect(flow.nodes[ids[0]]!.outputs[0].connected)
    #expect(flow.nodes[ids[1]]!.inputs[0].connected)
}

// MARK: - Nodes, Ports and Edges - Validation

@MainActor
@Test("`hasCycles` should return true if a cycle is present")
func hasCyclesShouldDetectCycle() {

    let (flow, _) = makeFlow(
        [.valueNode(.float), .valueNode(.float)],
        [
            ((0, 0), (1, 0)),
            ((1, 0), (0, 0)),
        ]
    )

    #expect(flow.hasCycles())
}

@MainActor
@Test("`hasCycles` should return false if no cycle is present")
func hasCyclesWithoutCycles() {

    let (flow, _) = makeFlow(
        [.valueNode(.float), .valueNode(.float)],
        [
            ((0, 0), (1, 0))
        ]
    )

    #expect(!flow.hasCycles())
}

@MainActor
@Test("`hasCycles` should detect a long cycle")
func hasCyclesShouldDetectLongCycle() {

    let (flow, _) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
        ],
        [
            ((0, 0), (1, 0)),
            ((1, 0), (2, 0)),
            ((2, 0), (3, 0)),
            ((3, 0), (4, 0)),
            ((4, 0), (0, 0)),
        ]
    )

    #expect(flow.hasCycles())
}

@MainActor
@Test("`hasCycles` should detect a long cycle when adding edge")
func hasCyclesShouldDetectLongCycleAddingEdge() {

    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
        ],
        [
            ((0, 0), (1, 0)),
            ((1, 0), (2, 0)),
            ((2, 0), (3, 0)),
            ((3, 0), (4, 0)),
        ]
    )

    #expect(!flow.hasCycles())

    #expect(
        flow.hasCycles(addingEdge: .init(.init(node: ids[4], port: .output(0)), .init(node: ids[0], port: .input(0)))!)
            == true
    )
}

@MainActor
@Test("`hasCycles(addingEdge:)` should return false if the edge does not create cycles")
func hasCyclesAddingEdgeWithoutCytle() {

    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
        ],
        [
            ((0, 0), (1, 0)),
            ((1, 0), (2, 0)),
            ((2, 0), (3, 0)),
            // ((3, 0), (4, 0)),
        ]
    )

    #expect(!flow.hasCycles())

    #expect(
        flow.hasCycles(addingEdge: .init(.init(node: ids[3], port: .output(0)), .init(node: ids[4], port: .input(0)))!)
            == false
    )
}

@MainActor
@Test("`typeCheckEdge` should return `.success` if the port types of the edge are the same.")
func testTypeCheckEdgeSameTypes() {
    let (flow, _) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.float),
        ],
        [
            ((0, 0), (1, 0))
        ]
    )

    switch flow.typeCheckEdge(flow.edges.first!) {
    case .failure(_):
        #expect(Bool(false))
    case .success(()):
        break
    }
}

@MainActor
@Test("`typeCheckEdge` should return `.success` if the port types of the edge are the same.")
func testTypeCheckEdgeDifferentTypesConvert() {
    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.int),
        ],
        []
    )

    switch flow.typeCheckEdge(.init(((ids[0], 0), (ids[1], 0)))) {
    case .failure(let fix):
        #expect(fix == .fixable(.canFixConvertingDestNodeTo(.valueNode(.float))))
    case .success(()):
        #expect(Bool(false), ".success")
    }
}

@MainActor
@Test("`typeCheckEdge` should return `.success` if the port types of the edge are the same.")
func testTypeCheckEdgeDifferentTypesNoFix() {
    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.int),
            .addNode(.int),
            .addNode(.float),
        ],
        [
            ((1, 0), (2, 0)),
            ((0, 0), (3, 0)),
        ]
    )

    switch flow.typeCheckEdge(.init(((ids[0], 0), (ids[1], 0)))) {
    case .failure(let fix):
        #expect(fix == .cantFix)
    case .success(()):
        #expect(Bool(false), ".success")
    }
}

@MainActor
@Test("`typeCheckEdge` should return `.success` if the port types of the edge are the same.")
func newEdgeWithTypeErrorFixActionTest() {
    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.int),
        ],
        []
    )

    let edge = ids.edge(src: (0, 0), dst: (1, 0))

    switch flow.typeCheckEdge(edge) {
    case .failure(let fix):
        #expect(fix == .fixable(.canFixConvertingDestNodeTo(.valueNode(.float))))
        flow.newEdgeWithTypeErrorFixAction(edge, .canFixConvertingDestNodeTo(.valueNode(.float)), undoManager: nil)
        #expect(flow.edges.contains(edge))
        #expect(flow.nodes[ids[1]]!.kind == .valueNode(.float))
        #expect(flow.nodes[ids[0]]!.kind == .valueNode(.float))
        #expect(flow.nodes[ids[0]]!.outputs[0].connected)
        #expect(flow.nodes[ids[1]]!.inputs[0].connected)

    case .success(()):
        #expect(Bool(false), ".success")
    }
}

@MainActor
@Test("`canCreateEdge: fail with invalid source port`")
func canCreateEdgeFailWithInvaildSourcePort() {
    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.int),
        ],
        []
    )

    let edge = ids.edge(src: (0, 10), dst: (1, 0))

    let result = flow.canCreateEdge(edge)
    switch result {
    case .failure(.invalidPort(let loc)):
        #expect(loc == .init(node: ids[0], port: .output(10)))
        break
    default:
        #expect(Bool(false), "\(result)")
    }
}

@MainActor
@Test("`canCreateEdge: fail with invalid destination port`")
func canCreateEdgeFailWithInvaildDestPort() {
    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.int),
        ],
        []
    )

    let edge = ids.edge(src: (0, 0), dst: (1, 10))

    let result = flow.canCreateEdge(edge)
    switch result {
    case .failure(.invalidPort(let loc)):
        #expect(loc == .init(node: ids[1], port: .input(10)))
        break
    default:
        #expect(Bool(false), "\(result)")
    }
}

@MainActor
@Test("`canCreateEdge: fail with destination port already connected`")
func canCreateEdgeFailWithDestPortAlreadyConnected() {
    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.int),
        ],
        []
    )

    let edge = ids.edge(src: (0, 0), dst: (1, 0))

    flow.nodes[ids[1]]!.inputs[0].connected = true

    let result = flow.canCreateEdge(edge)
    switch result {
    case .failure(.destPortAlreadyConnected):
        break
    default:
        #expect(Bool(false), "\(result)")
    }
}

@MainActor
@Test("`canCreateEdge: fail with fixable type error`")
func canCreateEdgeFailWithTypeErrorFix() {
    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.int),
        ],
        []
    )

    let edge = ids.edge(src: (0, 0), dst: (1, 0))

    let result = flow.canCreateEdge(edge)
    switch result {
    case .failure(.typeError(.fixable(.canFixConvertingDestNodeTo))):
        break
    default:
        #expect(Bool(false), "\(result)")
    }
}

@MainActor
@Test("`canCreateEdge: fail with not fixable type error`")
func canCreateEdgeFailWithTypeErrorCantFix() {
    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.int),
            .addNode(.int),
            .addNode(.float),
        ],
        [
            ((1, 0), (2, 0)),
            ((0, 0), (3, 0)),
        ]
    )
    // ((ids[0], 0), (ids[1], 0))
    let edge = ids.edge(src: (0, 0), dst: (1, 0))

    let result = flow.canCreateEdge(edge)
    switch result {
    case .failure(.typeError(.cantFix)):
        break
    default:
        #expect(Bool(false), "\(result)")
    }
}

@MainActor
@Test("`canCreateEdge: fail with cycle`")
func canCreateEdgeFailWithCycle() {
    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
        ],
        [
            ((0, 0), (1, 0)),
            ((1, 0), (2, 0)),
            ((2, 0), (3, 0)),
            ((3, 0), (4, 0)),
        ]
    )

    let edge = ids.edge(src: (4, 0), dst: (0, 0))
    let result = flow.canCreateEdge(edge)
    switch result {
    case .failure(.graphCycle):
        break
    default:
        #expect(Bool(false), "\(result)")
    }
}

// MARK: - Node Properties

@MainActor
@Test
func getPortConnectedTest() {

    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
        ],
        [
            ((0, 0), (1, 0)),
            ((1, 0), (2, 0)),
            ((2, 0), (3, 0)),
            ((3, 0), (4, 0)),
        ]
    )

    #expect(flow.getPortConnected(.init(node: ids[0], port: .output(0))))
    #expect(!flow.getPortConnected(.init(node: ids[0], port: .input(0))))
}

@MainActor
@Test
func getPortTypeTest() {

    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.int),
        ]
    )

    #expect(flow.getPortType(.init(node: ids[0], port: .output(0))) == .float)
    #expect(flow.getPortType(.init(node: ids[0], port: .input(0))) == .float)
    #expect(flow.getPortType(.init(node: ids[1], port: .output(0))) == .int)
    #expect(flow.getPortType(.init(node: ids[1], port: .input(0))) == .int)
}

@MainActor
@Test
func setPortConnectedTest() {

    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
        ],
        [
            ((0, 0), (1, 0)),
            ((1, 0), (2, 0)),
            ((2, 0), (3, 0)),
            ((3, 0), (4, 0)),
        ]
    )

    flow.setNodePortConnected(.init(node: ids[0], port: .output(0)), false)
    flow.setNodePortConnected(.init(node: ids[0], port: .input(0)), true)
    #expect(!flow.getPortConnected(.init(node: ids[0], port: .output(0))))
    #expect(flow.getPortConnected(.init(node: ids[0], port: .input(0))))
}

// MARK: - Node Properties (Undo)

@MainActor
@Test
func setPortConnectedUndoTest() {

    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
            .valueNode(.float),
        ],
        [
            ((0, 0), (1, 0)),
            ((1, 0), (2, 0)),
            ((2, 0), (3, 0)),
            ((3, 0), (4, 0)),
        ]
    )

    um.withGroup {
        flow.setNodePortConnected(.init(node: ids[0], port: .output(0)), false, undoManager: um)
    }
    um.withGroup {
        flow.setNodePortConnected(.init(node: ids[0], port: .input(0)), true, undoManager: um)
    }
    #expect(!flow.getPortConnected(.init(node: ids[0], port: .output(0))))
    #expect(flow.getPortConnected(.init(node: ids[0], port: .input(0))))

    um.undo()
    #expect(!flow.getPortConnected(.init(node: ids[0], port: .input(0))))
    #expect(!flow.getPortConnected(.init(node: ids[0], port: .output(0))))
    um.undo()
    #expect(!flow.getPortConnected(.init(node: ids[0], port: .input(0))))
    #expect(flow.getPortConnected(.init(node: ids[0], port: .output(0))))
}
