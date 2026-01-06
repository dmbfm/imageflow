import Backend
import Foundation
import Helpers
import Logging
import Photos
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import Values

@Observable
@MainActor
final class MainContentViewModel: ObservableObject {
    let flow: Flow
    let canvas: CanvasFeatureState
    let assetStore: AssetStore
    let assetBrowserViewModel: AssetBrowserViewModel

    // var assetBrowserType: AssetBrowserType = .browser(.init(assetKinds: .all))
    var showAssetBrowser: Bool = false
    var showFileImporter: Bool = false
    var showPhotoPicker: Bool = false
    var selectedPhotoPickerItems: [PhotosPickerItem] = []
    var error: LocalizedAlertError? = nil
    var undoManager: UndoManager? = nil

    @ObservationIgnored var canvasCenter: CGPoint = .zero
    @ObservationIgnored var fileImporterConfiguration: FileImporterConfiguration = .init(
        allowedContentTypes: [])

    struct FileImporterConfiguration {
        var allowedContentTypes: [UTType]
    }

    init(flow: Flow, canvas: CanvasFeatureState, assetStore: AssetStore) {
        self.flow = flow
        self.canvas = canvas
        self.assetStore = assetStore
        self.assetBrowserViewModel = .init(
            assetsProvider: assetStore,
            allowedAssetKinds: .all,
            allowedImportTypes: [],
            photoPickerDisabled: true
        )
        self.assetBrowserViewModel.delegate = self
    }

    func onDoubleClick(nodePaletteItem item: NodePaletteItem) {
        self.createNodeAtCanvasCenter(fromPaletteItem: item)
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
        let pos: CGPoint = {
            let view = NodeView(node)
            let size = view.intrinsicContentSize
            let pos = self.canvasCenter - (size * 0.5).cgPoint
            return self.canvas.viewport.convert(pos, from: .screen, to: .canvas)
        }()
        self.flow.newNodeAction(node, at: pos, undoManager: self.undoManager)
        self.flow.select([node.id])
    }

    func onAssetBrowserDismiss(_ result: AssetBrowserResult) {
        switch result {
        case .cancel:
            break
        case let .pick(assetKind, assetId, portLocation):
            if let value: Value = Value(assetKind: assetKind, assetId: .asset(assetId)) {
                assert(
                    self.flow.nodes[portLocation.node]![valueAt: .input(portLocation.index)].type == assetKind.valueType
                )
                self.flow.nodes[portLocation.node]![valueAt: .input(portLocation.index)] = value
            } else {
                log("Failed to create value for asset: kind: \(assetStore), id: \(assetId)", level: .error)
            }
        case let .create(assetKind, assetId):
            if let value: Value = .init(assetKind: assetKind, assetId: .asset(assetId)),
                let nodeKind = assetKind.nodeKind,
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
                self.assetBrowserError = .init(inner: UserError.importFilesNotSupported(erroredTypes))
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
        self.assetBrowserViewModel.setType(.browser(.init(assetKinds: allowedAssetKinds)))
        self.showAssetBrowser = true
    }

    func openAssetPicker(picker: AssetBrowserType.Picker) {
        self.assetBrowserViewModel.setType(.picker(picker))
        // self.assetBrowserType = .picker(picker)
        self.showAssetBrowser = true
        // Task { @MainActor in
        //     try! await Task.sleep(for: .milliseconds(500))
        //     self.assetBrowserType = .picker(picker)
        // }
    }
}

extension MainContentViewModel: CanvasFeatureView.Delegate {
    func openAssetPicker(node: UUID, portIndex: Int, kind: AssetKind) {
        self.openAssetPicker(picker: .init(assetKind: kind, portLocation: .init(node: node, index: portIndex)))
    }

    func titleForAsset(id: Values.AssetIdentifier) -> String? {
        if case let .asset(id) = id {
            self.assetStore.assets[id]?.filename
        } else {
            nil
        }
    }
}

extension MainContentViewModel: AssetBrowserViewModel.Delegate {
    func onDismiss(_ result: AssetBrowserResult) {
        self.onAssetBrowserDismiss(result)
    }

    func openFileImporter(_ types: [UTType]) {
        log("openFileImporter:types:\(types)", level: .debug)
        self.showAssetBrowser = false
        self.fileImporterConfiguration = .init(allowedContentTypes: types)
        Task { @MainActor in
            self.showFileImporter = true
        }
    }

    func openPhotoPicker() {
        self.showAssetBrowser = false
        Task { @MainActor in
            self.showPhotoPicker = true
        }
    }

    func deleteAsset(_ asset: Asset) {
        self.assetStore.removeAsset(asset.id, undoManager: self.undoManager)
        self.undoManager?.setActionName("Delete Image")
    }
}

extension MainContentViewModel {
    enum UserError: LocalizedError {
        case importFilesNotSupported(Set<UTType>)

        var errorDescription: String? {
            switch self {
            case .importFilesNotSupported(let types):
                {
                    if types.isEmpty {
                        "Import failed: unsupported file type"
                    } else if types.count == 1 {
                        "Import failed: unsupported file type: \(types.first!.displayText)"
                    } else {
                        "The follwing file types are not supported: \(types.map({ $0.displayText }).joined(separator: ", "))"
                    }
                }()
            }
        }
    }
}

extension Value {
    fileprivate init?(assetKind: AssetKind, assetId: AssetIdentifier) {
        self =
            switch assetKind {
            case .image: .image(assetId)
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

extension UTType {
    var displayText: String {
        self.description
    }
}
