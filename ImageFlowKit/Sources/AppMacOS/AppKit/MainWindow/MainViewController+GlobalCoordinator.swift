import AssetBrowserFeature
import Foundation
import NodePaletteFeature
import SharedModels
import Values

#if canImport(AppKit)
import AppKit
#endif

extension MainViewController: GlobalCoordinatorProtocol {

    func assetTitle(_ asset: UUID) -> String? {
        self.assetStore.assets[asset]?.originalFilename
    }

    func perform(userAction: SharedModels.UserAction) {
        logger.info("userAction: \("\(userAction)")")

        switch userAction {
        case let .newNodeWithKind(kind, point):
            self.newNode(kind: kind, at: point)
        case let .newNode(node, point, port):
            self.newNode(node: node, centeredAt: point, typedPort: port)
        case let .openAssetPicker(node, portIndex, kind):
            self.presentAsSheet(
                AssetBrowserSheetController(
                    assetStore: self.assetStore,
                    coordinator: .init(self),
                    type: .picker(.init(assetKind: kind, portLocation: .init(node: node, index: portIndex))),
                    delegate: self
                )
            )
        case .openAssetBrowser:
            self.presentAsSheet(
                AssetBrowserSheetController(
                    assetStore: self.assetStore,
                    coordinator: .init(self),
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
        case .viewport(.setZoom(let zoom, let anim)):
            self.canvasView.setZoom(zoom, anim)
        case .viewport(.setOrigin(let origin)):
            self.canvasView.setOrigin(origin)
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
        case .pasteNodes(let items, let point):
            self.pasteNodes(items, point)
        case .selectAllNodes:
            self.flow.selectAll()
        case .selectNodesConnectedToPort(let port):
            self.selectNodesConnectedToPort(port)
        case .dropPasteImages(let payload):
            self.dropPasteImages(payload)
        case .selectNone:
            self.flow.selectNone()
        case .showNodeSearch(let typedPort, let canvasPosition):
            self.showNodeSearch(typedPort, canvasPosition)
        case .convertNode(let id, let kind):
            self.flow.convertNodeAction(id, kind: kind, undoService: self.undoService)
            self.undoService.setActionName("Convert Node", icon: .systemIconNode)
        case .setCanvasViewPort(let viewport):
            self.canvasView.viewport = .init(origin: viewport.origin, scale: viewport.scale)
        case .setNodeInputValue(port: let port, let newValue, let oldValue, let undo):
            self.setNodeInputValue(port, newValue, oldValue, undo)
        case .restoreNodeInputDefaultValue(let port):
            self.restoreNodeInputDefaultValue(port)
        case .createBookmark:
            self.detailVC.canvasVC.createBookmark()
        case .removeBookmark(let id):
            self.detailVC.canvasVC.removeBookmark(id)
        case .renameBookmark(let id, let name):
            self.detailVC.canvasVC.renameBookmark(id, name)
        case .statusBarMessage(let maybeMessage):
            self.detailVC.canvasVC.statusBarMessage(message: maybeMessage)
        default:
            logger.warning("Unhandled userAction: \("\(userAction)")")
        }
    }

    func selectNodesConnectedToPort(_ port: PortLocation) {
        switch port.slot {
        case .input(let index):
            self.flow.select(nodeConnectedToNode: port.node, atInputPort: index)
        case .output(let index):
            self.flow.select(nodesConnectedToNode: port.node, atOutputPort: index)
        }
    }

    func restoreNodeInputDefaultValue(_ port: InputPortLocation) {
        self.flow.restoreDefaultValue(id: port.node, index: port.index, undoService: self.undoService)
        self.undoService.setActionName("Restore Default Value", icon: .systemIconValue)
    }

    func setNodeInputValue(_ port: InputPortLocation, _ newValue: Value, _ oldValue: Value?, _ undo: Bool) {
        self.flow.setNodeValue(
            id: port.node,
            index: port.index,
            oldValue: oldValue,
            newValue: newValue,
            undoService: undo ? self.undoService : nil
        )
        if undo {
            self.undoService.setActionName("\(newValue.type.displayName) Value Change", icon: .systemIconValue)
        }
    }

    func dropPasteImages(_ info: UserAction.DropPasteImages) {
        switch info.payload {
        case .data(let data):
            Task {
                let id = try await self.assetStore.importAsset(
                    fromData: data.data,
                    filename: data.filename,
                    kind: .image,
                    undoService: self.undoService,
                )
                if case let .canvas(maybePoint) = info.target {
                    let canvasPos =
                        maybePoint?.canvas(view: self.canvasView, viewport: self.canvasView.viewport).cgPoint
                        ?? self.pasteCanvasPosition()
                    var node = FlowNode(kind: .valueNode(.image))
                    node.inputs[0].value = .image(.asset(id))
                    self.newNode(node: node, centeredAt: .canvas(canvasPos), typedPort: nil)
                }
                self.undoService.setActionName("Import Image", icon: "photo")
            }
        case .url(let urls):
            for (idx, url) in urls.enumerated() {
                let offset: CGFloat = 80 * Double(idx)
                Task {
                    let id = try await self.assetStore.importAsset(
                        fromURL: url,
                        kind: .image,
                        undoService: self.undoService
                    )
                    if case let .canvas(maybePoint) = info.target {
                        let canvasPos =
                            maybePoint?.canvas(view: self.canvasView, viewport: self.canvasView.viewport).cgPoint
                            ?? self.pasteCanvasPosition()
                        var node = FlowNode(kind: .valueNode(.image))
                        node.inputs[0].value = .image(.asset(id))
                        self.newNode(
                            node: node,
                            centeredAt: .canvas(canvasPos + .init(x: offset, y: offset)),
                            typedPort: nil
                        )
                    }
                    self.undoService.setActionName("Import Image", icon: "photo")
                }
            }
            break
        }
    }

    func showNodeSearch(_ typedPortLocation: TypedPortLocation?, _ canvasPosition: CGPoint?) {
        let position = canvasPosition ?? self.canvasView.bounds.center
        let rect = CGRect(x: position.x - 1, y: position.y - 1, width: 2, height: 2)

        self.present(
            NodePaletteSearchPopoverController { [weak self] item in
                Task {
                    self?.perform(
                        userAction: .newNode(
                            .init(kind: item.nodeKind),
                            at: .canvasView(position),
                            connectingToExistingPort: typedPortLocation
                        )
                    )
                }
            },
            asPopoverRelativeTo: rect,
            of: self.canvasView,
            preferredEdge: .maxY,
            behavior: .transient
        )
    }

    func nodes(forTarget target: UserAction.Target) -> Set<UUID> {
        switch target {
        case .nodes(let nodes): nodes
        case .selection: self.flow.selection
        }
    }

    func pasteCanvasPosition() -> CGPoint {
        #if os(macOS)
        let viewport = self.canvasView.viewport
        let view = self.canvasView

        guard let mouseWindowPos = NSApp.keyWindow?.mouseLocationOutsideOfEventStream else {
            return viewport.convert(view.bounds.center, from: .screen, to: .canvas)
        }

        let mouseCanvasPos = view.convert(mouseWindowPos, from: nil)
        if view.safeAreaRect.contains(mouseCanvasPos) {
            return viewport.convert(mouseCanvasPos, from: .screen, to: .canvas)
        } else {
            return viewport.convert(view.bounds.center, from: .screen, to: .canvas)
        }
        #elseif os(iOS)
        fatalError("TODO: Implement this")
        #endif
    }

    func pasteNodes(_ items: [FlowPasteboardItem], _ point: Point?) {
        guard !items.isEmpty else {
            logger.warning("Attemping to paste 0 items!")
            return
        }

        if items.count > 1 {
            logger.warning("Attemping to paste more thaen 1 pasteboard item!")
        }

        let point = self.pasteCanvasPosition()

        if let item = items.first {
            self.flow.paste(
                pasteboardData: item.flowPasteboardData,
                at: point,
                undoService: self.undoService
            )
        }
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
        self.flow.duplidateSelectedNodesAction(undoService: self.undoService)
    }

    func cutNodes(_ target: UserAction.Target) {
        let nodes = self.nodes(forTarget: target)

        if nodes.isEmpty { return }

        self.copyNodes(.nodes(nodes))
        self.flow.deleteNodesAction(nodes, undoService: self.undoService)
        self.undoService.setActionName("Cut \(nodes.nodeName)", icon: .systemIconMenuCut)
    }

    func deleteNodes(_ target: UserAction.Target) {
        let nodes = self.nodes(forTarget: target)

        if nodes.isEmpty { return }

        self.flow.deleteNodesAction(nodes, undoService: self.undoService)
        self.undoService.setActionName("Delete \(nodes.nodeName)", icon: .systemIconMenuDelete)
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
