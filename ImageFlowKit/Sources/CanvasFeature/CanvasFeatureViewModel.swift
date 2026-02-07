import CanvasView
import Design
import Helpers
import Logging
import NodePaletteFeature
import NodeView
import SharedModels
import SwiftUI
import Values

import class SharedModels.Flow

#if os(macOS)
import AppKit
#endif

@Observable
@MainActor
public final class CanvasFeatureViewModel {
    /// The Flow model
    let flow: Flow
    /// The asset store
    let assetStore: any AssetStoreService
    /// The global coordinator to receive and send global events from
    let coordinator: GlobalCoordinator
    /// The canvas viewport state
    var state: CanvasFeatureState
    /// A binding to the app-wide focus state
    var focus: FocusState<Focus?>.Binding
    /// The edges to be drawn by the `CanvasView`
    var edgeLayers: [CanvasView.EdgeLayer] = []
    /// The view showing annotation in the canvas such as errors, warnings and othes messages
    var annotationView: AnnotationView = .empty(width: 280)
    /// The current interaction mode of the canvas
    var interactionMode: CanvasInteractionMode = .default
    /// Storage for the `NodeView` instances to be displayed
    @ObservationIgnored var nodeViews: NodeViewCollection = .init()
    /// Temporary storage for when the viewport is zoomed/dragged
    @ObservationIgnored var viewportAtDragStart: CanvasView.Viewport = .init()
    /// The current UndoManager from the SwiftUI's environment
    @ObservationIgnored var undoManager: UndoManager?
    /// Stores a reference to the platform-specific (i.e., NSView/UIView) canvas view.
    @ObservationIgnored weak var canvasPlatformView: PlatformView?
    /// The delegate for this view model (in practive it is a typealias to `NodeView.Delegate`) (TODO: Is this necessary?)
    @ObservationIgnored weak var delegate: Delegate?
    /// Storage for `EventEmitter` cancellables
    @ObservationIgnored var cancellables: Set<AnyEventEmitterCancellable> = []
    /// If true, hides floating or docked previews.
    var hidePreviews: Bool = false
    /// If true, show the interactive selection toolbar on iPadOS.
    var interactiveSelectionToolbarIsPresented: Bool {
        self.interactionMode == .interactiveSelection
    }

    public typealias Delegate = NodeViewDelegate

    #if os(macOS)
    /// The state of the node search popover
    var nodeSearchPopoverState: NodeSearchPopoverState = .init()

    struct NodeSearchPopoverState {
        var isPresented: Bool = false
        var typedPortLocation: TypedPortLocation?
        var mousePosition: CGPoint?
    }
    #endif

    public init(
        state: CanvasFeatureState,
        flow: Flow,
        assetStore: any AssetStoreService,
        focus: FocusState<Focus?>.Binding,
        delegate: Delegate? = nil,
        coordinator: GlobalCoordinator,
    ) {
        self.state = state
        self.flow = flow
        self.assetStore = assetStore
        self.focus = focus
        self.delegate = delegate
        self.coordinator = coordinator

        self.coordinator.emitter.on({ [weak self] event in self?.onCoordinatorEvent(event) }).store(
            in: &self.cancellables
        )
    }

    // MARK: - Computed variables

    var nodePositions: [UUID: CGPoint] {
        self.flow.nodePositionsWithLiveMove
    }

    var canvasPlatformViewRefBinding: Binding<PlatformView?> {
        .init(
            get: { [weak self] in
                self?.canvasPlatformView
            },
            set: { [weak self] newValue in
                self?.canvasPlatformView = newValue
            }
        )
    }

    public var viewport: CanvasView.Viewport {
        self.state.viewport
    }

    // MARK: - Global Coordinator

    func onCoordinatorEvent(_ event: GlobalCoordinatorEvent) {
    }

    // MARK: - Canvas

