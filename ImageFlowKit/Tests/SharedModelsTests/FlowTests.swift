import Backend
import CoreGraphics
import Foundation
import Testing
import Values

import struct SharedModels.Edge
import class SharedModels.Flow

@testable import SharedModels

// MARK: - Helpers

@MainActor
let undoService: UndoService = {
    let um = UndoManager()
    um.groupsByEvent = false
    let undoService = UndoService(um)
    return undoService
}()

@MainActor
var um: UndoManager { undoService.undoManager! }

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
        flow.nodePositions[id] = .zero
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

        try! flow.edges.insert(
            Edge.fromPorts(
                .init(
                    node: sourceNode.id,
                    port: .output(source.1)
                ),
                .init(
                    node: destNode.id,
                    port: .input(dest.1)
                )
            ).get()
        )
    }
    return (flow, ids)
}

extension Edge {
    init(_ pairs: ((UUID, Int), (UUID, Int))) {
        self =
            try! Edge.fromPorts(
                .init(node: pairs.0.0, port: .output(pairs.0.1)),
                .init(node: pairs.1.0, port: .input(pairs.1.1))
            ).get()
    }
}

extension Collection where Element == UUID, Index == Int {
    func edge(src: (Int, Int), dst: (Int, Int)) -> Edge {
        try! Edge.fromPorts(
            .init(node: self[src.0], port: .output(src.1)),
            .init(node: self[dst.0], port: .input(dst.1))
        ).get()
    }
}
// MARK: - Node Positions

@MainActor
@Test("nodePositions should correctly return the positions of the nodes")
func testNodePositions() {
    let ids: [UUID] = (0..<5).map { _ in UUID() }
    let positions = [
        CGPoint(x: 0, y: 0), .init(x: 100, y: 0), .init(x: 200, y: 0), .init(x: 300, y: 0), .init(x: 400, y: 0),
    ]
    let flow = Flow()
    for (index, id) in ids.enumerated() {
        flow.addNode(.init(id: id, kind: .valueNode(.float)), at: positions[index])
    }

    #expect(flow.nodePositions == .init(uniqueKeysWithValues: zip(ids, positions)))
}

// MARK: - Nodes, Ports and Edges - Querying

@MainActor
@Test
func testIsValidPort() {
    let (flow, ids) = makeFlow([.valueNode(.float), .valueNode(.float), .math(.addNode(.float))], [])
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
            .math(.addNode(.float)),
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
            .math(.addNode(.float)),
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
            .math(.addNode(.float)),
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
            .math(.addNode(.float)),
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
    flow.addNode(node, at: .zero)
    #expect(flow.nodes.count == 1)
    #expect(flow.nodes[node.id] == node)
}

@MainActor
@Test("`removeNode` should correctly remove one node from `nodes`")
func testRemoveNode() {
    let flow = Flow()
    let node1 = FlowNode(kind: .valueNode(.float))
    let node2 = FlowNode(kind: .valueNode(.float))
    flow.addNode(node1, at: .zero)
    flow.addNode(node2, at: .zero)
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
    let node = FlowNode(kind: .math(.addNode(.vector2)))
    let node1 = FlowNode(id: id, kind: .valueNode(.float))
    let node2 = FlowNode(id: id, kind: .valueNode(.int))
    flow.addNode(node, at: .zero)
    flow.addNode(node1, at: .zero)
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
    let edge = try! Edge.fromPorts(.init(node: .init(), port: .output(0)), .init(node: .init(), port: .input(0))).get()
    flow.addEdge(edge)
    #expect(flow.edges.count == 1)
    #expect(flow.edges.contains(edge))
}

