import Backend
import Helpers
import Logging
import SwiftUI
import Values

@MainActor
final class Scratchpad {
    weak var canvasPlatformView: PlatformView? = nil
    var viewportAtDragStart: CanvasView.Viewport = .init()
    var edgeToRemove: Edge? = nil
    var undoManager: UndoManager?

    init(
        canvasPlatformView: PlatformView? = nil,
        viewportAtDragStart: CanvasView.Viewport = .init(),
        undoManager: UndoManager? = nil
    ) {
        self.canvasPlatformView = canvasPlatformView
        self.viewportAtDragStart = viewportAtDragStart
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
    let flow: Flow

    @State private var partialEdge: PartialEdge? = nil
    @State private var edgeLayers: [CanvasView.EdgeLayer] = []
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

    init(
        _ state: CanvasFeatureState,
        _ flow: Flow,
        _ focus: FocusState<Focus?>.Binding,
    ) {
        self.state = state
        self.focus = focus
        self.flow = flow
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
            self.flow.liveSelectStart()
        case let .modified(shiftDown: shiftDown, rect: rect):
            var nodes = Set<UUID>()
            for (id, view) in self.nodeViews {
                if view.frame.intersects(rect) {
                    nodes.insert(id)
                }
            }
            self.flow.liveSelectUpdate(nodes, mode: shiftDown ? .union : .replace)
        case .ended:
            self.flow.liveSelectEnd(undoManager: nil)
        }
    }

    private func onCanvasClickBackground() {
        self.flow.selectNone()
        self.focus.wrappedValue = .global
    }

    // MARK: - Node Methods

    private func viewForNode(_ id: UUID) -> (any CanvasNodeView)? {

        if let view = self.nodeViews[id] {
            return view
        }

        if id == self.annotationView.id {
            return self.annotationView
        }

        guard let node = self.flow.nodes[id] else {
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
        self.flow.nodes[id]?.inputs[index].value = value
    }

    func onNodePortDrag(_ port: PortLocation, _ gesture: PortView.DragData, undoManager um: UndoManager? = nil) {
    }

    func onNodeClick(_ id: UUID) {
        self.flow.select([id], mode: self.isShiftDown ? .union : .replace)
        self.focus.wrappedValue = .global
    }

    func onNodeDragGesture(_ id: UUID, _ gesture: CanvasNodeDragGesture) {
        switch gesture.phase {
        case .began:
            let nodes =
                if self.flow.isSelected(id) {
                    self.flow.selection
                } else {
                    Set([id])
                }
            self.flow.liveMoveNodesStart(nodes)
        case .cancelled:
            self.flow.liveMoveNodesCancel()
        case .changed:
            if let snap = self.flow.liveMoveNodesSnapshot {
                let next = snap.reduce(
                    into: [:],
                    { acc, e in acc[e.key] = e.value + .init(x: gesture.dx, y: gesture.dy) }
                )
                self.flow.liveMoveNodesUpdate(next)
            }
        case .ended:
            self.flow.liveMoveNodesEnd(undoManager: self.undoManager)
        }
    }

    func updateNodeData() {
        for (id, node) in self.flow.nodes {
            if let view = self.nodeViews[id] {
                view.node = node
            }
        }
    }

    // MARK: - Annotations

    func showAnnotation(_ annotation: Annotation, at point: CGPoint) {
        self.annotationView.annotation = annotation
        self.flow.moveNode(self.annotationView.id, to: point)
        self.annotationView.isHidden = false
    }

    func hideAnnotation() {
        self.annotationView.isHidden = true
    }

    // MARK: - Node Edges

    func updateEdges() {
        var edges: [CanvasView.EdgeLayer] = [
            .init(
                color: Colors.portConnected.platformColor,
                edges: self.flow.edges.compactMap { edge in
                    guard let src = self.portFrameCenter(edge.from), let dst = self.portFrameCenter(edge.to) else {
                        return nil
                    }
                    return CanvasView.Edge(
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

    func portFrame(_ location: PortLocation) -> CGRect? {
        guard let frame = self.nodeViews[location.node]?.portFrame(location.slot) else {
            return nil
        }
        return self.scratch.canvasPlatformView?.convert(frame, from: nil)
    }

    func portFrameCenter(_ location: PortLocation, _ coordinateSpace: CanvasView.CoordinateSpace = .canvas) -> CGPoint?
    {
        guard let frame = self.portFrame(location) else { return nil }
        return self.state.viewport.convert(frame.center, from: .screen, to: coordinateSpace)
    }

    // MARK: - Other Methods

    func dropDestinationHandler(_ items: [NodeKindDragItem], _ point: CGPoint) -> Bool {

        guard let item = items.first else { return false }

        let id = UUID()
        self.flow.newNodeAction(.init(id: id, kind: item.kind), undoManager: self.undoManager)
        self.flow.moveNode(id, to: self.state.viewport.convert(point, from: .screen, to: .canvas))

        return true
    }

    func updateSelection() {
        for (id, view) in self.nodeViews {
            view.isSelected = self.flow.isSelected(id)
        }
    }

    private var nodePositions: [UUID: CGPoint] {
        self.flow.nodePositionsWithLiveMove
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {

            @Bindable var state = self.state
            CanvasView(
                $state.viewport,
                self.nodePositions,
                self.edgeLayers,
                self.scratch,
                self.viewForNode,
                self.onCanvasEvent,
            )
            .dropDestination(for: NodeKindDragItem.self, action: self.dropDestinationHandler(_:_:))
            .onChange(of: self.flow.edges, initial: true) { self.updateEdges() }
            .onChange(of: self.nodePositions, initial: true) { self.updateEdges() }
            .onChange(of: self.flow.nodes, initial: true) { self.updateNodeData() }
            .onChange(of: self.flow.selection, initial: true) { self.updateSelection() }
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
