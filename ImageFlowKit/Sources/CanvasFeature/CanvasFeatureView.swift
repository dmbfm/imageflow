import Backend
import CanvasView
import CommonUtils
import Design
import Logging
import Models
import NodeDataStore
import NodeSelectionStore
import NodeView
import PlatformUtils
import SwiftUI
import SwiftUIUtils
import Values

import enum CanvasView.CoordinateSpace

@MainActor
final class Scratchpad {
    weak var canvasPlatformView: PlatformView? = nil
    var selectionAtRectDragStart: Set<UUID> = []
    var viewportAtDragStart: CanvasViewport = .init()
    var nodePositionsAtDragStart: [UUID: CGPoint] = [:]
    var edgeToRemove: Models.Edge? = nil
    var undoManager: UndoManager?

    init(
        canvasPlatformView: PlatformView? = nil,
        selectionAtRectDragStart: Set<UUID> = [],
        viewportAtDragStart: CanvasViewport = .init(),
        nodePositionsAtDragStart: [UUID: CGPoint] = [:],
        undoManager: UndoManager? = nil
    ) {
        self.canvasPlatformView = canvasPlatformView
        self.selectionAtRectDragStart = selectionAtRectDragStart
        self.viewportAtDragStart = viewportAtDragStart
        self.nodePositionsAtDragStart = nodePositionsAtDragStart
        self.undoManager = undoManager
    }
}

extension Scratchpad: PlatformViewRefStore {
    var view: PlatformView? {
        get {
            self.canvasPlatformView
        }

        set {
            self.canvasPlatformView = newValue
        }
    }
}

public struct CanvasFeatureView: View {

    // MARK: - State

    let focus: FocusState<Focus?>.Binding
    let state: CanvasFeatureState
    let nodeDataStore: NodeDataStore
    let nodeSelectionStore: NodeSelectionStore

    @State private var partialEdge: PartialEdge? = nil
    @State private var edgeLayers: [EdgeLayer] = []
    @State private var nodeViews: NodeViewCollection = .init()
    @State private var annotationView: AnnotationView = .empty(width: 280)
    @State private var scratch: Scratchpad = .init()

    @Environment(\.undoManager) private var undoManager: UndoManager?

    // MARK: - Types

    struct PartialEdge: Sendable, Equatable {
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

    public init(
        _ state: CanvasFeatureState,
        _ nodeDataStore: NodeDataStore,
        _ nodeSelectionStore: NodeSelectionStore,
        _ focus: FocusState<Focus?>.Binding,
    ) {
        self.state = state
        self.nodeDataStore = nodeDataStore
        self.nodeSelectionStore = nodeSelectionStore
        self.focus = focus
    }

    // MARK: - Canvas

    private func onCanvasEvent(_ event: CanvasView.Event) {
        switch event {
        case .rectSelect(let state):
            onCanvasRectSelect(state)
            self.focus.wrappedValue = .global
        case .clickBackground:
            onCanvasClickBackground()
            self.focus.wrappedValue = .global
        case .didMoveToSuperview:
            Task { @MainActor in
                self.updateEdges()
            }
        }
    }

    private func onCanvasRectSelect(_ state: CanvasPlatformView.Event.RectSelect) {
        switch state {
        case .started:
            self.scratch.selectionAtRectDragStart = self.nodeSelectionStore.selection
            break
        case let .modified(shiftDown: shiftDown, rect: rect):
            var nodes = Set<UUID>()
            for (id, view) in self.nodeViews {
                if view.frame.intersects(rect) {
                    nodes.insert(id)
                }
            }
            self.nodeSelectionStore.selection = shiftDown ? nodes.union(self.scratch.selectionAtRectDragStart) : nodes
        case .ended:
            break
        }
    }

    private func onCanvasClickBackground() {
        self.nodeSelectionStore.deselectAll()
    }

    // MARK: - Node Methods

    private func viewForNode(_ id: UUID) -> (any CanvasNodeView)? {

        if let view = self.nodeViews[id] {
            return view
        }

        if id == self.annotationView.id {
            return self.annotationView
        }

        guard let node = self.nodeDataStore.nodes[id] else {
            log("Node data not found for id: \(id)", level: .warning)
            return nil
        }

        let view = NodeView(node)

        view.emitter.on { self.onNodeEvent(id, $0) }

        self.nodeViews[id] = view

        return view
    }

    func onNodeEvent(_ id: UUID, _ event: CanvasNodeEvent<NodeView.Event>) {
        switch event {
        case .click:
            self.onNodeClick(id)
        case .dragGesture(let gesture):
            self.onNodeDragGesture(id, gesture)
        case .other(let event):
            switch event {
            case let .dragPort(port, gesture):
                self.onNodePortDrag(port, gesture, undoManager: self.scratch.undoManager)
                break
            case let .valueDidChange(index, value):
                self.onNodeValueChange(id, index, value)
                break
            }
        case .sizeChanged:
            break
        }
    }

    func onNodeValueChange(_ id: UUID, _ index: Int, _ value: Value) {
        self.nodeDataStore.nodes[id]?.inputs[index].value = value
    }

