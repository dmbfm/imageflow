import Backend
import Helpers
import Logging
import Photos
import SwiftUI
import Values

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
            openAssetPicker: { picker in
                self.openAssetPicker(picker)
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
        case .cancel:
            break
        case let .pick(assetKind, assetId, portLocation):
            if let value: Value = .init(assetKind: assetKind, assetId: assetId) {
                assert(
                    self.flow.nodes[portLocation.node]![valueAt: .input(portLocation.index)].type == assetKind.valueType
                )
                self.flow.nodes[portLocation.node]![valueAt: .input(portLocation.index)] = value
            } else {
                log("Failed to create value for asset: kind: \(assetStore), id: \(assetId)", level: .error)
            }
        case let .create(assetKind, assetId):
            if let value: Value = .init(assetKind: assetKind, assetId: assetId), let nodeKind = assetKind.nodeKind,
                let inputIndex = assetKind.nodeInputIndex
            {
                var node = FlowNode(id: .init(), kind: nodeKind)
                assert(node.inputs[inputIndex].value.type == assetKind.valueType)
                node.inputs[inputIndex].value = value
                self.createNodeAtCanvasCenter(node)
            } else {
                log("Failed to create value for asset: kind: \(assetStore), id: \(assetId)", level: .error)
            }
        }
    }

    func fileImporterCompletionHandler(_ res: Result<[URL], any Error>) {
        guard case let .success(urls) = res else { return }

        Task {

            var erroredTypes = Set<UTType>()

            for url in urls {
                do {
                    _ = url.startAccessingSecurityScopedResource()
                    guard let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey]),
                        let utType = resourceValues.contentType
                    else { continue }
                    url.stopAccessingSecurityScopedResource()

                    guard let kind = utType.assetKind else {
                        erroredTypes.insert(utType)
                        continue
                    }

                    // if kind == .lut {
                    //     erroredTypes.insert(utType)
                    //     continue
                    // }

                    try await self.assetStore.addAsset(fromURL: url, kind: kind, undoManager: self.undoManager)
                    self.undoManager?.setActionName("Import Image")
                } catch {
                    log("failed to import file: \(url): \(error)")
                }
            }

            if !erroredTypes.isEmpty {
                #if os(macOS)
                self.error = .init(inner: UserError.importFilesNotSupported(erroredTypes))
                #else
                fatalError("TODO: on iOS alerts must be placed *inside* the sheet view.")
                #endif
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

    func openAssetBrowser(_ allowedAssetKinds: AssetKindSet = .all) {
        self.assetBrowserType = .browser(.init(assetKinds: allowedAssetKinds))
        self.showAssetBrowser = true
    }

    func openAssetPicker(_ picker: AssetBrowserType.Picker) {
        self.assetBrowserType = .picker(picker)
        self.showAssetBrowser = true
        Task { @MainActor in
            try! await Task.sleep(for: .milliseconds(1))
            self.assetBrowserType = .picker(picker)
        }
    }
}

extension Value {
    fileprivate init?(assetKind: AssetKind, assetId: UUID) {
        self =
            switch assetKind {
            case .image: .image(.asset(assetId))
            case .lut: .lut(assetId)
            }
    }
}

extension AssetKind {
    fileprivate var nodeKind: NodeKind? {
        switch self {
        case .image: .valueNode(.image)
        case .lut: .valueNode(.lut)
        }
    }

    fileprivate var nodeInputIndex: Int? {
        switch self {
        case .image: 0
        case .lut: 0
        }
    }
}

struct LocalizedAlertError: LocalizedError {
    var inner: any LocalizedError

    var errorDescription: String? {
        self.inner.errorDescription
    }

    var failureReason: String? {
        self.inner.failureReason
    }

    var helpAnchor: String? {
        self.inner.helpAnchor
    }

    var recoverySuggestion: String? {
        self.inner.recoverySuggestion
    }
}

extension View {
    func errorAlert(_ error: Binding<LocalizedAlertError?>) -> some View {
        self
            .alert(
                isPresented: .constant(error.wrappedValue != nil),
                error: error.wrappedValue,
                actions: {
                    Button("OK") {
                        error.wrappedValue = nil
                    }
                }
            )
    }
}
