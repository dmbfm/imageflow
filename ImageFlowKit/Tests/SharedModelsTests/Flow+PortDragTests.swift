import Foundation
import Testing

@testable import SharedModels

@Test("Drag an output port to an empty input port should create an edge, register an undo item, and correctly undo")
@MainActor
func portDragAndCreateEdge() throws {
    let flow = Flow()
    let ids = [UUID(), UUID()]
    flow.newNodeAction(.init(id: ids[0], kind: .addNode(.float)), at: .zero, undoManager: nil)
    flow.newNodeAction(.init(id: ids[1], kind: .valueNode(.float)), at: .zero, undoManager: nil)

    let src = PortLocation(node: ids[1], port: .output(0))
    let dst = PortLocation(node: ids[0], port: .input(0))

    flow.portDragStart(src, .zero)
    flow.portDragUpdate(.init(x: 100, y: 200), nil)
    #expect(flow.partialEdge == .init(port: src, pointer: .init(x: 100, y: 200)))
    flow.portDragUpdate(.init(x: 300, y: 400), dst)
    #expect(flow.partialEdge == .init(port: src, pointer: .init(x: 300, y: 400), state: .canConnect))
    um.removeAllActions()
    flow.portDragEnd(undoManager: um)
    #expect(flow.edges.count == 1)
    #expect(flow.edges.first == .init(src, dst))

    #expect(um.canUndo)
    um.undo()
    #expect(flow.edges.isEmpty)
}

@Test("Drag an output port to an empty input port and then cancel should not create an edge")
@MainActor
func portDragAndCancel() throws {
    let flow = Flow()
    let ids = [UUID(), UUID()]
    flow.newNodeAction(.init(id: ids[0], kind: .addNode(.float)), at: .zero, undoManager: nil)
    flow.newNodeAction(.init(id: ids[1], kind: .valueNode(.float)), at: .zero, undoManager: nil)

    let src = PortLocation(node: ids[1], port: .output(0))
    let dst = PortLocation(node: ids[0], port: .input(0))

    flow.portDragStart(src, .zero)
    flow.portDragUpdate(.init(x: 100, y: 200), nil)
    #expect(flow.partialEdge == .init(port: src, pointer: .init(x: 100, y: 200)))
    flow.portDragUpdate(.init(x: 300, y: 400), dst)
    #expect(flow.partialEdge == .init(port: src, pointer: .init(x: 300, y: 400), state: .canConnect))
    um.removeAllActions()
    flow.portDragCancel()
    #expect(flow.edges.isEmpty)
    #expect(!um.canUndo)
}

@Test(
    "Dragging a connected input port and dropping it while not hovering a port should delete the original edge and create an undo item"
)
@MainActor
func portDragConnectedInputShouldDelete() {
    let flow = Flow()
    let ids = [UUID(), UUID()]
    flow.newNodeAction(.init(id: ids[0], kind: .addNode(.float)), at: .zero, undoManager: nil)
    flow.newNodeAction(.init(id: ids[1], kind: .valueNode(.float)), at: .zero, undoManager: nil)

    let src = PortLocation(node: ids[1], port: .output(0))
    let dst = PortLocation(node: ids[0], port: .input(0))

    flow.portDragStart(src, .zero)
    flow.portDragUpdate(.init(x: 300, y: 400), dst)
    flow.portDragEnd(undoManager: nil)
    #expect(flow.edges.count == 1)
    #expect(flow.getPortConnected(src) == true)
    #expect(flow.getPortConnected(dst) == true)

    flow.portDragStart(dst, .zero)
    #expect(flow.edges.isEmpty)
    #expect(flow.getPortConnected(src) == false)
    #expect(flow.getPortConnected(dst) == false)

    flow.portDragUpdate(.zero, nil)
    flow.portDragEnd(undoManager: um)
    #expect(flow.edges.isEmpty)

    um.undo()
    #expect(flow.edges.count == 1)
    #expect(flow.edges.first == .init(src, dst))
    #expect(flow.getPortConnected(src) == true)
    #expect(flow.getPortConnected(dst) == true)
}

@Test(
    "Dragging the output port of a int node to the input port of a float node should convert the float node to an int node"
)
@MainActor
func portDragConvertNode() {
    let (flow, ids) = makeFlow([.valueNode(.int), .valueNode(.float)], [])

    let src = PortLocation(node: ids[0], port: .output(0))
    let dst = PortLocation(node: ids[1], port: .input(0))

    flow.portDragStart(src, .zero)
    flow.portDragUpdate(.zero, dst)
    flow.portDragEnd(undoManager: nil)

    #expect(flow.nodes[ids[0]]?.kind == .valueNode(.int))
    #expect(flow.nodes[ids[1]]?.kind == .valueNode(.int))
}
