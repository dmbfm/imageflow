import Helpers
import Logging
import Photos
import SwiftUI

#if os(macOS)
typealias MainContentView = MainContentViewMacOS
#endif

#if os(iOS)
typealias MainContentView = MainContentViewIPadOS
#endif

protocol MainContentViewProtocol: View {
    init(flow: Flow, canvas: CanvasFeatureState, assetStore: AssetStore)
}

extension MainContentView: MainContentViewProtocol {}

extension MainContentView {

    var assetBrowserDelegate: AssetBrowserView.Delegate {
        .init(
            onDismiss: self.onAssetBrowserDismiss(_:),
            openFileImporter: {
                self.showAssetBrowser = false
                Task { @MainActor in
                    self.showFileImporter = true
                }
            },
            openPhotoPicker: {
                self.showAssetBrowser = false
                Task { @MainActor in
                    self.showPhotoPicker = true
                }
            }
        )
    }

    func onChangeOfShowFileImporter() {
        if !self.showFileImporter {
            self.showAssetBrowser = true
        }
    }

    func onChangeOfShowPhotoPicker() {
        if !self.showPhotoPicker {
            self.showAssetBrowser = true
        }
    }

    func createNodeAtCanvasCenter(fromPaletteItem item: NodePaletteItem) {
        let node = FlowNode(kind: item.nodeKind)
        self.createNodeAtCanvasCenter(node)
    }

    func createNodeAtCanvasCenter(_ node: FlowNode) {
        var node = node
        let pos: CGPoint = {
            let view = NodeView(node)
            let size = view.intrinsicContentSize
            let pos = self.canvasCenter.value - (size * 0.5).cgPoint
            return self.canvas.viewport.convert(pos, from: .screen, to: .canvas)
        }()
        node.position = pos
        self.flow.newNodeAction(node, undoManager: self.undoManager)
        self.flow.select([node.id])
    }

    func onAssetBrowserDismiss(_ result: AssetBrowserResult) {
        log("asset browser result: \(result), type: \(self.assetBrowserType)")
        switch result {
        case .create(let id):
            var node = FlowNode(id: .init(), kind: .valueNode(.image))
            node.inputs[0].value = .image(.asset(id))
            self.createNodeAtCanvasCenter(node)
        default:
            break
        }
    }

    func fileImporterCompletionHandler(_ res: Result<[URL], any Error>) {
        guard case let .success(urls) = res else { return }

        Task {
            for url in urls {
                do {
                    try await self.assetStore.addImage(fromURL: url, undoManager: self.undoManager)
                    self.undoManager?.setActionName("Import Image")
                } catch {
                    log("failed to import file: \(url): \(error)")
                }
            }
        }
    }

    func onChangeOfPhotoPickerItems() {
        if self.selectedPhotoPickerItems.isEmpty {
            return
        }

        let items = self.selectedPhotoPickerItems
        self.selectedPhotoPickerItems.removeAll()

        Task.detached {
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            if status != .authorized {
                log("Auth error!", level: .error)
                return
            }
            try await self.assetStore.addImageAssets(fromPhotosPickerItems: items, undoManager: self.undoManager)
        }
    }
}
