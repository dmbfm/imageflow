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

        public init() {
            self.canvas = .init()
            self.nodeDataStore = .init()
        }

        public init(
            canvas: CanvasFeatureState.StorableData,
            nodeDataStore: NodeDataStore.StorableData,
        ) {
            self.canvas = canvas
            self.nodeDataStore = nodeDataStore
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
        )
    }

    func restore(_ snapshot: StorableData) {
        self.canvas.restore(snapshot.canvas)
        self.nodeDataStore.restore(snapshot.nodeDataStore)
    }
}
