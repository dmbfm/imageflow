import Backend
import CanvasView
import Design
import Logging
import Models
import NodeDataStore
import NodeView
import PlatformUtils
import SwiftUI
import SwiftUIUtils

import enum CanvasView.CoordinateSpace

public struct CanvasFeatureView: View {

    // MARK: - State

    @Binding var state: CanvasFeatureState
    @Binding var nodeDataStore: NodeDataStore
    @State private var edgeLayers: [EdgeLayer] = []
    @State private var nodeViews: NodeViewCollection = .init()
    @State private var canvasPlatformViewRef: PlatformViewRef = .init()
    @State private var partialEdge: PartialEdge? = nil

    // MARK: - Types

    private struct PartialEdge: Sendable, Equatable {
        var port: PortLocation
        var pointer: CGPoint
        var state: State = .default

        enum State: Equatable {
            case `default`
            case cantConnect
            case canConnect
        }

        var color: PlatformColor {
            switch self.state {
            case .default:
                Colors.portConnected.platformColor
            case .canConnect:
                Colors.edgeWithSuccess.platformColor
            case .cantConnect:
                Colors.edgeWithError.platformColor
            }
        }

    }

    // MARK: - Initializers

    public init(_ state: Binding<CanvasFeatureState>, _ nodeDataStore: Binding<NodeDataStore>) {
        self._state = state
        self._nodeDataStore = nodeDataStore
    }

    // MARK: - Node Views

    func viewForNode(_ id: UUID) -> (any CanvasNodeView)? {

        if let view = self.nodeViews[id] {
            return view
        }

        guard let node = self.nodeDataStore.nodes[id] else {
            log("Node data not found for id: \(id)", level: .warning)
            return nil
        }

        let view = NodeView(node)

        view.emitter.on { event in
            switch event {
            case .click: break
            case .dragGesture(_): break
            case .sizeChanged: break
            case .other(let event):
                switch event {
                case .valueDidChange(_, _): break
                case let .dragPort(port, data): self.portDragHandler(port, data)
                }
            }
        }

        self.nodeViews[id] = view

        return view
    }

    func updateNodeData() {
        for (id, node) in self.nodeDataStore.nodes {
            if let view = self.nodeViews[id] {
                view.node = node
            }
        }
    }

    // MARK: - Node Edges

    func updateEdges() {
        var edges = [
            EdgeLayer(
                color: Colors.portConnected.platformColor,
                edges: self.nodeDataStore.edges.map { edge in
                    Edge(
                        edge.id,
                        src: self.portFrameCenter(edge.from)!,
                        dst: self.portFrameCenter(edge.to)!
                    )
                }
            )
        ]

        if let e = self.partialEdge {

            let point = self.state.viewport.convert(
                self.canvasPlatformViewRef.view!.convert(e.pointer, from: nil),
                //self.converter.convertFromWindow(e.point),
                from: .screen,
                to: .canvas
            )
            let (src, dst) =
                switch e.port.slot {
                case .input:
                    (point, self.portFrameCenter(e.port)!)
                case .output:
                    (self.portFrameCenter(e.port)!, point)
                }

            edges.append(
                .init(color: e.color, edges: [.init(src: src, dst: dst)])
            )
        }

        self.edgeLayers = edges
    }

    // MARK: - Port

    func portDragHandler(_ port: PortLocation, _ data: PortView.DragData) {
        switch data.phase {
        case .began:

            let isInput = port.slot.isInput
            let isConnected = self.nodeDataStore.getPortConnected(port) == .success(true)

            if isInput && isConnected {
                guard let edgeToRemove = self.nodeDataStore.edges(to: port).first else {
                    log("Failed to get edge starting at \(port)", level: .error)
                    return
                }
                if case let .failure(err) = self.nodeDataStore.removeEdge(edgeToRemove) {
                    log("Failed to remove edge: \(err)", level: .error)
                    return
                }
            }

            self.nodeViews[port.node]?.setDrawPortAsConnected(port.slot, true)

        case .changed:

            self.partialEdge = .init(port: port, pointer: data.locationInWindow, state: .default)
            self.partialEdge?.state =
                switch self.canDropPort(port, data.locationInWindow) {
                case .ok:
                    .canConnect
                case .failure:
                    .cantConnect
                default:
                    .default
                }

            self.updateEdges()

        case .ended:

            if let hit = self.portHitTest(locationInWindow: data.locationInWindow),
                let edge = Models.Edge(port, hit)
            {
                switch self.canDropPort(port, hit) {
                case .ok(let condition):
                    switch condition {
                    case .needsToConvertDestinationNodeTo(let variation):
                        let _ = self.nodeDataStore.nodes[edge.to.node]!.convert(toVariation: variation)
                    case .needsToConvertSourceNodeTo(let variation):
                        let _ = self.nodeDataStore.nodes[edge.from.node]!.convert(toVariation: variation)
                    case .none:
                        break
                    }

                    if case let .failure(err) = self.nodeDataStore.addEdge(edge) {
                        log("\(err)", level: .error)
                    }
                case .failure(let reason):
                    log("Can't create edge: \(reason)", level: .error)
                    break
                }
            }

            assert(self.nodeDataStore.validateEdges() ==  .ok)
            self.partialEdge = nil
            self.nodeViews[port.node]?.setDrawPortAsConnected(port.slot, false)
            self.updateEdges()

        case .cancelled:
            self.partialEdge = nil
            self.nodeViews[port.node]?.setDrawPortAsConnected(port.slot, false)
            self.updateEdges()
        }
    }

    func portHitTest(locationInWindow point: CGPoint) -> PortLocation? {
        for (_, view) in self.nodeViews {
            for (port, frame) in view.ports.map({ (loc, view) in
                (loc, view.superview!.convert(view.frame, to: nil))
            }) {
                if frame.contains(point) {
                    return port
                }
            }
        }
        return nil
    }

    func canDropPort(_ source: PortLocation, _ locationInWindow: CGPoint) -> CanDropPortResult? {
        guard let hit = self.portHitTest(locationInWindow: locationInWindow), hit != source else { return nil }
        return self.canDropPort(source, hit)
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

    func portFrame(_ location: PortLocation) -> CGRect? {
        guard let frame = self.nodeViews[location.node]?.portFrame(location.slot) else {
            return nil
        }
        return self.canvasPlatformViewRef.view?.convert(frame, from: nil)
    }

    func portFrameCenter(_ location: PortLocation, _ coordinateSpace: CoordinateSpace = .canvas) -> CGPoint? {
        guard let frame = self.portFrame(location) else { return nil }
        return self.state.viewport.convert(frame.center, from: .screen, to: coordinateSpace)
    }

    public var body: some View {
        ZStack {
            CanvasView(
                self.$state.viewport,
                self.$state.nodePositions,
                self.edgeLayers,
                self.canvasPlatformViewRef,
                self.viewForNode
            )
            // .randomColorDebugBorder(50)
            .onChange(of: self.nodeDataStore.edges, initial: true) { self.updateEdges() }
            .onChange(of: self.state.nodePositions, initial: true) { self.updateEdges() }
            .onChange(of: self.nodeDataStore.nodes, initial: true) { self.updateNodeData() }
        }
    }
}

enum PreviewData {
    static let id = UUID()
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var state: CanvasFeatureState = .init(nodePositions: [PreviewData.id: .zero])
    @Previewable @State var nodeDataStore: NodeDataStore = .init([
        PreviewData.id: .init(id: PreviewData.id, kind: .addNode(.float))
    ])
    VStack {
        CanvasFeatureView($state, $nodeDataStore)
    }
}
