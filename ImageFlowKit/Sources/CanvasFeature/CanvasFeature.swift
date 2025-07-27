import Backend
import CanvasView
import CommonUtils
import Design
import Logging
import Models
import NodeDataStore
import NodeView
import SwiftUI
import SwiftUIUtils

// MARK: - State

public struct CanvasFeature {
    public struct State: Sendable, Equatable {
        public var viewport: CanvasViewport = .init()
        public var portPositions: [PortLocation: CGPoint] = [:]

        public init(viewport: CanvasViewport = .init(), portPositions: [PortLocation: CGPoint] = [:]) {
            self.viewport = viewport
            self.portPositions = portPositions
        }
        public mutating func updatePortPosition(_ location: PortLocation, _ position: CGPoint) {
            self.portPositions[location] = self.viewport.convert(position, from: .screen, to: .canvas)
        }

        public func portPosition(_ location: PortLocation) -> CGPoint? {
            self.portPositions[location]
        }

        public func portHitTest(_ point: CGPoint, _ radius: CGFloat = 10) -> PortLocation? {
            for (port, pos) in self.portPositions {
                log("\(point) ---> \(pos)")
                if pos.distance(to: point) <= radius {
                    return port
                }
            }

            return nil
        }
    }

    public struct StoredState: Sendable, Equatable, Codable {

        public var nodePositions: NodePositionStore = .init()

        public init(nodePositionStore: NodePositionStore = .init()) {
            self.nodePositions = nodePositionStore
        }
    }
}

// MARK: - View

public struct CanvasFeatureView: View {

    @Binding var state: CanvasFeature.State
    @Binding var store: CanvasFeature.StoredState

    var nodeDataStore: NodeDataStore
    @State var partialEdge: PartialEdge?
    @Environment(\.undoManager) var undoManager

    struct PartialEdge: Sendable, Equatable {
        var port: PortLocation
        var point: CGPoint
        var state: State = .default

        enum State {
            case `default`
            case connect
            case error

            var color: Color {
                switch self {
                case .connect: Colors.edgeWithSuccess.color
                case .error: Colors.edgeWithError.color
                case .default: Colors.portConnected.color
                }
            }
        }
    }

    public init(_ state: Binding<CanvasFeature.State>, _ store: Binding<CanvasFeature.StoredState>, nodeDataStore: NodeDataStore) {
        self._state = state
        self._store = store
        self.nodeDataStore = nodeDataStore
    }

    var resolvedPartialEdge: EdgeView.Edge? {
        self.partialEdge.flatMap { partialEdge in

            switch partialEdge.port.slot {
            case .input(_):
                if let end = self.state.portPosition(partialEdge.port) {
                    return .init(start: partialEdge.point, end: end, color: partialEdge.state.color)
                }
            case .output(_):
                if let start = self.state.portPosition(partialEdge.port) {
                    return .init(start: start, end: partialEdge.point, color: partialEdge.state.color)
                }
            }

            return nil
        }
    }

    func canDropPort(_ source: PortLocation, _ destination: PortLocation) -> CanDropPortResult {

        if source.node == destination.node {
            return .failure(.sameNode)
        }

        if !source.canConnectWith(destination) {
            return .failure(.portDirection)
        }

        guard let edge = Models.Edge(source, destination) else { return .failure(.invalidEdge) }

        if self.nodeDataStore.edges.contains(edge) {
            return .failure(.edgeAlreadyExists)
        }

        let checkResult = self.nodeDataStore.typeCheck(addingEdge: edge)

        switch checkResult {
        case .typeMismatch(.nofix):
            return .failure(.typeMismatch)
        case .typeMismatch(.fixConvertingSourceTo(let variation)):
            return .ok(.needsToConvertSourceNodeTo(variation))
        case .typeMismatch(.fixConvertingDestTo(let variation)):
            return .ok(.needsToConvertDestinationNodeTo(variation))
        case .invalidPort(_):
            return .failure(.invalidPort)
        default: break
        }

        return .ok(.none)
    }

    enum CanDropPortResult: Equatable {
        case ok(Condition)
        case failure(Reason)

