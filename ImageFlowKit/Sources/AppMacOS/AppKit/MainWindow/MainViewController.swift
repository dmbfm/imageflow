#if os(macOS)
import AppKit
import AssetBrowserFeature
import AssetManager
import PreviewFeature
import Backend
import CanvasFeature
import SharedModels
import BackendService
import CanvasView
import NodeView
import Helpers
import XKit
import SwiftUI
import Combine

final class MainViewController: NSSplitViewController {

    // MARK: - Properties

    var flow: SharedModels::Flow
    var assetStore: any AssetStoreService
    var backendRunner: BackendRunner!
    var sidebarVC: SidebarViewController!
    var detailVC: DetailViewController!
    var inspectorVC: InspectorViewController!
    var emitter: EventEmitter<GlobalCoordinatorEvent> = .init()
    var modalContainerVM: ModalContainerViewModel = .init()
    var cancellables: Set<AnyEventEmitterCancellable> = []

    // MARK: - Computed Properties

    var canvasView: CanvasPlatformView {
        self.detailVC.canvasView
    }

    var previewVC: PreviewFeatureController {
        self.detailVC.previewVC
    }

    var canvasViewportPublisher: PassthroughSubject<CanvasView.Viewport, Never> {
        self.detailVC.canvasVC.viewportPublisher
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
        item.minimumThickness = 200
        item.maximumThickness = 400
        return item
    }()

    // MARK: - Initialization

    init(_ flow: SharedModels::Flow, _ assetStore: AssetStoreService) {
        self.flow = flow
        self.assetStore = assetStore

        super.init(nibName: nil, bundle: nil)

        self.backendRunner = .init(flow, .init(self), assetStore.assetManager, assetStore)
        self.sidebarVC = .init(globalCoordinator: .init(self))
        self.detailVC = .init(self.flow, .init(self), self.assetStore)
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

        self.view.addSubview(NSHostingView(rootView: ModalContainerView(vm: self.modalContainerVM)))

        Task {
            self.backendRunner.run()
        }
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
    }
}

// MARK: - ImageFlowCoordinatorProtocol