    func onNodePortDrag(_ port: PortLocation, _ gesture: PortView.DragData, undoManager um: UndoManager? = nil) {
        switch gesture.phase {
        case .began:
            self.scratch.edgeToRemove = nil

            let isInput = port.slot.isInput
            let isConnected = self.nodeDataStore.getPortConnected(port) == .success(true)

            if isInput && isConnected {
                guard let edgeToRemove = self.nodeDataStore.edges(to: port).first else {
                    log("Failed to get edge starting at \(port)", level: .error)
                    return
                }

                self.scratch.edgeToRemove = edgeToRemove

                if case let .failure(err) = self.nodeDataStore.deleteEdge(edgeToRemove) {
                    log("Failed to remove edge: \(err)", level: .error)
                    return
                }
            }

            self.nodeViews[port.node]?.setDrawPortAsConnected(port.slot, true)

        case .changed:

            self.partialEdge = .init(port: port, pointer: gesture.locationInWindow, state: .default)
            self.partialEdge?.state = {
                switch self.canDropPort(port, gesture.locationInWindow) {
                case .ok:
                    self.hideAnnotation()
                    return .canConnect
                case .failure(let port, let reason):
                    if let pos = self.portFrameCenter(port) {
                        self.showAnnotation(
                            .init(title: "Can't connect ports", message: "\(reason)", maxWidth: 250),
                            at: pos + .init(x: 10, y: 0)
                        )
                    }
                    return .cantConnect
                case .noPort, .samePort:
                    self.hideAnnotation()
                    return .default
                }
            }()

            self.updateEdges()

        case .ended:
            // if let hit = self.portHitTest(locationInWindow: data.locationInWindow),
            //     let edge = Models.Edge(port, hit)
            // {
            switch self.canDropPort(port, gesture.locationInWindow) {
            case .ok(let hit, let condition):

                log("condition: \(condition)", level: .debug)

                guard let edge = Models.Edge(port, hit) else { break }

                um?.beginUndoGrouping()

                switch condition {
                case .needsToConvertDestinationNodeTo(let variation):
                    try! self.nodeDataStore.convertNode(edge.to.node, toVariation: variation, undoManager: um)
                case .needsToConvertSourceNodeTo(let variation):
                    try! self.nodeDataStore.convertNode(edge.from.node, toVariation: variation, undoManager: um)
                case .none:
                    break
                }

                if case let .failure(err) = self.nodeDataStore.createEdge(edge, undoManager: um) {
                    log("\(err)", level: .error)
                }

                um?.endUndoGrouping()
                um?.setActionName("Create Edge")

            case .failure(_, let reason):
                log("Can't create edge: \(reason)", level: .error)
                break

            case .noPort, .samePort:
                break
            }
            // }

            assert(self.nodeDataStore.validateEdges() == .ok)
            self.partialEdge = nil
            self.nodeViews[port.node]?.setDrawPortAsConnected(port.slot, false)
            self.hideAnnotation()
            self.updateEdges()

        case .cancelled:
            if let edge = self.scratch.edgeToRemove.take() {
                _ = try! self.nodeDataStore.createEdge(edge).get()
            }
            self.partialEdge = nil
            self.nodeViews[port.node]?.setDrawPortAsConnected(port.slot, false)
            self.hideAnnotation()
            self.updateEdges()
        }
    }

    func onNodeClick(_ id: UUID) {
        self.nodeSelectionStore.select(nodes: [id], mode: self.isShiftDown ? .union : .replace)
        self.focus.wrappedValue = .global
    }

    func onNodeDragGesture(_ id: UUID, _ gesture: CanvasNodeDragGesture) {
        let translation = self.state.viewport.convert(
            CGSize(width: gesture.dx, height: gesture.dy),
            from: .screen,
            to: .canvas
        )

        switch gesture.phase {
        case .began:
            self.scratch.nodePositionsAtDragStart = {
                let nodes: Set<UUID> =
                    if self.nodeSelectionStore.isSelected(id) {
                        self.nodeSelectionStore.selection
                    } else {
                        [id]
                    }

                return Dictionary(
                    uniqueKeysWithValues: nodes.compactMap {
                        if let pos = self.state.nodePositions[$0] { ($0, pos) } else { nil }
                    }
                )
            }()
            break
        case .changed:
            for (id, _) in self.scratch.nodePositionsAtDragStart {
                let newPos = self.state.nodePositions[id]! + translation.cgPoint
                self.state.nodePositions[id] = newPos
            }
        case .cancelled:
            for (id, pos) in self.scratch.nodePositionsAtDragStart {
                self.state.nodePositions[id] = pos
            }
        case .ended:
            try! self.state.move(
                nodes: self.state.nodePositions.filter({ self.scratch.nodePositionsAtDragStart[$0.key] != nil }),
                previousOverride: self.scratch.nodePositionsAtDragStart,
                undoManager: self.scratch.undoManager,
                undoTitle: self.scratch.nodePositionsAtDragStart.count > 1 ? "Move Nodes" : "Move Node"
            )
        }
    }