        enum Condition: Equatable {
            case none
            case needsToConvertSourceNodeTo(NodeKind)
            case needsToConvertDestinationNodeTo(NodeKind)
        }

        enum Reason: Equatable {
            case portDirection
            case typeMismatch
            case invalidEdge
            case invalidPort
            case edgeAlreadyExists
            case sameNode
        }

        var isOk: Bool {
            if case .ok = self {
                true
            } else {
                false
            }
        }
    }

    func onPortDrag(_ value: PortDragGesture.Value, _ phase: PortDragGesture.Phase) {
        let location = self.state.viewport.convert(value.location, from: .screen, to: .canvas)
        switch phase {
        case .started:

            switch value.port.slot {
            case .input(_):
                // If we are dragging an input port which is already connected, we need to
                // remove the existing edge and create a partial edge from the output port to the
                // mouse position

                // Check if the port is connected
                if self.nodeDataStore.getPortConnected(value.port) == .success(true) {

                    // Try to get the edge
                    guard let edge = self.nodeDataStore.edges(to: value.port).first else {
                        fatalError("Edge not found!")
                    }

                    if case let .failure(err) = self.nodeDataStore.removeEdge(edge) {
                        fatalError("Failed to remove edge: \(err)")
                    }

                    // The partial edge starts from the output port
                    self.partialEdge = .init(port: edge.from, point: location)
                } else {
                    // The partial edge starts from the input port
                    self.partialEdge = .init(port: value.port, point: location)
                }
                break
            case .output(_):
                // We don't need to do anything here because output nodes can have multiple outgoing edges.
                self.partialEdge = .init(port: value.port, point: location)

                break
            }

        case .changed:
            self.partialEdge = .init(port: self.partialEdge!.port, point: location)
            // check if there are any ports under the cursor
            if let port = self.state.portHitTest(location) {
                switch self.canDropPort(self.partialEdge!.port, port) {
                case .ok:
                    self.partialEdge?.state = .connect
                    MouseCursor.push(.dragLink)
                    break
                case .failure:
                    MouseCursor.pop(.dragLink)
                    if port != self.partialEdge!.port {
                        self.partialEdge?.state = .error
                    }
                    break
                }
            } else {
                MouseCursor.pop(.dragLink)
            }

        case .ended:
            guard let partialEdge = self.partialEdge else {
                log("Partial edge is nil!", level: .error)
                return
            }

            self.partialEdge = nil

            if let port = self.state.portHitTest(location), let edge = Edge(partialEdge.port, port) {
                switch self.canDropPort(partialEdge.port, port) {
                case .ok(.none):
                    if case let .failure(err) = self.nodeDataStore.addEdge(edge) {
                        log("\(err)", level: .error)
                    }
                case .ok(.needsToConvertDestinationNodeTo(let kind)):
                    let _ = self.nodeDataStore.nodes[edge.to.node]!.convert(toVariation: kind)
                    if case let .failure(err) = self.nodeDataStore.addEdge(edge) {
                        log("\(err)", level: .error)
                    }
                case .ok(.needsToConvertSourceNodeTo(let kind)):
                    let _ = self.nodeDataStore.nodes[edge.from.node]!.convert(toVariation: kind)
                    if case let .failure(err) = self.nodeDataStore.addEdge(edge) {
                        log("\(err)", level: .error)
                    }
                case .failure(let reason):
                    log("\(reason)", level: .error)
                }
            }
            let validation = self.nodeDataStore.validateEdges()
            assert(self.nodeDataStore.validateEdges() == .ok, "validation: \(validation)")
            self.partialEdge = nil
            // self.hideAnnotationMessage()
            MouseCursor.pop(.dragLink)
        case .cancelled:
            self.partialEdge = nil
            // self.hideAnnotationMessage()
            MouseCursor.pop(.dragLink)
        }
    }

    func onCanvasNotification(_ notification: CanvasNotification) {
        // switch notification {
        //     case .continuousTranslationBegan:
        //         self.undoManager?.beginUndoGrouping()
        //         self.undoManager?.setActionName("Viewport")
        //     case .continuousTranslationEnded:
        //         self.undoManager?.endUndoGrouping()
        //     case .willScrollZoom:
        //         self.undoManager?.disableUndoRegistration()
        //     case .didScrollZoom:
        //         self.undoManager?.enableUndoRegistration()
        // }
    }

