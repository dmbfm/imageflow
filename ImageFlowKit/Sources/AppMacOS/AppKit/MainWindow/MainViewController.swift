#if os(macOS)
import AppKit
import AssetBrowserFeature
import AssetManager
import Backend
import CanvasFeature
import SharedModels
import BackendService
import CanvasView
import NodeView
import Helpers

final class MainViewController: NSSplitViewController {

    // MARK: - Properties

    var flow: SharedModels::Flow
    var assetStore: any AssetStoreService
    var backendRunner: BackendRunner
    var sidebarVC: SidebarViewController!
    var detailVC: DetailViewController!
    var inspectorVC: InspectorViewController!

    // MARK: - Computed Properties

    var canvasView: CanvasPlatformView {
        self.detailVC.canvasView
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
        return item
    }()

    // MARK: - Initialization

    init(_ flow: SharedModels::Flow, _ assetStore: AssetStoreService) {
        self.flow = flow
        self.assetStore = assetStore
        self.backendRunner = .init(flow, assetStore.assetManager)

        super.init(nibName: nil, bundle: nil)

        self.sidebarVC = .init()
        self.detailVC = .init(self.flow, self.assetStore)
        self.inspectorVC = .init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - NSViewController

    override func viewDidLoad() {
        self.addSplitViewItem(self.sidebarItem)
        self.addSplitViewItem(self.detailItem)
        self.addSplitViewItem(self.inspectorItem)
    }

    #if os(macOS)
    let maxZoom: CGFloat = 4
    #else
    let maxZoom: CGFloat = 1
    #endif
    let minZoom: CGFloat = 0.1
}

// MARK: - ImageFlowCoordinatorProtocol

extension MainViewController: ImageFlowCoordinatorProtocol {
    func perform(userAction: SharedModels.UserAction) {
        logger.info("userAction: \("\(userAction)")")

        switch userAction {
        case let .newNodeWithKind(kind, point):
            self.newNode(kind: kind, at: point)
        case let .newNode(node, point, port):
            self.newNode(node: node, at: point, typedPort: port)
        case let .openAssetPicker(node, portIndex, kind):
            self.presentAsSheet(
                AssetBrowserSheetController(
                    assetStore: self.assetStore,
                    type: .picker(.init(assetKind: kind, portLocation: .init(node: node, index: portIndex))),
                    delegate: self
                )
            )
        default:
            logger.warning("Unhandled userAction: \("\(userAction)")")
            break
        }
    }

    public func currentZoom() -> CGFloat {
        self.canvasView.viewport.scale
    }

    public func canZoomIn() -> Bool {
        self.currentZoom() < self.maxZoom
    }

    public func canZoomOut() -> Bool {
        self.currentZoom() > self.minZoom
    }

    func nodeCount() -> Int {
        self.flow.nodes.count
    }

    func selectedNodeCount() -> Int {
        self.flow.selection.count
    }
}

extension MainViewController {
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
        self.newNode(node: .init(kind: kind), at: point, typedPort: nil)
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
    func newNode(node: FlowNode, at point: Point?, typedPort: TypedPortLocation?) {
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
        self.flow.select([node.id])
    }
}

extension Point {
    @MainActor
    func canvas(
        view: PlatformView,
        viewport: CanvasView.Viewport
    ) -> Point {
        switch self {
        case .canvas: self
        case .canvasView(let point): .canvasView(viewport.convert(point, from: .screen, to: .canvas))
        case .window(let point): .canvasView(view.convert(point, from: nil)).canvas(view: view, viewport: viewport)
        }
    }
}
#endif
