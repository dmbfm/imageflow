import Backend
import Helpers
import Logging
import SwiftUI
import Values

@MainActor
private final class Scratchpad {
    weak var canvasPlatformView: PlatformView? = nil
    var viewportAtDragStart: CanvasView.Viewport = .init()
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
    let assetStore: AssetStore
    let previewState: PreviewFeatureState<Flow, AssetStore>

    @State private var edgeLayers: [CanvasView.EdgeLayer] = []
    @State private var nodeViews: NodeViewCollection = .init()
    @State private var annotationView: AnnotationView = .empty(width: 280)
    @State private var scratch: Scratchpad = .init()

    @Environment(\.undoManager) private var undoManager: UndoManager?

    // MARK: - Types

    struct Delegate {
        var openAssetPicker: (AssetBrowserType.Picker) -> ()
        var fetchAsset: (AssetIdentifier) -> Asset?
    }

    private var delegate: Delegate

    // MARK: - Initializers

    init(
        _ state: CanvasFeatureState,
        _ flow: Flow,
        _ assetStore: AssetStore,
        _ previewState: PreviewFeatureState<Flow, AssetStore>,
        _ focus: FocusState<Focus?>.Binding,
        _ delegate: Delegate
    ) {
        self.state = state
        self.focus = focus
        self.flow = flow
        self.previewState = previewState
        self.assetStore = assetStore
        self.delegate = delegate
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

        let delegate = NodeView.Delegate(
            openAssetPicker: { index, kind in
                self.delegate.openAssetPicker(.init(assetKind: kind, portLocation: .init(node: id, index: index)))
            },
            titleForAsset: { id in self.delegate.fetchAsset(id)?.filename }
        )

        let view = NodeView(node, delegate: delegate)

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
            case .didRepopulateInputRows:
                self.nodeViews[id]?.setNeedsLayout()
                self.nodeViews[id]?.layoutIfNeeded()
                self.updateEdges()
            }
        case .sizeChanged:
            Task { @MainActor in
                self.updateEdges()
            }
        }
    }

    func onNodeValueChange(_ id: UUID, _ index: Int, _ value: Value) {
        self.flow.nodes[id]?.inputs[index].value = value
    }

    func onNodePortDrag(_ port: PortLocation, _ gesture: PortView.DragData, undoManager um: UndoManager? = nil) {
        let viewPos =
            self.scratch.canvasPlatformView?.convert(gesture.locationInWindow, from: nil) ?? gesture.locationInWindow
        let pointer = self.state.viewport.convert(viewPos, from: .screen, to: .canvas)

        let hoveredPort = self.portHitTest(locationInWindow: gesture.locationInWindow)

        switch gesture.phase {
        case .began:
            self.flow.portDragStart(port, pointer)
            self.nodeViews[port.node]?.setDrawPortAsConnected(port.slot, true)
        case .changed:
            self.flow.portDragUpdate(pointer, hoveredPort)
        case .cancelled:
            self.flow.portDragCancel()
            self.nodeViews[port.node]?.setDrawPortAsConnected(port.slot, false)
        case .ended:
            self.flow.portDragEnd(undoManager: self.undoManager)
            self.nodeViews[port.node]?.setDrawPortAsConnected(port.slot, false)
        }
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
            let delta = self.state.viewport.convert(
                .init(width: gesture.dx, height: gesture.dy),
                from: .screen,
                to: .canvas
            )
            if let snap = self.flow.liveMoveNodesSnapshot {
                let next = snap.reduce(
                    into: [:],
                    { acc, e in acc[e.key] = e.value + delta.cgPoint }
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

        if let e = self.flow.partialEdge {
            let point = e.pointer
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
        let pos = self.state.viewport.convert(point, from: .screen, to: .canvas)
        self.flow.newNodeAction(.init(id: id, kind: item.kind), at: pos, undoManager: self.undoManager)

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
            .ignoresSafeArea()
            .dropDestination(for: NodeKindDragItem.self, action: self.dropDestinationHandler(_:_:))
            .onChange(of: self.flow.edges, initial: true) { self.updateEdges() }
            .onChange(of: self.nodePositions, initial: true) { self.updateEdges() }
            .onChange(of: self.flow.nodes, initial: true) { self.updateNodeData() }
            .onChange(of: self.flow.selection, initial: true) { self.updateSelection() }
            .onChange(of: self.undoManager, { self.scratch.undoManager = self.undoManager })
            .onChange(of: self.flow.partialEdge) { self.updateEdges() }

            CanvasImagePreviewView(previewState: self.previewState) { _ in }
                #if os(iOS)
            .safeAreaPadding(.top, 60)
                #endif
        }
    }
}

//#if os(macOS)
fileprivate struct CanvasImagePreviewView: View {
    let previewState: PreviewFeatureState<Flow, AssetStore>
    let launchPreviewWindow: (AssetIdentifier) -> ()
    var body: some View {

        PreviewFeatureView(state: self.previewState)

        // HStack {
        //     Spacer()
        //     VStack {
        //         Spacer()
        //         // ImagePreviewFeatureView(flow: self.flow, assetStore: self.assetStore)
        //             // ImagePreviewView(
        //             //     self.assetStore,
        //             //     self.selection
        //             // )
        //             .padding(.trailing, 20)
        //             .padding(.bottom, 20)
        //     }
        // }
    }
}
//#endif

//#if os(iOS)
//fileprivate struct CanvasImagePreviewView: View {
//    let flow: Flow
//    let assetStore: AssetStore
//    let launchPreviewWindow: (AssetIdentifier) -> ()
//    var body: some View {
//        TouchImagePreviewFeatureView(flow: self.flow, assetStore: self.assetStore)
//    }
//}
//#endif
