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
        case .showNodeSearch(let typedPort, let canvasPosition):
            self.showNodeSearch(typedPort, canvasPosition)
        default:
            logger.warning("Unhandled userAction: \("\(userAction)")")
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
