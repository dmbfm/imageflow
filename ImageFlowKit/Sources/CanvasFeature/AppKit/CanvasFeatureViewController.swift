#if canImport(AppKit)

import AppKit
import CanvasView
import SharedModels
import SharedControllers
import Helpers
import NodeView
import Values
import Design
import ContextMenus
import XKit
import Combine
import SwiftUI
import UniformTypeIdentifiers
import AssetSystem

public final class CanvasFeatureViewController: NSViewController {

    // MARK: - Properties

    /// The Flow model
    public var flow: Flow
    /// A description
    public var state: CanvasFeatureState
    /// The asset provider
    public var assetStore: AssetStore
    /// Storage for the `NodeView` instances to be displayed
    public var nodeViews: NodeViewCollection = .init()
    /// The underlying canvas view
    public var canvasView: CanvasPlatformView!
    /// The coordinator
    public var coordinator: GlobalCoordinator
    /// Publisher for viewport changes.
    public var viewportPublisher: CurrentValueSubject<CanvasView.Viewport, Never> = .init(
        .init(origin: .zero, scale: 1.0)
    )
    /// Provider for canvas context menus
    var canvasContextMenuProvider: CanvasContextMenuProvider?
    /// An instance of `PasteBoardController`.
    var pasteboardController: PasteboardController
    /// Set to true whenever the user is dragging a partial edge starting from a
    /// connected input port of a node.
    var isDraggingConnectedInputPort: Bool = false

    var nodeViewDelegateEmitter: EventEmitter<NodeViewDelegateEvent> = .init()
    var cancellables: Set<AnyEventEmitterCancellable> = []
    var cancellables2: Set<AnyCancellable> = []

    // MARK: - Computed Variables

    /// The current interaction mode of the canvas
    var interactionMode: CanvasInteractionMode {
        get {
            self.canvasView.interactionMode
        }

        set {
            self.canvasView.interactionMode = newValue
        }
    }

    var viewport: CanvasView.Viewport {
        self.canvasView.viewport
    }

    var isShiftDown: Bool {
        self.view.window?.currentEvent?.modifierFlags.contains(.shift) ?? false
    }

    // MARK: - Initialization