    func onCanvasEvent(_ event: CanvasView.Event) {
        switch event {
        case .rectSelect(let state):
            self.onCanvasRectSelect(state)
            self.focus.wrappedValue = .global
        case .clickBackground:
            self.onCanvasClickBackground()
        case .didMoveToSuperview:
            Task { @MainActor in
                self.updateEdges()
            }
        case .pointerMoved(positionInView: let pos):
            if let pos {
                self.coordinator.pointerData = .init(
                    positionInCanvasView: pos,
                    positionInCanvas: self.state.viewport.convert(pos, from: .screen, to: .canvas)
                )
            } else {
                self.coordinator.pointerData = nil
            }
        }
    }

    private func onCanvasRectSelect(_ state: CanvasPlatformView.Event.RectSelect) {
        switch state {
        case .started:
            self.flow.liveSelectStart()
        case let .modified(shiftDown: shiftDown, rect: rect):
            var nodes = Set<UUID>()
            for (id, view) in self.nodeViews where view.frame.intersects(rect) {
                nodes.insert(id)
            }
            self.flow.liveSelectUpdate(nodes, mode: shiftDown ? .union : .replace)
        case .ended:
            self.flow.liveSelectEnd(undoManager: nil)
        }
    }

    private func onCanvasClickBackground() {
        self.flow.selectNone(undoManager: nil)
        self.focus.wrappedValue = .global
    }

    // MARK: - Nodes

