import AssetBrowserFeature
import AssetManager
import Backend
import CanvasFeature
import Foundation
import Helpers
import Logging
import NodeView
import Photos
import PhotosUI
import SharedModels
import SwiftUI
import UniformTypeIdentifiers
import Values

import class SharedModels.Flow

@Observable
@MainActor
final class MainContentViewModel {
    let flow: Flow
    let canvas: CanvasFeatureState
    let assetStore: AssetStore
    let assetBrowserViewModel: AssetBrowserViewModel

    var showAssetBrowser: Bool = false
    var showFileImporter: Bool = false {
        didSet {
            if self.showFileImporter != oldValue {
                self.onChangeOfShowFileImporter()
            }
        }
    }
    var showPhotoPicker: Bool = false {
        didSet {
            if self.showPhotoPicker != oldValue {
                self.onChangeOfShowPhotoPicker()
            }
        }
    }
    var selectedPhotoPickerItems: [PhotosPickerItem] = [] {
        didSet {
            if self.selectedPhotoPickerItems != oldValue {
                self.onChangeOfPhotoPickerItems()
            }
        }
    }
    var canvasAction: CanvasFeatureView.Action?
    var error: LocalizedAlertError? = nil
    var undoManager: UndoManager? = nil

    #if os(iOS)
    var showNodePaletteModal: Bool = false
    var assetBrowserError: LocalizedAlertError? = nil
    #endif

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

    func focusDidChange(_ focus: FocusState<Focus?>.Binding) {
        log("focusDidChange:focus:\(focus.wrappedValue, default: "nil")", level: .info)
        if focus.wrappedValue == nil {
            focus.wrappedValue = .global
            log("focusDidChange:focus:nil -> \(focus.wrappedValue, default: "nil")", level: .info)
        }
    }

    func onDoubleClick(nodePaletteItem item: NodePaletteItem) {
        self.createNodeAtCanvasCenter(fromPaletteItem: item)
    }

    var onDeleteCommand: (() -> ())? {
        if !self.flow.selection.isEmpty {
            { [weak self] in self?._onDeleteCommand() }
        } else {
            nil
        }
    }

    func _onDeleteCommand() {
        self.flow.deleteSelectedNodesAction(undoManager: self.undoManager)
    }

    func onKeyPressSpace() -> KeyPress.Result {
        self.canvasAction = .showNodeSearchPopover
        return .handled
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

        func inner() async {
            var erroredTypes = Set<UTType>()

            func processURL(_ url: URL) async {
                do {
                    _ = url.startAccessingSecurityScopedResource()
                    guard let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey]),
                        let utType = resourceValues.contentType
                    else { return }
                    url.stopAccessingSecurityScopedResource()

                    guard let kind = utType.assetKind else {
                        erroredTypes.insert(utType)
                        return
                    }

                    try await self.assetStore.addAsset(fromURL: url, kind: kind, undoManager: self.undoManager)
                    self.undoManager?.setActionName("Import Image")
                } catch {
                    log("failed to import file: \(url): \(error)")
                }
            }

            for url in urls {
                await processURL(url)
            }

            if !erroredTypes.isEmpty {
                #if os(macOS)
                self.error = .init(inner: UserError.importFilesNotSupported(erroredTypes))
                #else
                self.assetBrowserError = .init(inner: UserError.importFilesNotSupported(erroredTypes))
                #endif
            }
        }

        let _: Task<(), Never> = Task { await inner() }
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
        self.showAssetBrowser = true
    }
}

extension MainContentViewModel: NodeViewDelegate {
    func nodeViewSelectedNodesCount() -> Int {
        self.flow.selection.count
    }

    func nodeViewAction(_ action: NodeViewContextMenuAction) {
        switch action {
        case .deleteSelectedNodes:
            self.flow.deleteSelectedNodesAction(undoManager: self.undoManager)
        case .duplicateSelectedNodes:
            self.flow.duplidateSelectedNodesAction(undoManager: self.undoManager)
        }
    }

    func nodeView(willShowContextMenuForNode node: UUID) {
        self.flow.selectNodeIfNotSelected(node)
    }

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

public struct LocalizedAlertError: LocalizedError {
    var inner: any LocalizedError

    public var errorDescription: String? {
        self.inner.errorDescription
    }

    public var failureReason: String? {
        self.inner.failureReason
    }

    public var helpAnchor: String? {
        self.inner.helpAnchor
    }

    public var recoverySuggestion: String? {
        self.inner.recoverySuggestion
    }
}

extension View {
    public func errorAlert(_ error: Binding<LocalizedAlertError?>) -> some View {
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