@MainActor
@Test("`removeEdge` should correctly add an edge")
func testRemoveEdge() throws {
    let flow = Flow()
    #expect(flow.edges.isEmpty)
    let edge = try Edge.fromPorts(.init(node: .init(), port: .output(0)), .init(node: .init(), port: .input(0))).get()
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
    um.withGroup { flow.addNode(node, at: .zero, undoService: undoService) }
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
    um.withGroup { flow.addNode(node1, at: .zero, undoService: undoService) }
    um.withGroup { flow.addNode(node2, at: .zero, undoService: undoService) }
    #expect(flow.nodes.count == 2)
    um.withGroup { flow.removeNode(node2.id, undoService: undoService) }
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
    um.withGroup { flow.addNode(node1, at: .zero, undoService: undoService) }
    um.withGroup { flow.addNode(node2, at: .zero, undoService: undoService) }
    #expect(flow.nodes.count == 2)
    um.withGroup { flow.removeNode(node2.id, undoService: undoService) }
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
    let node = FlowNode(kind: .math(.addNode(.vector2)))
    let node1 = FlowNode(id: id, kind: .valueNode(.float))
    let node2 = FlowNode(id: id, kind: .valueNode(.int))
    um.withGroup { flow.addNode(node, at: .zero, undoService: undoService) }
    um.withGroup { flow.addNode(node1, at: .zero, undoService: undoService) }
    #expect(flow.nodes.count == 2)
    #expect(flow.nodes[id] == node1)
    #expect(flow.nodes[node.id] == node)
    um.withGroup { flow.updateNode(node2, undoService: undoService) }
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
func testAddEdgeUndo() throws {
    let flow = Flow()
    #expect(flow.edges.isEmpty)
    let edge = try Edge.fromPorts(.init(node: .init(), port: .output(0)), .init(node: .init(), port: .input(0))).get()
    um.withGroup { flow.addEdge(edge, undoService: undoService) }
    #expect(flow.edges.count == 1)
    #expect(flow.edges.contains(edge))
    um.undo()
    #expect(flow.edges.isEmpty)
}

@MainActor
@Test("`removeEdge` should correctly add an edge")
func testRemoveEdgeUndo() throws {
    let flow = Flow()
    #expect(flow.edges.isEmpty)
    let edge = try Edge.fromPorts(.init(node: .init(), port: .output(0)), .init(node: .init(), port: .input(0))).get()
    um.withGroup { flow.addEdge(edge, undoService: undoService) }
    #expect(flow.edges.count == 1)
    #expect(flow.edges.contains(edge))
    um.withGroup { flow.removeEdge(edge, undoService: undoService) }
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
    um.removeAllActions()
    let flow = Flow()
    um.withGroup {
        flow.newNodeAction(.init(kind: .valueNode(.float)), at: .zero, undoService: undoService)
    }
    #expect(flow.nodes.count == 1)
    #expect(um.canUndo)
}

@MainActor
@Test("`newNodeAction` should be able to undo its operation")
func newNodeActionShouldUndo() {
    um.removeAllActions()
    let flow = Flow()
    um.withGroup {
        flow.newNodeAction(.init(kind: .valueNode(.float)), at: .zero, undoService: undoService)
    }
    #expect(flow.nodes.count == 1)
    #expect(um.canUndo)
    um.undo()
    #expect(flow.nodes.isEmpty)
}

@MainActor
@Test("`newNodeAction` should be able to undo its operation then redo it")
func newNodeActionShouldUndoThenRedo() {
    um.removeAllActions()
    let flow = Flow()
    um.withGroup {
        flow.newNodeAction(.init(kind: .valueNode(.float)), at: .zero, undoService: undoService)
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
    um.removeAllActions()
    let flow = Flow()
    let id = UUID()
    flow.newNodeAction(.init(id: id, kind: .valueNode(.float)), at: .zero, undoService: nil)
    #expect(flow.nodes.count == 1)
    um.withGroup {
        flow.deleteNodeAction(id, undoService: undoService)
    }
    #expect(um.canUndo)
    #expect(flow.nodes.isEmpty)
}

@MainActor
@Test("`deleteNodeAction` should be able to undo its operation.")
func deletNodeActionShouldUndo() {
    um.removeAllActions()
    let flow = Flow()
    let id = UUID()
    flow.newNodeAction(.init(id: id, kind: .valueNode(.float)), at: .zero, undoService: nil)
    #expect(flow.nodes.count == 1)
    um.withGroup {
        flow.deleteNodeAction(id, undoService: undoService)
    }
    #expect(um.canUndo)
    #expect(flow.nodes.isEmpty)
    um.undo()
    #expect(flow.nodes.count == 1)
}

@MainActor
@Test("`deleteNodeAction` should be able to undo its operation and then redo it.")
func deletNodeActionShouldUndoThenRedo() {
    um.removeAllActions()
    let flow = Flow()
    let id = UUID()
    flow.newNodeAction(.init(id: id, kind: .valueNode(.float)), at: .zero, undoService: nil)
    #expect(flow.nodes.count == 1)
    um.withGroup {
        flow.deleteNodeAction(id, undoService: undoService)
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
func deleteEdgeActionShouldRegisterUndo() throws {
    um.removeAllActions()
    let (flow, ids) = makeFlow(
        [.valueNode(.float), .valueNode(.float)],
        [((0, 0), (1, 0))]
    )
    let edge = try Edge.fromPorts(.init(node: ids[0], port: .output(0)), .init(node: ids[1], port: .input(0))).get()
    #expect(flow.edges.contains(edge))
    um.withGroup {
        flow.deleteEdgeAction(edge, undoService: undoService)
    }
    #expect(flow.edges.isEmpty)
    #expect(um.canUndo)
}

@MainActor
@Test("`deleteEdgeAction` should disconnect node ports")
func deleteEdgeActionShouldDisconnectPorts() throws {
    um.removeAllActions()
    let (flow, ids) = makeFlow(
        [.valueNode(.float), .valueNode(.float)],
        [((0, 0), (1, 0))]
    )
    let src = PortLocation(node: ids[0], port: .output(0))
    let dst = PortLocation(node: ids[1], port: .input(0))
    let edge = try Edge.fromPorts(src, dst).get()
    #expect(flow.edges.contains(edge))
    flow.deleteEdgeAction(edge, undoService: nil)
    #expect(flow.edges.isEmpty)
    #expect(!flow.getPortConnected(src))
    #expect(!flow.getPortConnected(dst))
}

@MainActor
@Test("`deleteEdgeAction` should not disconnect output port with remaining edge")
func deleteEdgeActionShouldDisconnectPortsV2() throws {
    um.removeAllActions()
    let (flow, ids) = makeFlow(
        [.valueNode(.float), .valueNode(.float), .valueNode(.float)],
        [((0, 0), (1, 0)), ((0, 0), (2, 0))]
    )
    let src = PortLocation(node: ids[0], port: .output(0))
    let dst1 = PortLocation(node: ids[1], port: .input(0))
    let dst2 = PortLocation(node: ids[2], port: .input(0))
    let edge1 = try Edge.fromPorts(src, dst1).get()
    let edge2 = try Edge.fromPorts(src, dst2).get()
    #expect(flow.edges.contains(edge1))
    #expect(flow.edges.contains(edge2))
    flow.deleteEdgeAction(edge1, undoService: nil)
    #expect(!flow.edges.contains(edge1))
    #expect(flow.edges.contains(edge2))
    #expect(flow.getPortConnected(src))
    #expect(flow.getPortConnected(dst2))
    #expect(!flow.getPortConnected(dst1))
}

@MainActor
@Test("`deleteEdgeAction` should corretly undo")
func deleteEdgeActionShouldUndo() throws {
    um.removeAllActions()
    let (flow, ids) = makeFlow(
        [.valueNode(.float), .valueNode(.float)],
        [((0, 0), (1, 0))]
    )
    let edge = try Edge.fromPorts(.init(node: ids[0], port: .output(0)), .init(node: ids[1], port: .input(0))).get()
    #expect(flow.edges.contains(edge))
    um.withGroup {
        flow.deleteEdgeAction(edge, undoService: undoService)
    }
    #expect(flow.edges.isEmpty)
    #expect(um.canUndo)
    um.undo()
    #expect(flow.edges.contains(edge))
}

@MainActor
@Test("`deleteEdgeAction` should corretly undo")
func deleteEdgeActionShouldUndoThenRedo() throws {
    um.removeAllActions()
    let (flow, ids) = makeFlow(
        [.valueNode(.float), .valueNode(.float)],
        [((0, 0), (1, 0))]
    )
    let edge = try Edge.fromPorts(.init(node: ids[0], port: .output(0)), .init(node: ids[1], port: .input(0))).get()
    #expect(flow.edges.contains(edge))
    um.withGroup {
        flow.deleteEdgeAction(edge, undoService: undoService)
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
func newEdgeActionShouldCreateNewEdge() throws {
    um.removeAllActions()
    let (flow, ids) = makeFlow(
        [.valueNode(.float), .valueNode(.float)],
        []
    )
    let edge = try Edge.fromPorts(.init(node: ids[0], port: .output(0)), .init(node: ids[1], port: .input(0))).get()
    #expect(flow.edges.isEmpty)
    #expect(!flow.nodes[ids[0]]!.outputs[0].connected)
    #expect(!flow.nodes[ids[1]]!.inputs[0].connected)
    um.withGroup {
        flow.newEdgeAction(edge, undoService: undoService)
    }
    #expect(um.canUndo)
    #expect(flow.edges.contains(edge))
    #expect(flow.nodes[ids[0]]!.outputs[0].connected)
    #expect(flow.nodes[ids[1]]!.inputs[0].connected)
}

@MainActor
@Test("`newEdgeAction` should corretly undo.")
func newEdgeActionShouldUndo() throws {
    um.removeAllActions()
    let (flow, ids) = makeFlow(
        [.valueNode(.float), .valueNode(.float)],
        []
    )
    let edge = try Edge.fromPorts(.init(node: ids[0], port: .output(0)), .init(node: ids[1], port: .input(0))).get()
    #expect(flow.edges.isEmpty)
    #expect(!flow.nodes[ids[0]]!.outputs[0].connected)
    #expect(!flow.nodes[ids[1]]!.inputs[0].connected)
    um.withGroup {
        flow.newEdgeAction(edge, undoService: undoService)
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
func newEdgeActionShouldUndoThenRedo() throws {
    um.removeAllActions()
    let (flow, ids) = makeFlow(
        [.valueNode(.float), .valueNode(.float)],
        []
    )
    let edge = try Edge.fromPorts(.init(node: ids[0], port: .output(0)), .init(node: ids[1], port: .input(0))).get()
    #expect(flow.edges.isEmpty)
    #expect(!flow.nodes[ids[0]]!.outputs[0].connected)
    #expect(!flow.nodes[ids[1]]!.inputs[0].connected)
    um.withGroup {
        flow.newEdgeAction(edge, undoService: undoService)
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
func hasCyclesShouldDetectCycle() throws {

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
func hasCyclesWithoutCycles() throws {

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
func hasCyclesShouldDetectLongCycle() throws {

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
func hasCyclesShouldDetectLongCycleAddingEdge() throws {

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
        flow.hasCycles(
            addingEdge: try Edge.fromPorts(.init(node: ids[4], port: .output(0)), .init(node: ids[0], port: .input(0)))
                .get()
        )
            == true
    )
}

@MainActor
@Test("`hasCycles(addingEdge:)` should return false if the edge does not create cycles")
func hasCyclesAddingEdgeWithoutCytle() throws {

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
        flow.hasCycles(
            addingEdge: try Edge.fromPorts(.init(node: ids[3], port: .output(0)), .init(node: ids[4], port: .input(0)))
                .get()
        )
            == false
    )
}

@MainActor
@Test("`typeCheckEdge` should return `.success` if the port types of the edge are the same.")
func testTypeCheckEdgeSameTypes() throws {
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
@Test("`typeCheckEdge` should return `.cantFix` if the port types of the edge are not compatible.")
func testTypeCheckEdgeDifferentTypesNoFix() throws {
    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.matrix2x2),
            .math(.addNode(.matrix2x2)),
            .math(.addNode(.float)),
        ],
        [
            ((1, 0), (2, 0)),
            ((0, 0), (3, 0)),
        ]
    )

    switch flow.typeCheckEdge(.init(((ids[0], 0), (ids[1], 0)))) {
    case .failure(let fix):
        #expect(fix == .cantFix(from: .float, to: .matrix2x2))
    case .success(()):
        #expect(Bool(false), ".success")
    }
}

@MainActor
@Test("`canCreateEdge: fail with invalid source port`")
func canCreateEdgeFailWithInvaildSourcePort() throws {
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
func canCreateEdgeFailWithInvaildDestPort() throws {
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

// @MainActor
// @Test("`canCreateEdge: fail with destination port already connected`")
// func canCreateEdgeFailWithDestPortAlreadyConnected() throws {
//     let (flow, ids) = makeFlow(
//         [
//             .valueNode(.float),
//             .valueNode(.int),
//         ],
//         []
//     )

//     let edge = ids.edge(src: (0, 0), dst: (1, 0))

//     flow.nodes[ids[1]]!.inputs[0].connected = true

//     let result = flow.canCreateEdge(edge)
//     switch result {
//     case .failure(.destPortAlreadyConnected):
//         break
//     default:
//         #expect(Bool(false), "\(result)")
//     }
// }

@MainActor
@Test("`canCreateEdge: fail with not fixable type error`")
func canCreateEdgeFailWithTypeErrorCantFix() throws {
    let (flow, ids) = makeFlow(
        [
            .valueNode(.float),
            .valueNode(.matrix2x2),
            .math(.addNode(.matrix2x2)),
            .math(.addNode(.float)),
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
func canCreateEdgeFailWithCycle() throws {
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
func getPortConnectedTest() throws {

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
func getPortTypeTest() throws {

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
func setPortConnectedTest() throws {

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
func setPortConnectedUndoTest() throws {

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
        flow.setNodePortConnected(.init(node: ids[0], port: .output(0)), false, undoService: undoService)
    }
    um.withGroup {
        flow.setNodePortConnected(.init(node: ids[0], port: .input(0)), true, undoService: undoService)
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

// MARK: - Selection (Undo)

@MainActor
@Test("select a single node")
func selectASingleNodeTest() throws {
    let ids = (0..<10).map { _ in UUID() }
    let flow = Flow()
    for id in ids {
        flow.addNode(.init(id: id, kind: .valueNode(.float)), at: .zero)
    }
    #expect(flow.selection.isEmpty)
    flow.select([ids[5]])
    #expect(flow.selection.count == 1)
    #expect(flow.selection.contains(ids[5]))
}

@MainActor
@Test("select a single node (union)")
func selectASingleNodeUnionTest() throws {
    let ids = (0..<10).map { _ in UUID() }
    let flow = Flow()
    for id in ids {
        flow.addNode(.init(id: id, kind: .valueNode(.float)), at: .zero)
    }
    flow.selection = [ids[0], ids[1]]
    flow.select([ids[5]], mode: .union)
    #expect(flow.selection.count == 3)
    #expect(flow.selection.contains(ids[0]))
    #expect(flow.selection.contains(ids[1]))
    #expect(flow.selection.contains(ids[5]))
}

@MainActor
@Test("select multiple nodes")
func selectMultipleNodesTest() throws {

    let ids = (0..<10).map { _ in UUID() }
    let flow = Flow()
    for id in ids {
        flow.addNode(.init(id: id, kind: .valueNode(.float)), at: .zero)
    }
    flow.selection = [ids[0], ids[1]]
    flow.select([ids[5], ids[7], ids[9]], mode: .replace)
    #expect(flow.selection.count == 3)
    #expect(flow.selection.contains(ids[9]))
    #expect(flow.selection.contains(ids[7]))
    #expect(flow.selection.contains(ids[5]))
}

@MainActor
@Test("select multiple nodes (union)")
func selectMultipleNodesUnionTest() throws {

    let ids = (0..<10).map { _ in UUID() }
    let flow = Flow()
    for id in ids {
        flow.addNode(.init(id: id, kind: .valueNode(.float)), at: .zero)
    }
    flow.selection = [ids[0], ids[1]]
    flow.select([ids[5], ids[7], ids[9]], mode: .union)
    #expect(flow.selection.count == 5)
    #expect(flow.selection.contains(ids[0]))
    #expect(flow.selection.contains(ids[1]))
    #expect(flow.selection.contains(ids[9]))
    #expect(flow.selection.contains(ids[7]))
    #expect(flow.selection.contains(ids[5]))
}

@MainActor
@Test("live select replace")
func liveSelectTest() throws {

    let ids = (0..<10).map { _ in UUID() }
    let flow = Flow()
    for id in ids {
        flow.addNode(.init(id: id, kind: .valueNode(.float)), at: .zero)
    }
    flow.selection = [ids[0], ids[1]]

    flow.liveSelectStart()
    flow.liveSelectUpdate([ids[5], ids[7], ids[9]], mode: .replace)
    flow.liveSelectUpdate([], mode: .replace)
    flow.liveSelectUpdate([ids[4], ids[5], ids[6]], mode: .replace)
    flow.liveSelectUpdate([ids[5], ids[7], ids[9]], mode: .replace)
    flow.liveSelectEnd()
    #expect(flow.selection.count == 3)
    #expect(flow.selection.contains(ids[9]))
    #expect(flow.selection.contains(ids[7]))
    #expect(flow.selection.contains(ids[5]))
}

@MainActor
@Test("live select union")
func liveSelectUnionTest() throws {

    let ids = (0..<10).map { _ in UUID() }
    let flow = Flow()
    for id in ids {
        flow.addNode(.init(id: id, kind: .valueNode(.float)), at: .zero)
    }
    flow.selection = [ids[0], ids[1]]

    flow.liveSelectStart()
    flow.liveSelectUpdate([ids[5], ids[7], ids[9]], mode: .replace)
    flow.liveSelectUpdate([], mode: .replace)
    flow.liveSelectUpdate([ids[4], ids[5], ids[6]], mode: .replace)
    flow.liveSelectUpdate([ids[5], ids[7], ids[9]], mode: .union)
    flow.liveSelectEnd()
    #expect(flow.selection.count == 5)
    #expect(flow.selection.contains(ids[0]))
    #expect(flow.selection.contains(ids[1]))
    #expect(flow.selection.contains(ids[9]))
    #expect(flow.selection.contains(ids[7]))
    #expect(flow.selection.contains(ids[5]))
}

@MainActor
@Test("live select cancel")
func liveSelectCancelTest() throws {

    um.removeAllActions()

    let ids = (0..<10).map { _ in UUID() }
    let flow = Flow()
    for id in ids {
        flow.addNode(.init(id: id, kind: .valueNode(.float)), at: .zero)
    }
    flow.selection = [ids[0], ids[1]]

    flow.liveSelectStart()
    flow.liveSelectUpdate([ids[5], ids[7], ids[9]], mode: .replace)
    flow.liveSelectUpdate([], mode: .replace)
    flow.liveSelectUpdate([ids[4], ids[5], ids[6]], mode: .replace)
    flow.liveSelectUpdate([ids[5], ids[7], ids[9]], mode: .replace)
    flow.liveSelectCancel()
    #expect(!um.canUndo)
    #expect(flow.selection.count == 2)
    #expect(flow.selection.contains(ids[0]))
    #expect(flow.selection.contains(ids[1]))
}

// MARK: - Flow + Move Nodes

@MainActor
@Test("moveNode should change a node's position")
func moveNodeShouldChangeNodePosition() throws {
    let (flow, ids) = makeFlow([.valueNode(.float)])
    #expect(flow.nodePositions[ids[0]] == .zero)
    flow.moveNode(ids[0], to: .init(x: 200, y: 300))
    #expect(flow.nodePositions[ids[0]] == CGPoint(x: 200, y: 300))
}

@MainActor
@Test("moveNode should undo a change a node's position")
func moveNodeShouldUndoChangeNodePosition() throws {
    let (flow, ids) = makeFlow([.valueNode(.float)])
    #expect(flow.nodePositions[ids[0]] == .zero)
    um.withGroup {
        flow.moveNode(ids[0], to: .init(x: 200, y: 300), undoService: undoService)
    }
    #expect(flow.nodePositions[ids[0]] == CGPoint(x: 200, y: 300))
    um.undo()
    #expect(flow.nodePositions[ids[0]] == .zero)
    um.redo()
    #expect(flow.nodePositions[ids[0]] == CGPoint(x: 200, y: 300))
}

@MainActor
@Test
func testLiveMoveNodes() throws {
    let (flow, ids) = makeFlow((0..<10).map { _ in .valueNode(.float) })
    let movedNodes = Set(ids.dropLast(5))

    var pos = flow.liveMoveNodesStart(movedNodes)
    #expect(pos == movedNodes.reduce(into: [:], { acc, e in acc[e] = .zero }))
    pos =
        pos.reduce(into: ([:], 0)) { acc, e in
            let hash = e.key.hashValue
            acc.0[e.key] = CGPoint(x: Double(hash), y: (e.value.y + 0.1) * Double(hash))
            acc.1 += 1
        }.0
    flow.liveMoveNodesUpdate(pos)
    #expect(flow.nodePositionsWithLiveMove.filter({ e in movedNodes.contains(e.key) }) == pos)
    pos =
        pos.reduce(into: ([:], 0)) { acc, e in
            let hash = e.key.hashValue
            acc.0[e.key] = CGPoint(x: Double(hash), y: (e.value.y + 0.1) * Double(hash))
            acc.1 += 1
        }.0
    flow.liveMoveNodesUpdate(pos)
    #expect(flow.nodePositionsWithLiveMove.filter({ e in movedNodes.contains(e.key) }) == pos)
    flow.liveMoveNodesEnd(undoService: nil)
    #expect(flow.nodePositions.filter({ e in movedNodes.contains(e.key) }) == pos)
}

@MainActor
@Test
func testLiveMoveNodesCancel() throws {
    let (flow, ids) = makeFlow((0..<10).map { _ in .valueNode(.float) })
    let movedNodes = Set(ids.dropLast(5))

    let initialPos = flow.nodePositions

    var pos = flow.liveMoveNodesStart(movedNodes)
    #expect(pos == movedNodes.reduce(into: [:], { acc, e in acc[e] = .zero }))
    pos =
        pos.reduce(into: ([:], 0)) { acc, e in
            let hash = e.key.hashValue
            acc.0[e.key] = CGPoint(x: Double(hash), y: (e.value.y + 0.1) * Double(hash))
            acc.1 += 1
        }.0
    flow.liveMoveNodesUpdate(pos)
    #expect(flow.nodePositionsWithLiveMove.filter({ e in movedNodes.contains(e.key) }) == pos)
    pos =
        pos.reduce(into: ([:], 0)) { acc, e in
            let hash = e.key.hashValue
            acc.0[e.key] = CGPoint(x: Double(hash), y: (e.value.y + 0.1) * Double(hash))
            acc.1 += 1
        }.0
    flow.liveMoveNodesUpdate(pos)
    #expect(flow.nodePositionsWithLiveMove.filter({ e in movedNodes.contains(e.key) }) == pos)
    flow.liveMoveNodesCancel()
    #expect(flow.nodePositions == initialPos)
    #expect(flow.liveMoveNodesSnapshot == nil)
}

@MainActor
@Test
func testLiveMoveNodesUndo() throws {
    um.removeAllActions()

    let (flow, ids) = makeFlow((0..<10).map { _ in .valueNode(.float) })
    let movedNodes = Set(ids.dropLast(5))

    let initialPos = flow.nodePositions

    var pos = flow.liveMoveNodesStart(movedNodes)
    #expect(pos == movedNodes.reduce(into: [:], { acc, e in acc[e] = .zero }))
    pos =
        pos.reduce(into: ([:], 0)) { acc, e in
            let hash = e.key.hashValue
            acc.0[e.key] = CGPoint(x: Double(hash), y: (e.value.y + 0.1) * Double(hash))
            acc.1 += 1
        }.0
    flow.liveMoveNodesUpdate(pos)
    #expect(flow.nodePositionsWithLiveMove.filter({ e in movedNodes.contains(e.key) }) == pos)
    pos =
        pos.reduce(into: ([:], 0)) { acc, e in
            let hash = e.key.hashValue
            acc.0[e.key] = CGPoint(x: Double(hash), y: (e.value.y + 0.1) * Double(hash))
            acc.1 += 1
        }.0
    flow.liveMoveNodesUpdate(pos)
    #expect(flow.nodePositionsWithLiveMove.filter({ e in movedNodes.contains(e.key) }) == pos)
    um.withGroup {
        flow.liveMoveNodesEnd(undoService: undoService)
    }
    #expect(flow.nodePositions.filter({ e in movedNodes.contains(e.key) }) == pos)
    um.undo()
    #expect(flow.nodePositions == initialPos)
    um.redo()
    #expect(flow.nodePositions.filter({ e in movedNodes.contains(e.key) }) == pos)
    um.undo()
    #expect(flow.nodePositions == initialPos)
    um.redo()
    #expect(flow.nodePositions.filter({ e in movedNodes.contains(e.key) }) == pos)
}