    func viewForNode(_ id: UUID) -> (any CanvasNodeView)? {
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

        let view = NodeView(node, delegate: self.delegate)

        view.emitter.on { [weak self, id] event in
            self?.onNodeEvent(id, event)
        }.store(in: &self.cancellables)

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
                self.onNodePortDrag(port, gesture, undoManager: self.undoManager)
            case let .valueDidChange(index, value):
                self.onNodeValueChange(id, index, value)
            case .didRepopulateInputRows:
                self.nodeViews[id]?.setNeedsLayout()
                self.nodeViews[id]?.layoutIfNeeded()
                self.updateEdges()
            }
        case .sizeChanged:
            Task { @MainActor in
                self.updateEdges()
            }
        case .keyboardWillShow(windowVerticalOverlap: _):
            break
        }
    }

    func onNodeValueChange(_ id: UUID, _ index: Int, _ value: Value) {
        self.flow.nodes[id]?.inputs[index].value = value
    }

    func onNodePortDrag(_ port: PortLocation, _ gesture: PortView.DragData, undoManager um: UndoManager? = nil) {
        let viewPos =
            self.canvasPlatformView?.convert(gesture.locationInWindow, from: nil) ?? gesture.locationInWindow
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
            let pos: CGPoint? =
                if let canvasView = self.canvasPlatformView {
                    self.state.viewport.convert(
                        canvasView.convert(gesture.locationInWindow, from: nil),
                        from: .screen,
                        to: .canvas
                    )
                } else {
                    nil
                }

            self.flow.portDragEnd(undoManager: self.undoManager, position: pos)
            self.nodeViews[port.node]?.setDrawPortAsConnected(port.slot, false)
        }
    }

    func onNodeClick(_ id: UUID) {
        if self.interactionMode == .interactiveSelection {
            self.flow.toggleSelected(id)
            self.focus.wrappedValue = .global
        } else {
            self.flow.select([id], previousOverride: nil, mode: self.isShiftDown ? .union : .replace, undoManager: nil)
            self.focus.wrappedValue = .global
        }
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
            self.flow.select(nodes)
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
            self.focus.wrappedValue = .global
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
        self.flow.moveNode(self.annotationView.id, to: point, undoManager: nil)
        self.annotationView.isHidden = false
    }

    func hideAnnotation() {
        self.annotationView.isHidden = true
    }

    // MARK: - Edges

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
            }) where frame.contains(point) {
                return port
            }
        }
        return nil
    }

    func portFrame(_ location: PortLocation) -> CGRect? {
        guard let frame = self.nodeViews[location.node]?.portFrame(location.slot) else {
            return nil
        }
        return self.canvasPlatformView?.convert(frame, from: nil)
    }

    func portFrameCenter(_ location: PortLocation, _ coordinateSpace: CanvasView.CoordinateSpace = .canvas) -> CGPoint?
    {
        guard let frame = self.portFrame(location) else { return nil }
        return self.state.viewport.convert(frame.center, from: .screen, to: coordinateSpace)
    }

    // MARK: - Node Search Popover

    #if os(macOS)
    public func nodeSearchPopoverPresent(typedPortLocation: TypedPortLocation? = nil) {
        let mousePosition: CGPoint? = {
            if let window = NSApp.keyWindow, let canvas = self.canvasPlatformView {
                canvas.convert(window.mouseLocationOutsideOfEventStream, from: nil)
                    .clamped(toRect: canvas.safeAreaRect)
            } else {
                nil
            }
        }()

        NSPopover.swizzle()

        self.nodeSearchPopoverState = .init(
            isPresented: true,
            typedPortLocation: typedPortLocation,
            mousePosition: mousePosition
        )
    }

    func nodeSearchPopover(didPickItem item: NodePaletteItem, at maybePosition: CGPoint?) {
        if let position = maybePosition {
            let canvasPosition = self.state.viewport.convert(position, from: .screen, to: .canvas)

            let node = FlowNode(kind: item.nodeKind)

            if let typedPort = self.nodeSearchPopoverState.typedPortLocation {
                self.flow.newNodeAction(
                    node,
                    at: canvasPosition,
                    connectingToExistingPort: typedPort,
                    undoManager: self.undoManager
                )
            } else {
                self.flow.newNodeAction(node, at: canvasPosition, undoManager: self.undoManager)
            }

            self.flow.select([node.id])

        } else {
            log("nodeSearchPopover(didPickItem): missing canvas position!", level: .error)
        }
    }

    func nodeSearchPopoverDismiss() {
        self.nodeSearchPopoverState = .init(isPresented: false, typedPortLocation: nil)
    }
    #endif

    // MARK: - Interaction Mode

    public func startInteractiveSelection() {
        self.hidePreviews = true
        Task { @MainActor in
            try await Task.sleep(for: .seconds(0.1))
            self.interactionMode = .interactiveSelection
        }
    }

    public func stopInteractiveSelection() {
        self.interactionMode = .default
        Task { @MainActor in
            try await Task.sleep(for: .seconds(0.1))
            self.hidePreviews = false
        }
    }

    func interactiveSelectionToolbarAction(_ action: InteractiveSelectionToolbarView.Action) {
        switch action {
        case .done:
            self.stopInteractiveSelection()
        case .selectAll:
            self.coordinator.perform(userAction: .selectAllNodes)
        case .selectNone:
            self.coordinator.perform(userAction: .selectNone)
        }
    }

    // MARK: - Other Methods

    func dropDestinationHandler(_ items: [NodeKindDragItem], _ point: CGPoint) -> Bool {
        guard let item = items.first else { return false }

        let id = UUID()
        let pos = self.state.viewport.convert(point, from: .screen, to: .canvas)
        self.flow.newNodeAction(.init(id: id, kind: item.kind), at: pos, undoManager: self.undoManager)

        self.flow.select([id])

        return true
    }

    func updateSelection() {
        for (id, view) in self.nodeViews {
            view.isSelected = self.flow.isSelected(id)
        }
    }
}

extension CanvasFeatureViewModel {
    var isShiftDown: Bool {
        #if os(macOS)
        NSEvent.modifierFlags.contains(.shift)
        #else
        false
        #endif
    }
}

extension CanvasFeatureViewModel: PlatformViewRefStore {
    public var view: PlatformView? {
        get {
            self.canvasPlatformView
        }

        set {
            self.canvasPlatformView = newValue
        }
    }
}

extension CanvasFeatureViewModel: CanvasViewDelegate {
    public func canvasViewEditMenuShouldAppear() -> Bool {
        self.flow.selection.isEmpty
    }
}

extension PartialEdge {
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