    public var body: some View {
        CanvasView(viewport: self.$state.viewport) {
            Text("Hello!")
                .background(.white)
            ForEach(Array(self.nodeDataStore.edges)) { (edge: Models.Edge) in
                if let start = self.state.portPositions[edge.from], let end = self.state.portPositions[edge.to] {
                    EdgeView(edge: .init(start: start, end: end, color: Colors.portConnected.color))
                }
            }

            if let partialEdge = self.resolvedPartialEdge {
                EdgeView(edge: partialEdge)
            }

            ForEach(self.store.nodePositions.items) { item in
                NodeView(
                    node: .init {
                        self.nodeDataStore.nodes[item.id]!
                    } set: { newValue in
                        self.nodeDataStore.nodes[item.id] = newValue
                    }
                )
                .offset(item.position.cgSize)
                .dragNode(self.$store.nodePositions[item.id])
                .portDragGesture(self.onPortDrag(_:_:))
                // .portDragGesture() { value, phase in
                //     switch phase {
                //     case .started, .changed:
                //         self.partialEdge = .init(
                //             port: value.port,
                //             point: self.state.viewport.convert(value.location, from: .screen, to: .canvas)
                //         )
                //     case .ended, .cancelled:
                //         self.partialEdge = nil
                //         break
                //     }
                // }
            }
        }
        .onCanvasViewNotification(self.onCanvasNotification(_:))
    }
}

// MARK: - NodePositionStore

public struct NodePositionStore: Sendable, Hashable, Codable {
    public var items: [Item] = []

    public struct Item: Sendable, Hashable, Identifiable, Codable {
        public var id: UUID
        public var position: CGPoint

        public init(id: UUID, position: CGPoint) {
            self.id = id
            self.position = position
        }
    }

    public init(items: [NodePositionStore.Item] = []) {
        self.items = items
    }

    subscript(id: UUID) -> CGPoint {
        get {
            for item in self.items {
                if item.id == id {
                    return item.position
                }
            }

            fatalError("Invalid id: \(id)")
        }

        set {
            for index in self.items.indices {
                if self.items[index].id == id {
                    self.items[index].position = newValue
                    return
                }
            }

            fatalError("Invalid id: \(id)")
        }

    }
}

// MARK: - Previews

fileprivate struct PreviewData {
    static let id1 = UUID()
    static let id2 = UUID()
}

#Preview {
    @Previewable @State var store = {
        let state = CanvasFeature.StoredState(
            nodePositionStore: .init(items: [
                .init(id: PreviewData.id1, position: .zero),
                .init(id: PreviewData.id2, position: .init(x: 250, y: 250)),
            ])
        )
        return state
    }()
    @Previewable @State var state = CanvasFeature.State()
    @Previewable @State var nodeDataStore = {
        // let store = NodeDataStore(
        //     [
        //         PreviewData.id1: FlowNode(id: PreviewData.id1, kind: .addNode(.float)),
        //         PreviewData.id2: FlowNode(id: PreviewData.id2, kind: .addNode(.float)),
        //     ],
        //     edges: Set([
        //         .init(.init(node: PreviewData.id1, port: .output(0)), .init(node: PreviewData.id2, port: .input(0)))!
        //     ])
        // )
        // store.
        let store = NodeDataStore()
        var n1 = FlowNode(id: PreviewData.id1, kind: .addNode(.float))
        var n2 = FlowNode(id: PreviewData.id2, kind: .addNode(.float))
        store.addNode(n1)
        store.addNode(n2)
        _ = store.addEdge(
            .init(
                PortLocation(node: PreviewData.id1, port: .output(0)),
                PortLocation(node: PreviewData.id2, port: .input(0))
            )!
        )
        return store
    }()
    VStack {
        CanvasFeatureView($state, $store, nodeDataStore: nodeDataStore)
    }
    .frame(width: 500, height: 500)
    .border(.gray.opacity(0.2))
    .padding()
}