    func updateNodeData() {
        for (id, node) in self.nodeDataStore.nodes {
            if let view = self.nodeViews[id] {
                view.node = node
            }
        }
    }

    // MARK: - Annotations

    func showAnnotation(_ annotation: Annotation, at point: CGPoint) {
        self.annotationView.annotation = annotation
        self.state.nodePositions[self.annotationView.id] = point
        self.annotationView.isHidden = false
    }

    func hideAnnotation() {
        self.annotationView.isHidden = true
    }

    // MARK: - Node Edges

    func updateEdges() {
        var edges = [
            EdgeLayer(
                color: Colors.portConnected.platformColor,
                edges: self.nodeDataStore.edges.compactMap { edge in
                    guard let src = self.portFrameCenter(edge.from), let dst = self.portFrameCenter(edge.to) else {
                        return nil
                    }
                    return Edge(
                        edge.id,
                        src: src,
                        dst: dst
                    )
                }
            )
        ]

        if let e = self.partialEdge {

            let point = self.state.viewport.convert(
                self.scratch.canvasPlatformView!.convert(e.pointer, from: nil),
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

    func canDropPort(_ source: PortLocation, _ locationInWindow: CGPoint) -> CanDropPortResult {
        guard let destination = self.portHitTest(locationInWindow: locationInWindow) else {
            return .noPort
        }

        if destination == source {
            return .samePort
        }

        guard let edge = Models.Edge(source, destination) else {
            return .failure(destination, .invalidEdge)
        }

        switch self.nodeDataStore.canAddEdge(edge) {
        case .success:
            return .ok(destination, .none)
        case .failure(.typeMismatch):
            switch self.nodeDataStore.typeCheck(addingEdge: edge) {
            case .typeMismatch(.nofix):
                return .failure(destination, .typeMismatch)
            case .typeMismatch(.fixConvertingSourceTo(let variation)):
                return .ok(destination, .needsToConvertSourceNodeTo(variation))
            case .typeMismatch(.fixConvertingDestTo(let variation)):
                return .ok(destination, .needsToConvertDestinationNodeTo(variation))
            case .invalidPort(_):
                return .failure(destination, .invalidPort)
            case .edgeAlreadyExists:
                return .failure(destination, .edgeAlreadyExists)
            case .missingNode(let node):
                return .failure(destination, .missingNode(node))
            case .ok:
                return .ok(destination, .none)
            }
        case .failure(let reason):
            return .failure(destination, .addEdge(reason))
        }
    }

    enum CanDropPortResult: Equatable {
        case samePort
        case noPort
        case ok(PortLocation, Condition)
        case failure(PortLocation, Reason)

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
            case missingNode(UUID)
            case addEdge(NodeDataStore.AddEdgeError)
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
        return self.scratch.canvasPlatformView?.convert(frame, from: nil)
    }

    func portFrameCenter(_ location: PortLocation, _ coordinateSpace: CoordinateSpace = .canvas) -> CGPoint? {
        guard let frame = self.portFrame(location) else { return nil }
        return self.state.viewport.convert(frame.center, from: .screen, to: coordinateSpace)
    }

    // MARK: - Other Methods

    func dropDestinationHandler(_ items: [NodeKindDragItem], _ point: CGPoint) -> Bool {

        guard let item = items.first else { return false }

        let id = UUID()
        if case .failure(_) = self.nodeDataStore.createNode(.init(id: id, kind: item.kind)) {
            return false
        }
        self.state.nodePositions[id] = self.state.viewport.convert(point, from: .screen, to: .canvas)

        return true
    }

    func updateSelection() {
        for (id, view) in self.nodeViews {
            view.isSelected = self.nodeSelectionStore.isSelected(id)
        }
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            @Bindable var state = self.state
            CanvasView(
                $state.viewport,
                self.state.nodePositions,
                self.edgeLayers,
                self.scratch,
                self.viewForNode,
                self.onCanvasEvent,
            )
            .dropDestination(for: NodeKindDragItem.self, action: self.dropDestinationHandler(_:_:))
            .onChange(of: self.nodeDataStore.edges, initial: true) { self.updateEdges() }
            .onChange(of: self.state.nodePositions, initial: true) { self.updateEdges() }
            .onChange(of: self.nodeDataStore.nodes, initial: true) { self.updateNodeData() }
            .onChange(of: self.nodeSelectionStore.selection, initial: true) { self.updateSelection() }
            .onChange(of: self.undoManager, { self.scratch.undoManager = self.undoManager })
        }
    }
}

// private enum PreviewData {
//     static let id = UUID()
// }

// // #Preview(traits: .sizeThatFitsLayout) {
// //     @Previewable @State var state: CanvasFeatureState = .init(nodePositions: [PreviewData.id: .zero])
// //     @Previewable @State var nodeDataStore: NodeDataStore = .init([
// //         PreviewData.id: .init(id: PreviewData.id, kind: .addNode(.float))
// //     ])
// //     @Previewable @State var nodeSelectionStore: NodeSelectionStore = .init()
// //     VStack {
// //         CanvasFeatureView($state, $nodeDataStore, $nodeSelectionStore)
// //     }
// // }