extension MainViewController: GlobalCoordinatorProtocol {
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
        case .openAssetBrowser:
            self.presentAsSheet(
                AssetBrowserSheetController(
                    assetStore: self.assetStore,
                    type: .browser(.init(assetKinds: .all)),
                    delegate: self,
                )
            )
        case let .exportImage(image, filename):
            self.modalContainerVM.showImageExporter(image, filename)
        case .viewport(.zoomIn):
            self.canvasView.zoomIn()
        case .viewport(.zoomOut):
            self.canvasView.zoomOut()
        case .viewport(.setZoom(let zoom)):
            self.canvasView.setZoom(zoom)
        case .rename(let id):
            self.showRenameSheet(forNode: id)
        case .exportPreviewedImage:
            self.previewVC.exportImage()
        case .copy(let target):
            self.copyNodes(target)
        case .cut(let target):
            self.cutNodes(target)
        case .delete(let target):
            self.deleteNodes(target)
        case .duplicate(let target):
            self.duplicateNodes(target)
        case .pasteNodes(let point):
            self.pasteNodes(point)
        case .selectAllNodes:
            self.flow.selectAll()
        case .selectNone:
            self.flow.selectNone()
        default:
            logger.warning("Unhandled userAction: \("\(userAction)")")
        }
    }

    func nodes(forTarget target: UserAction.Target) -> Set<UUID> {
        switch target {
        case .nodes(let nodes): nodes
        case .selection: self.flow.selection
        }
    }

    func pasteNodes(_ point: Point?) {
        func doPaste(data: FlowPasteboardData, at maybePos: CGPoint? = nil) {
            #if os(macOS)
            if let mwp = NSApp.keyWindow?.mouseLocationOutsideOfEventStream {
                let viewport = self.canvasView.viewport
                let view = self.canvasView
                let mp = view.convert(mwp, from: nil)
                var pos: CGPoint = .zero
                if view.safeAreaRect.contains(mp) {
                    pos = viewport.convert(mp, from: .screen, to: .canvas)
                } else {
                    pos = viewport.convert(view.bounds.center, from: .screen, to: .canvas)
                }

                self.flow.paste(pasteboardData: data, at: pos, undoManager: self.undoManager)
            }
            #endif

            #if os(iOS)
            if let pos = maybePos, let viewport = self.canvasViewModel?.viewport {
                let pastePos = viewport.convert(pos, from: .screen, to: .canvas)
                self.flow.paste(pasteboardData: data, at: pastePos, undoManager: self.undoManager)
            } else if let pastePos = self.pointerData?.positionInCanvas {
                self.flow.paste(pasteboardData: data, at: pastePos, undoManager: self.undoManager)
            } else if let centerPos = self.canvasViewModel?.view?.bounds.center,
                let viewport = self.canvasViewModel?.viewport
            {
                let pastePos = viewport.convert(centerPos, from: .screen, to: .canvas)
                self.flow.paste(pasteboardData: data, at: pastePos, undoManager: self.undoManager)
            }
            #endif
        }
        #if os(macOS)
        if let objects = NSPasteboard.general.readObjects(forClasses: [FlowPasteboardItem.self]) {
            for o in objects {
                if let data = (o as? FlowPasteboardItem?)??.flowPasteboardData {
                    doPaste(data: data, at: nil)
                }
            }
        }
        #endif

        #if os(iOS)
        let pb = UIPasteboard.general

        if let data = pb.data(forPasteboardType: UTType.flowNode.identifier),
            let flowPasteboardData = FlowPasteboardData(data: data)
        {
            let point: CGPoint? =
                if let point = maybePoint ?? (self.pointerData?.positionInCanvas).map({ Point.canvas($0) }),
                    let vm = self.canvasViewModel,
                    let view = vm.view
                {
                    point.canvas(view: view, viewport: vm.viewport).cgPoint
                } else {
                    nil
                }

            self.doPaste(data: flowPasteboardData, at: point)
        }
        #endif
    }

    func copyNodes(_ target: UserAction.Target) {
        let nodes = self.nodes(forTarget: target)

        if nodes.isEmpty { return }

        #if os(macOS)
        if let item = FlowPasteboardItem(nodes: nodes, self.flow) {
            NSPasteboard.general.clearContents()
            if !NSPasteboard.general.writeObjects([item]) {
                logger.error("Failed to write items to pasteboard!")
            }
        }
        #else
        let pb = UIPasteboard.general
        if let data = self.flow.pasteboardData(forNodes: nodes), let jsonData = data.jsonData {
            pb.setData(jsonData, forPasteboardType: UTType.flowNode.identifier)
        }
        #endif
    }

    func duplicateNodes(_ target: UserAction.Target) {
        logger.warning("TODO: implement duplicateNodes")
        // let nodes = self.nodes(forTarget: target)
        // if nodes.isEmpty { return }
    }

    func cutNodes(_ target: UserAction.Target) {
        let nodes = self.nodes(forTarget: target)

        if nodes.isEmpty { return }

        self.copyNodes(.nodes(nodes))
        self.flow.deleteNodesAction(nodes, undoManager: self.undoManager)
        self.undoManager?.setActionName("Cut \(nodes.nodeName)")
    }

    func deleteNodes(_ target: UserAction.Target) {
        let nodes = self.nodes(forTarget: target)

        if nodes.isEmpty { return }

        self.flow.deleteNodesAction(nodes, undoManager: self.undoManager)
        self.undoManager?.setActionName("Delete \(nodes.nodeName)")
    }

    func showRenameSheet(forNode id: UUID) {
        guard let node = self.flow.nodes[id] else {
            logger.warning("showRenameSheet: node not found: \(id)")
            return
        }
        self.presentAsSheet(RenameNodeSheetViewController(id, node.name, self))
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
