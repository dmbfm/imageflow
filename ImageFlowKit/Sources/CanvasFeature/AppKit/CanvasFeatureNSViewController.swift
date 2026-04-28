#if canImport(AppKit)

import AppKit
import CanvasView
import SharedModels
import Helpers
import NodeView
import Values
import Design

public final class CanvasFeatureNSViewController: NSViewController {

    /// The Flow model
    var flow: Flow
    /// Storage for the `NodeView` instances to be displayed
    var nodeViews: NodeViewCollection = .init()
    /// The underlying canvas view
    var canvasView: CanvasPlatformView!

    var viewport: CanvasView.Viewport {
        self.canvasView.viewport
    }

    private var nodeViewDelegateEmitter: EventEmitter<NodeViewDelegateEvent> = .init()
    private var cancellables: Set<AnyEventEmitterCancellable> = []

    public init(flow: Flow) {
        self.flow = flow
        super.init(nibName: nil, bundle: nil)

        self.flow.emitter.on({ [weak self] event in
            self?.onFlowEvent(event)
        }).store(in: &self.cancellables)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        self.canvasView = .init(
            viewport: .init(),
            nodePositions: self.flow.nodePositions,
            viewForNode: { [weak self] in self?.viewForNode($0) }
        )
        self.view = self.canvasView

        self.upadteEdges()
    }

    // MARK: - Flow

    private func onFlowEvent(_ event: FlowEvent) {
        logger.trace("\("\(event)")")

        switch event {
        case .nodePositionsDidChange, .liveMoveNodesSnapshotDidChange:
            self.updateNodePositions()
            self.upadteEdges()
        default:
            break
        }
    }

    // MARK: - Nodes

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
        logger.trace("\(id): \("\(event)")")
        switch event {
        case .dragGesture(let gesture):
            self.onNodeDragGesture(id, gesture)
        default:
            break
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
        }
    }

    // MARK: - Edges

    func upadteEdges() {
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

        // self.updatePlusIconPosition()
        self.canvasView.edgeLayers = edges
    }

    // MARK: - Ports

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
}

extension CanvasFeatureNSViewController: NodeViewDelegate {
    public func nodeView(willShowContextMenuForNode node: UUID) {

    }

    public func nodeView(contextMenuForNode node: UUID, at point: CGPoint?) -> PlatformMenu? {
        nil
    }

    public func nodeView(
        registerUndoForNode node: UUID,
        inputIndex: Int,
        oldValue: Values.Value,
        newValue: Values.Value
    ) {

    }

    public func nodeViewSelectedNodesCount() -> Int {
        0
    }

    public func openAssetPicker(node: UUID, portIndex: Int, kind: SharedModels.AssetKind) {

    }

    public func titleForAsset(id: Values.AssetIdentifier) -> String? {
        nil
    }

    public func statusBarMessage(message: String?) {

    }

    public var emitter: EventEmitter<NodeViewDelegateEvent> {
        self.nodeViewDelegateEmitter
    }

}

#endif
