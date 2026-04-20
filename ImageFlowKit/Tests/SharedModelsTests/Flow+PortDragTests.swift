import Foundation
import Testing

@testable import SharedModels

@Test("Drag an output port to an empty input port should create an edge, register an undo item, and correctly undo")
@MainActor
func portDragAndCreateEdge() throws {
    let flow = Flow()
    let ids = [UUID(), UUID()]
    flow.newNodeAction(.init(id: ids[0], kind: .math(.addNode(.float))), at: .zero, undoManager: nil)
    flow.newNodeAction(.init(id: ids[1], kind: .valueNode(.float)), at: .zero, undoManager: nil)

    let src = PortLocation(node: ids[1], port: .output(0))
    let dst = PortLocation(node: ids[0], port: .input(0))

    flow.portDragStart(src, .zero)
    flow.portDragUpdate(.init(x: 100, y: 200), nil)
    #expect(flow.partialEdge == .init(port: src, pointer: .init(x: 100, y: 200)))
    flow.portDragUpdate(.init(x: 300, y: 400), dst)
    #expect(flow.partialEdge == .init(port: src, pointer: .init(x: 300, y: 400), state: .canConnect))
    um.removeAllActions()
    um.withGroup {
        flow.portDragEnd(undoManager: um, position: nil, travelDistance: 1000)
    }
    #expect(flow.edges.count == 1)
    #expect(flow.edges.first == (try Edge.fromPorts(src, dst).get()))

    #expect(um.canUndo)
    um.undo()
    #expect(flow.edges.isEmpty)
}

@Test("Drag an output port to an empty input port and then cancel should not create an edge")
@MainActor
func portDragAndCancel() throws {
    let flow = Flow()
    let ids = [UUID(), UUID()]
    flow.newNodeAction(.init(id: ids[0], kind: .math(.addNode(.float))), at: .zero, undoManager: nil)
    flow.newNodeAction(.init(id: ids[1], kind: .valueNode(.float)), at: .zero, undoManager: nil)

    let src = PortLocation(node: ids[1], port: .output(0))
    let dst = PortLocation(node: ids[0], port: .input(0))

    flow.portDragStart(src, .zero)
    flow.portDragUpdate(.init(x: 100, y: 200), nil)
    #expect(flow.partialEdge == .init(port: src, pointer: .init(x: 100, y: 200)))
    flow.portDragUpdate(.init(x: 300, y: 400), dst)
    #expect(flow.partialEdge == .init(port: src, pointer: .init(x: 300, y: 400), state: .canConnect))
    flow.portDragCancel()
    #expect(flow.edges.isEmpty)
}

@Test(
    "Dragging a connected input port and dropping it while not hovering a port should delete the original edge and create an undo item"
)
@MainActor
func portDragConnectedInputShouldDelete() throws {
    let flow = Flow()
    let ids = [UUID(), UUID()]
    flow.newNodeAction(.init(id: ids[0], kind: .math(.addNode(.float))), at: .zero, undoManager: nil)
    flow.newNodeAction(.init(id: ids[1], kind: .valueNode(.float)), at: .zero, undoManager: nil)

    let src = PortLocation(node: ids[1], port: .output(0))
    let dst = PortLocation(node: ids[0], port: .input(0))

    flow.portDragStart(src, .zero)
    flow.portDragUpdate(.init(x: 300, y: 400), dst)
    um.withGroup {
        flow.portDragEnd(undoManager: um, position: nil, travelDistance: 1000)
    }
    #expect(flow.edges.count == 1)
    #expect(flow.getPortConnected(src) == true)
    #expect(flow.getPortConnected(dst) == true)

    flow.portDragStart(dst, .zero)
    #expect(flow.edges.isEmpty)
    #expect(flow.getPortConnected(src) == false)
    #expect(flow.getPortConnected(dst) == false)

    flow.portDragUpdate(.zero, nil)
    um.withGroup {
        flow.portDragEnd(undoManager: um, position: nil, travelDistance: 1000)
    }
    #expect(flow.edges.isEmpty)

    #expect(um.canUndo)

    um.undo()
    #expect(flow.edges.count == 1)
    #expect(flow.edges.first == (try Edge.fromPorts(src, dst).get()))
    #expect(flow.getPortConnected(src) == true)
    #expect(flow.getPortConnected(dst) == true)
}
