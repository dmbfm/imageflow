#if os(macOS)
import AppKit
import AssetBrowserFeature
import PreviewFeature
import Backend
import CanvasFeature
import SharedControllers
import SharedModels
import BackendService
import CanvasView
import NodeView
import Helpers
import XKit
import SwiftUI
import Combine
import AssetSystem
import InspectorFeature

final class MainViewController: NSSplitViewController {

    // MARK: - Properties

    var flow: SharedModels::Flow
    var assetStore: AssetStore
    var emitter: EventEmitter<GlobalCoordinatorEvent> = .init()
    var modalContainerVM: ModalContainerViewModel = .init()
    var cancellables: Set<AnyEventEmitterCancellable> = []

    var backendRunner: BackendRunner!
    var sidebarVC: SidebarViewController!
    var detailVC: DetailViewController!
    var inspectorVC: InspectorFeatureController!
    var pasteboardController: PasteboardController!

    // MARK: - Computed Properties

    var canvasView: CanvasPlatformView {
        self.detailVC.canvasView
    }

    var previewVC: PreviewFeatureController {
        self.detailVC.previewVC
    }

    var canvasViewportPublisher: AnyPublisher<CanvasViewportModel, Never> {
        .init(
            self.detailVC.canvasVC.viewportPublisher.map({ viewport in
                .init(origin: viewport.origin, scale: viewport.scale)
            })
        )
    }

    // MARK: - Lazy Properties

    lazy var sidebarItem: NSSplitViewItem = {
        let item = NSSplitViewItem(sidebarWithViewController: self.sidebarVC)
        item.minimumThickness = 200

        let accessoryView = SidebarSearchField()
        item.addTopAlignedAccessoryViewController(accessoryView)
        // NOTE: For some reason, we need to set the delegate *after* adding the
        // view to the item, or else it will get unset.
        accessoryView.delegate = self.sidebarVC

        return item
    }()

    lazy var detailItem: NSSplitViewItem = {
        let item = NSSplitViewItem(viewController: self.detailVC)
        item.automaticallyAdjustsSafeAreaInsets = true
        return item
    }()

    lazy var inspectorItem: NSSplitViewItem = {
        let item = NSSplitViewItem(inspectorWithViewController: self.inspectorVC)
        item.allowsFullHeightLayout = true
        item.titlebarSeparatorStyle = .line
        // item.collapseBehavior = .useConstraints
        item.minimumThickness = 280
        item.maximumThickness = 600
        //item.isCollapsed = true
        return item
    }()

    // MARK: - Initialization

    init(_ flow: SharedModels::Flow, _ assetStore: AssetStore) {
        self.flow = flow
        self.assetStore = assetStore
        // self.pasteboardController = .init(.ini)

        super.init(nibName: nil, bundle: nil)

        self.backendRunner = .init(flow, .init(self), assetStore)
        self.sidebarVC = .init(globalCoordinator: .init(self))
        self.detailVC = .init(self.flow, .init(self), self.assetStore)
        self.inspectorVC = .init(self.flow, .init(self))
        self.pasteboardController = .init(.init(self))

        self.flow.emitter.on({ [weak self] event in
            self?.onFlowEvent(event)
        }).store(in: &self.cancellables)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Events

    func onFlowEvent(_ event: FlowEvent) {
        switch event {
        case let .didEndPortDragWithoutCreatingEdge(typedPortLocation, canvasPosition, travelDistance):
            if travelDistance >= GlobalConstants.minTravelDistanceToCreateNode {
                self.perform(
                    userAction: .showNodeSearch(typedPortLocation: typedPortLocation, canvasPosition: canvasPosition)
                )
            }
        default:
            break
        }
    }

    // MARK: - NSViewController

    override func viewDidLoad() {
        self.addSplitViewItem(self.sidebarItem)
        self.addSplitViewItem(self.detailItem)
        self.addSplitViewItem(self.inspectorItem)

        //        print("\(self.splitView.maxPossiblePositionOfDivider(at: 1))")
        //        print("\(self.splitView.minPossiblePositionOfDivider(at: 1))")
        //        self.splitView.setPosition(500, ofDividerAt: 1)
        //
        //        print("\(self.splitView.maxPossiblePositionOfDivider(at: 0))")
        //        print("\(self.splitView.minPossiblePositionOfDivider(at: 0))")

        self.view.addSubview(NSHostingView(rootView: ModalContainerView(vm: self.modalContainerVM)))

        Task {
            self.backendRunner.run()
        }
    }

    override func viewDidAppear() {
        //        self.splitView.setPosition(500, ofDividerAt: 1)
        //        self.splitView.setPosition(500, ofDividerAt: 1)
        //        self.splitView.setPosition(500, ofDividerAt: 1)
    }

    #if os(macOS)
    let maxZoom: CGFloat = 4
    #else
    let maxZoom: CGFloat = 1
    #endif
    let minZoom: CGFloat = 0.1

    override func splitViewWillResizeSubviews(_ notification: Notification) {
        let s = self.detailVC.view.safeAreaInsets
        self.detailVC.updateSafeAreaInsets(s)
        // self.inspectorVC.view.additionalSafeAreaInsets = s
    }
}

// MARK: - Nodes

extension MainViewController {
    /// Creates a node of a given `NodeKind` at the given `Point`. If the `point` is `nil`, the
    /// node will be created at the center of the visible area of the canvas.
    /// - Parameters:
    ///   - kind: The `NodeKind` of the node to be created.
    ///   - point: The optional `Point` where to create tne node at.
    ///
    func newNode(kind: NodeKind, at point: Point?) {
        self.newNode(node: .init(kind: kind), centeredAt: point, typedPort: nil)
    }

