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

    struct FileImporterConfiguration {
        var allowedContentTypes: [UTType]
    }

    var canvasFeatureViewDelegate: CanvasFeatureView.Delegate {
        .init(
            openAssetPicker: { id, portIndex, configuration in
                self.openAssetPicker(.init(node: id, port: .input(portIndex)), configuration: configuration)
            },
            fetchAsset: { id in
                self.assetStore.assets[id]
            }
        )
    }

    var assetBrowserDelegate: AssetBrowserViewDelegate {
        .init(
            onDismiss: self.onAssetBrowserDismiss(_:),
            openFileImporter: { allowedTypes in
                self.showAssetBrowser = false
                self.fileImporterConfiguration.value = .init(allowedContentTypes: allowedTypes)
                Task { @MainActor in
                    self.showFileImporter = true
                }
            },
            openPhotoPicker: {
                self.showAssetBrowser = false
                Task { @MainActor in
                    self.showPhotoPicker = true
                }
            },
            deleteAsset: { asset in
                self.assetStore.removeAsset(asset.id, undoManager: self.undoManager)
                self.undoManager?.setActionName("Delete Image")
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
        switch result {
        case .create(let id):
            var node = FlowNode(id: .init(), kind: .valueNode(.image))
            node.inputs[0].value = .image(.asset(id))
            self.createNodeAtCanvasCenter(node)
        case .pick(let assetId):
            switch self.assetBrowserType {
            case .browser:
                break
            case .picker(let loc):
                self.flow.nodes[loc.node]![valueAt: loc.slot] = .image(.asset(assetId))
            }
        case .cancel:
            break
        }
    }

    func fileImporterCompletionHandler(_ res: Result<[URL], any Error>) {
        guard case let .success(urls) = res else { return }

        Task {
            for url in urls {
                do {
                    _ = url.startAccessingSecurityScopedResource()
                    guard let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey]),
                        let utType = resourceValues.contentType
                    else { continue }
                    url.stopAccessingSecurityScopedResource()

                    guard let kind = utType.assetKind else {
                        fatalError("TOD: Handle unsupported format: \(utType)")
                        continue
                    }

                    try await self.assetStore.addAsset(fromURL: url, kind: kind, undoManager: self.undoManager)
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
            try await self.assetStore.addAssets(fromPhotosPickerItems: items, undoManager: self.undoManager)
        }
    }

    func openAssetBrowser() {
        self.assetBrowserConfiguration = .init(allowedTypes: .all)
        self.assetBrowserType = .browser
        self.showAssetBrowser = true
    }

    func openAssetPicker(_ port: PortLocation, configuration: AssetBrowserConfiguration) {
        self.assetBrowserConfiguration = configuration
        self.showAssetBrowser = true
        Task { @MainActor in
            try! await Task.sleep(for: .milliseconds(1))
            self.assetBrowserType = .picker(port)
        }
    }
}
