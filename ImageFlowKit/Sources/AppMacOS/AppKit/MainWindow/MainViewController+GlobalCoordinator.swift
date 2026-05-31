import AssetBrowserFeature
import Foundation
import NodePaletteFeature
import SharedModels

#if canImport(AppKit)
import AppKit
#endif

extension MainViewController: GlobalCoordinatorProtocol {
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
        case .pasteNodes(let items, let point):
            self.pasteNodes(items, point)
        case .selectAllNodes:
            self.flow.selectAll()
        case .dropPasteImages(let payload):
            self.dropPasteImages(payload)
        case .selectNone:
            self.flow.selectNone()
        case .showNodeSearch(let typedPort, let canvasPosition):
            self.showNodeSearch(typedPort, canvasPosition)
        case .convertNode(let id, let kind):
            self.flow.convertNodeAction(id, kind: kind, undoManager: self.undoManager)
            self.undoManager?.setActionName("Convert Node")
        default:
            logger.warning("Unhandled userAction: \("\(userAction)")")
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
                    undoManager: self.undoManager
                )
                if case let .canvas(maybePoint) = info.target {
                    let canvasPos =
                        maybePoint?.canvas(view: self.canvasView, viewport: self.canvasView.viewport).cgPoint
                        ?? self.pasteCanvasPosition()
                    var node = FlowNode(kind: .valueNode(.image))
                    node.inputs[0].value = .image(.asset(id))
                    self.newNode(node: node, centeredAt: .canvas(canvasPos), typedPort: nil)
                }
                self.undoManager?.setActionName("Import Image")
            }
        case .url(let urls):
            for (idx, url) in urls.enumerated() {
                let offset: CGFloat = 80 * Double(idx)
                Task {
                    let id = try await self.assetStore.importAsset(
                        fromURL: url,
                        kind: .image,
                        undoManager: self.undoManager
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
                    self.undoManager?.setActionName("Import Image")
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
                undoManager: self.undoManager
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