    /// Adds the given `node` to the flow graph, at the given `Point`, while
    /// connecting it to the port of an extisting node given by `typedPort`.
    ///
    /// This method will try to estimate the node's dimensions so as to place
    /// the port connected to `typetPort` at the position defined by the given `point`.
    /// - Parameters:
    ///   - node: The new `FlowNode`.
    ///   - point: The optional point to create the node at.
    ///   - typedPort: The optonal existing port it will be connected to.
    ///
    func newNode(node: FlowNode, centeredAt point: Point?, typedPort: TypedPortLocation?) {
        let point = point ?? .canvasView(self.canvasView.safeAreaRect.center)
        let nodeView = NodeView(node)
        let nodeSize = nodeView.intrinsicContentSize
        nodeView.frame.size = nodeSize
        let nodeTopLeft = point.canvas(view: view, viewport: self.canvasView.viewport).cgPoint
        let pos = nodeTopLeft - (nodeSize.cgPoint * 0.5)
        nodeView.setNeedsLayout()
        nodeView.layoutIfNeeded()
        if let typedPort {
            let maybeSlot = self.flow.newNodeAction(
                node,
                at: pos,
                connectingToExistingPort: typedPort,
                undoManager: self.undoManager
            )
            if let slot = maybeSlot, let portView = nodeView.portView(slot) {
                let portPos = nodeView.convert(portView.bounds.center, from: portView)
                let newPos = nodeTopLeft - portPos
                self.flow.nodePositions[node.id] = newPos
            }
        } else {
            self.flow.newNodeAction(
                node,
                at: pos,
                undoManager: self.undoManager
            )
        }
        self.undoManager?.setActionName("New Node")
        self.flow.select([node.id])
    }
}

// MARK: - Helpers

extension Point {
    @MainActor
    func canvas(
        view: XView,
        viewport: CanvasView.Viewport
    ) -> Point {
        switch self {
        case .canvas: self
        case .canvasView(let point): .canvasView(viewport.convert(point, from: .screen, to: .canvas))
        case .window(let point): .canvasView(view.convert(point, from: nil)).canvas(view: view, viewport: viewport)
        }
    }
}

// MARK: - MainViewController + RenameNodeSheetViewController.Delegate

extension MainViewController: RenameNodeSheetViewController.Delegate {
    func renameNodeSheetDidConfirm(_ node: UUID, _ newName: String) {
        self.flow.setNodeName(id: node, newValue: newName, undoManager: self.undoManager)
    }

    func renameNodeSheetDidCancel() {}
}

#endif