    public init(
        flow: Flow,
        state: CanvasFeatureState,
        coordinator: GlobalCoordinator,
        assetStore: AssetStore,
    ) {
        self.flow = flow
        self.state = state
        self.coordinator = coordinator
        self.assetStore = assetStore
        self.pasteboardController = .init(coordinator)

        super.init(nibName: nil, bundle: nil)

        self.flow.emitter.on({ [weak self] event in
            self?.onFlowEvent(event)
        }).store(in: &self.cancellables)

        self.assetStore.publisher.sink { [weak self] event in
            self?.onAssetStoreEvent(event)
        }.store(in: &self.cancellables2)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - NSViewController

    public override func loadView() {
        self.canvasView = .init(
            viewport: self.state.viewport,
            nodePositions: self.flow.nodePositions,
        )
        self.canvasView.onEvent = { [weak self] in self?.onCanvasEvent($0) }
        self.canvasView.delegate = self
        self.view = self.canvasView

        self.canvasView.registerForDraggedTypes([
            .init(UTType.imageFlowNodeKindDragItem.identifier),
            .png,
            .tiff,
            .init("public.jpeg"),
            .fileURL,
        ])
    }

    public override func viewDidLoad() {
        self.upadteEdges()
        self.updateSelection()
        self.viewportPublisher.send(self.viewport)
    }

    // MARK: - Asset Store

    func onAssetStoreEvent(_ event: AssetSystemEvent) {
        switch event {
        case .asssetsDidChange:
            self.nodeViewDelegateEmitter.emit(.assetsChanged)
        default:
            break
        }
    }

    // MARK: - CanvasView

    func onCanvasEvent(_ event: CanvasPlatformView.Event) {
        switch event {
        case .viewportDidChange(let viewport):
            self.state.viewport = viewport
            self.viewportPublisher.send(viewport)
        case .rectSelect(let state):
            self.onCanvasRectSelect(state)
        case .clickBackground:
            self.onCanvasClickBackground()
        case .didMoveToSuperview:
            break
        case .pointerMoved(_):
            break
        }
    }

    private func onCanvasClickBackground() {
        self.flow.selectNone()
    }

    // MARK: - Flow

    private func onFlowEvent(_ event: FlowEvent) {
        switch event {
        case .nodesDidChange:
            self.updateNodeData()
        case .nodePositionsDidChange, .liveMoveNodesSnapshotDidChange:
            self.updateNodePositions()
            self.upadteEdges()
        case .partialEdgeDidChange:
            self.upadteEdges()
        case .selectionDidChange(_, liveSelect: true):
            self.updateSelection()
        case .selectionDidChange(_, liveSelect: false):
            self.updateSelection()
            for (id, node) in self.nodeViews {
                if self.flow.selection.contains(id) {
                    node.level = 1
                } else {
                    node.level = 0
                }
            }
            self.canvasView.perform(canvasAction: .sortSubviews)
        default:
            break
        }
    }

    // MARK: - Nodes

    func updateNodeData() {
        for (id, node) in self.flow.nodes {
            if let view = self.nodeViews[id] {
                view.node = node
            }
        }
    }

    func updateNodePositions() {
        let newValue = self.flow.nodePositionsWithLiveMove
        if self.canvasView.nodePositions != newValue {
            self.canvasView.nodePositions = newValue
        }
    }

    func viewForNode(_ id: UUID) -> (any CanvasNodeView)? {
        if let view = self.nodeViews[id] {
            return view
        }

        // TODO: Annotation view
        // if id == self.annotationView.id {
        //     return self.annotationView
        // }

        guard let node = self.flow.nodes[id] else {
            logger.warning("Node data not found for id: \(id)")
            return nil
        }

        let view = NodeView(node, delegate: self)

        view.emitter.on { [weak self, id] event in
            self?.onNodeEvent(id, event)
        }.store(in: &self.cancellables)

        self.nodeViews[id] = view

        return view
    }

    func onNodeEvent(_ id: UUID, _ event: CanvasNodeEvent<NodeView.Event>) {
        switch event {
        case .dragGesture(let gesture):
            self.onNodeDragGesture(id, gesture)
        case let .other(.dragPort(location, data)):
            self.onNodePortDrag(location, data)
        case .click:
            self.onNodeClick(id)
        case let .other(.valueDidChange(index, value)):
            self.flow.nodes[id]?.inputs[index].value = value
        case .sizeChanged:
            Task {
                self.upadteEdges()
            }
        default:
            logger.trace("Unhandled: \(id): \("\(event)")")
        }
    }

    func onNodeClick(_ id: UUID) {
        if self.interactionMode == .interactiveSelection {
            self.flow.toggleSelected(id)
            // self.focus.wrappedValue = .global
        } else {
            self.flow.select([id], previousOverride: nil, mode: self.isShiftDown ? .union : .replace)
            // self.focus.wrappedValue = .global
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
            let delta = self.viewport.convert(
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
        default:
            logger.warning("onNodeDragGesture: \("\(gesture.phase)")")
        }
    }

    func setNodeValue(
        _ id: UUID,
        _ index: Int,
        _ oldValue: Value?,
        _ newValue: Value,
    ) {
        guard let node = self.flow.nodes[id] else {
            logger.error(("Node not found: \(id)"))
            return
        }

        guard node.inputs.indices.contains(index) else {
            logger.error(("Node input index out of range: \(index)"))
            return
        }

        let oldValue = oldValue ?? node.inputs[index].value

        if let view = self.nodeViews[id] {
            let viewValue = view.value(inputIntex: index)!

            if viewValue != newValue {
                view.setValue(inputIntex: index, value: newValue)
            }
        }

        guard oldValue != newValue else {
            logger.info(("New value is equal to old value; nothing to do"))
            return
        }

        self.flow.nodes[id]?.inputs[index].value = newValue

        self.undoManager?.registerUndo(
            withTarget: self,
            handler: { this in
                this.setNodeValue(id, index, newValue, oldValue)
            }
        )
        self.undoManager?.setActionName("\(newValue.type.displayName) Value Change")
    }

    // MARK: - Edges

    func upadteEdges() {
        if self.flow.edges.isEmpty && self.flow.partialEdge == nil {
            self.canvasView.edgeLayers = []
            return
        }

        var edges: [CanvasView.EdgeLayer] = [
            .init(
                color: Colors.portConnected.platformColor,
                edges: self.flow.edges.compactMap { edge in
                    if let view = self.nodeViews[edge.fromPort.node] {
                        if view.superview == nil {
                            // return nil
                        }
                        view.layoutIfNeeded()
                    }
                    if let view = self.nodeViews[edge.toPort.node] {
                        if view.superview == nil {
                            // return nil
                        }
                        view.layoutIfNeeded()
                    }

                    guard let src = self.portFrameCenter(edge.fromPort), let dst = self.portFrameCenter(edge.toPort)
                    else {
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

        self.updatePlusIconPosition()
        self.canvasView.edgeLayers = edges
    }

    func updatePlusIconPosition() {

        if self.flow.partialEdge == nil && self.canvasView.plusIconState.visible == false {
            return
        }

        self.canvasView.plusIconState.visible = true

        guard let e = self.flow.partialEdge else {
            self.canvasView.plusIconState.visible = false
            return
        }

        if e.state != .default {
            self.canvasView.plusIconState.visible = false
        }

        if let center = self.portFrameCenter(e.port),
            e.pointer.distance(to: center) < GlobalConstants.minTravelDistanceToCreateNode
        {
            self.canvasView.plusIconState.visible = false
        }

        if self.isDraggingConnectedInputPort {
            self.canvasView.plusIconState.visible = false
        }

        self.canvasView.plusIconState.position = self.viewport.convert(e.pointer, from: .canvas, to: .screen)
        self.canvasView.plusIconState.direction =
            switch e.port.slot {
            case .input: .xminus
            case .output: .xplus
            }
    }

    // MARK: - Ports

    struct PortHit {
        var location: PortLocation
        var center: CGPoint
    }

    func portHitTest(locationInWindow point: CGPoint) -> PortHit? {
        for (_, view) in self.nodeViews {
            for (port, frame) in view.ports.map({ (loc, view) in
                (loc, view.superview!.convert(view.frame, to: nil))
            }) where frame.center.distance(to: point) < self.viewport.convert(32.0, from: .canvas, to: .screen) {
                return .init(location: port, center: frame.center)
            }
        }
        return nil
    }

    func portFrame(_ location: PortLocation) -> CGRect? {
        guard let frame = self.nodeViews[location.node]?.portFrame(location.slot) else {
            return nil
        }
        return self.canvasView?.convert(frame, from: nil)
    }

    func portFrameCenter(_ location: PortLocation, _ coordinateSpace: CanvasView.CoordinateSpace = .canvas) -> CGPoint?
    {
        guard let frame = self.portFrame(location) else { return nil }
        return self.viewport.convert(frame.center, from: .screen, to: coordinateSpace)
    }

    func onNodePortDrag(_ port: PortLocation, _ gesture: PortView.DragData) {
        let pointerViewPos = self.canvasView.convert(gesture.locationInWindow, from: nil)
        let pointerCanvasPos = self.viewport.convert(pointerViewPos, from: .screen, to: .canvas)
        let travelDistance =
            if let portCenter = self.portFrameCenter(port) {
                self.viewport.convert(pointerViewPos, from: .screen, to: .canvas).distance(to: portCenter)
            } else {
                0.0
            }

        // Hit-test for other ports but discard hits from the same node
        let portHit = self.portHitTest(locationInWindow: gesture.locationInWindow).flatMap({ hit in
            if hit.location.node == port.node {
                nil as (PortHit?)
            } else {
                hit
            }
        })

        switch gesture.phase {
        case .began:
            self.isDraggingConnectedInputPort =
                port.direction == .input && self.flow.nodes[port.node]!.inputs[port.slot.index].connected
            self.flow.portDragStart(port, pointerCanvasPos)
            self.nodeViews[port.node]?.setDrawPortAsConnected(port.slot, true)

        case .changed:
            let snappedPointerCanvasPos =
                if let hit = portHit {
                    self.viewport.convert(self.view.convert(hit.center, from: nil), from: .screen, to: .canvas)
                } else {
                    pointerCanvasPos
                }

            let result = self.flow.portDragUpdate(
                snappedPointerCanvasPos,
                portHit?.location
            )

            if let error = result?.error, let annotation = error.annotation {
                self.showAnnotation(annotation, at: snappedPointerCanvasPos)
            } else {
                self.hideAnnotation()
            }

        case .cancelled:
            self.flow.portDragCancel()
            self.nodeViews[port.node]?.setDrawPortAsConnected(port.slot, false)
            self.hideAnnotation()

        case .ended:
            let pos: CGPoint =
                self.viewport.convert(
                    self.canvasView.convert(gesture.locationInWindow, from: nil),
                    from: .screen,
                    to: .canvas
                )

            self.flow.portDragEnd(undoManager: self.undoManager, position: pos, travelDistance: travelDistance)
            self.nodeViews[port.node]?.setDrawPortAsConnected(port.slot, false)
            self.hideAnnotation()

        default:
            logger.warning("onNodePortDrag: \("\(gesture.phase)")")
        }
    }

    // MARK: - Annotations

    func showAnnotation(_ annotation: Annotation, at point: CGPoint) {
        // self.annotationView.annotation = annotation
        // self.annotationPosition = point
        // self.annotationView.isHidden = false
    }

    func hideAnnotation() {
        // self.annotationView.isHidden = true
        // self.annotationPosition = nil
    }

    // MARK: - Selection

    func updateSelection() {
        for (id, view) in self.nodeViews {
            view.isSelected = self.flow.isSelected(id)
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
            self.flow.liveSelectEnd()
        }
    }

    // MARK: - Bookmarks

    public func addBookmark(_ b: CanvasBookmark) {
        self.state.bookmarks.add(b)
        let id = b.id
        self.undoManager?.registerUndo(
            withTarget: self,
            handler: { [weak self] _ in
                self?.removeBookmark(id)
            }
        )
        self.undoManager?.setActionName("Create Bookmark")
    }

    public func createBookmark() {
        let id = UUID()
        let name = "Bookmark \(self.state.bookmarks.count + 1)"
        self.state.bookmarks.add(
            .init(
                id: id,
                name: name,
                viewport: self.viewport,
            )
        )

        self.undoManager?.registerUndo(
            withTarget: self,
            handler: { [weak self] _ in
                self?.removeBookmark(id)
            }
        )
        self.undoManager?.setActionName("Create Bookmark")
    }

    public func removeBookmark(_ id: UUID) {
        if let b = self.state.bookmarks.remove(id) {
            self.undoManager?.registerUndo(
                withTarget: self,
                handler: { [weak self] _ in
                    self?.addBookmark(b)
                }
            )
            self.undoManager?.setActionName("Remove Bookmark")
        }
    }

    public func renameBookmark(_ id: UUID, _ name: String) {
        if let oldName = self.state.bookmarks.get(withID: id)?.name {
            self.state.bookmarks.rename(id, name)
            self.undoManager?.registerUndo(
                withTarget: self,
                handler: { [weak self] _ in
                    self?.renameBookmark(id, oldName)
                }
            )
            self.undoManager?.setActionName("Rename Bookmark")
        }
    }
}

// MARK: - NodeViewDelegate

extension CanvasFeatureViewController: NodeViewDelegate {
    public func nodeView(willShowContextMenuForNode node: UUID) {
        self.becomeFirstResponder()
    }

    public func nodeView(contextMenuForNode node: UUID, at point: CGPoint?) -> XMenu? {
        NodeContextMenu.make(self.flow, node)
    }

    public func nodeView(
        registerUndoForNode node: UUID,
        inputIndex: Int,
        oldValue: Values.Value,
        newValue: Values.Value
    ) {
        self.setNodeValue(node, inputIndex, oldValue, newValue)
    }

    public func nodeViewSelectedNodesCount() -> Int {
        self.flow.selection.count
    }

    public func openAssetPicker(node: UUID, portIndex: Int, kind: SharedModels.AssetKind) {
        self.coordinator.perform(userAction: .openAssetPicker(node: node, portIndex: portIndex, kind: kind))
    }

    public func titleForAsset(id: Values.AssetIdentifier) -> String? {
        switch id {
        case .asset(let id):
            self.assetStore.assets[id]?.originalFilename
        case .nodeOutput:
            nil
        }
    }

    public func statusBarMessage(message: String?) {
        logger.warning("TODO: statusBarMessage")
    }

    public var emitter: EventEmitter<NodeViewDelegateEvent> {
        self.nodeViewDelegateEmitter
    }

}

extension PartialEdge {
    var color: XColor {
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

#endif
