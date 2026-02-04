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
    /// The Flow model
    let flow: Flow
    /// The Global Coordinator the receive and send events from
    let coordinator: GlobalCoordinator
    /// The asset store
    let assetStore: AssetStore
    /// The view model for the asset browser sheet
    let assetBrowserViewModel: AssetBrowserViewModel
    /// The canvas viewport state
    let canvas: CanvasFeatureState
    /// If true show the Asset Browser sheet
    var showAssetBrowser: Bool = false
    /// If true show the file importer
    var showFileImporter: Bool = false {
        didSet {
            if self.showFileImporter != oldValue {
                self.onChangeOfShowFileImporter()
            }
        }
    }
    /// If true show the photo picker
    var showPhotoPicker: Bool = false {
        didSet {
            if self.showPhotoPicker != oldValue {
                self.onChangeOfShowPhotoPicker()
            }
        }
    }
    /// The user-selected photo picker items
    var selectedPhotoPickerItems: [PhotosPickerItem] = [] {
        didSet {
            if self.selectedPhotoPickerItems != oldValue {
                self.onChangeOfPhotoPickerItems()
            }
        }
    }
    /// The state of the image exporter dialog
    var imageExporterState: ImageExporterState {
        didSet {
            if !self.imageExporterState.isPresented && self.imageExporterState.image != nil {
                self.imageExporterState.image = nil
            }
        }
    }
    /// Error messages to be shown as an alert
    var error: LocalizedAlertError? = nil
    /// The undo manager from SwiftUI's evironment
    var undoManager: UndoManager? = nil

    @ObservationIgnored var canvasCenter: CGPoint = .zero

    @ObservationIgnored var fileImporterConfiguration: FileImporterConfiguration = .init(
        allowedContentTypes: [])

    @ObservationIgnored var cancellables: Set<AnyEventEmitterCancellable> = []

    #if os(iOS)
    /// The state of the node palette sheet
    var nodePaletteState: NodePaletteState = .init()

    /// Alert for errors related to asset importing
    var assetBrowserError: LocalizedAlertError? = nil

    struct NodePaletteState {
        var isPresented: Bool = false
        var typedPortLocation: TypedPortLocation?
        var canvasPosition: CGPoint?
    }

    #endif

    struct ImageExporterState {
        var isPresented: Bool = false
        var image: CIImage?
        var defaultFilename: String?
    }

    struct FileImporterConfiguration {
        var allowedContentTypes: [UTType]
    }

    init(flow: Flow, canvas: CanvasFeatureState, assetStore: AssetStore, coordinator: GlobalCoordinator) {
        self.flow = flow
        self.canvas = canvas
        self.assetStore = assetStore
        self.assetBrowserViewModel = .init(
            assetsProvider: assetStore,
            allowedAssetKinds: .all,
            allowedImportTypes: [],
            photoPickerDisabled: true
        )
        self.imageExporterState = .init(isPresented: false, image: nil)
        self.coordinator = coordinator
        self.assetBrowserViewModel.delegate = self

        self.coordinator.emitter.on({ [weak self] event in self?.onCoordinatorEvent(event) }).store(
            in: &self.cancellables
        )
    }

    func onCoordinatorEvent(_ event: GlobalCoordinatorEvent) {
    }

    func focusDidChange(_ focus: FocusState<Focus?>.Binding) {
        #if os(macOS)
        log("focusDidChange:focus:\(focus.wrappedValue, default: "nil")", level: .info)

        if focus.wrappedValue == nil {
            focus.wrappedValue = .global
            log("focusDidChange:focus:nil -> \(focus.wrappedValue, default: "nil")", level: .info)
        }
        #endif
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

    #if os(macOS)
    var onCopyCommand: (() -> [NSItemProvider])? {
        if !self.flow.selection.isEmpty {
            { self._onCopyCommand() }
        } else {
            nil
        }
    }

    func _onCopyCommand() -> [NSItemProvider] {
        Task { @MainActor in
            self.coordinator.perform(userAction: .copySelectedNodes)
        }

        return []
    }

    var onCutCommand: (() -> [NSItemProvider])? {
        if !self.flow.selection.isEmpty {
            {
                self._onCutCommand()
            }
        } else {
            nil
        }
    }

    func _onCutCommand() -> [NSItemProvider] {
        Task { @MainActor in
            self.coordinator.perform(userAction: .cutSelectedNodes)
        }

        return []
    }

    func onPasteCommand(_ items: [NSItemProvider]) {
        self.coordinator.perform(userAction: .pasteNodes(nil))
    }
    #endif

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

    @discardableResult
    func createNodeAtCanvasCenter(fromPaletteItem item: NodePaletteItem) -> FlowNode {
        let node = FlowNode(kind: item.nodeKind)
        self.createNodeAtCanvasCenter(node)
        return node
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

    // MARK: - Node Palette

    #if os(iOS)
    public func nodePalettePresent(typedPortLocation: TypedPortLocation? = nil, canvasPosition: CGPoint? = nil) {
        self.nodePaletteState = .init(
            isPresented: true,
            typedPortLocation: typedPortLocation,
            canvasPosition: canvasPosition
        )
    }

    func nodePaletteDismiss() {
        self.nodePaletteState = .init()
    }

    func nodePalettePositionForNode(_ item: NodePaletteItem) -> CGPoint {
        if let pos = self.nodePaletteState.canvasPosition {
            return pos
        } else {
            let view = NodeView(FlowNode(kind: item.nodeKind))
            let size = view.intrinsicContentSize
            let pos = self.canvasCenter - (size * 0.5).cgPoint
            return self.canvas.viewport.convert(pos, from: .screen, to: .canvas)
        }
    }

    func onNodePaletteSheetTapItem(_ item: NodePaletteItem) {
        let port = self.nodePaletteState.typedPortLocation
        let pos = self.nodePalettePositionForNode(item)

        self.nodePaletteDismiss()
        let node = FlowNode(kind: item.nodeKind)

        if let port {
            self.flow.newNodeAction(
                node,
                at: pos,
                connectingToExistingPort: port,
                undoManager: self.undoManager
            )
        } else {
            self.flow.newNodeAction(node, at: pos, undoManager: self.undoManager)
        }

        self.flow.select([node.id])
    }
    #endif

    func onAssetBrowserDismiss(_ result: AssetBrowserResult) {
        switch result {
        case .cancel:
            break
        case let .pick(assetKind, assetId, portLocation):
            self.onAssetBrowserPick(assetKind, assetId, portLocation)
        case let .create(assetKind, assetId):
            self.onAssetBrowserCreate(assetKind, assetId)
        }
    }

    func onAssetBrowserPick(_ assetKind: AssetKind, _ assetId: UUID, _ portLocation: InputPortLocation) {
        if let value: Value = Value(assetKind: assetKind, assetId: .asset(assetId)) {
            assert(
                self.flow.nodes[portLocation.node]![valueAt: .input(portLocation.index)].type == assetKind.valueType
            )
            self.flow.nodes[portLocation.node]![valueAt: .input(portLocation.index)] = value
        } else {
            log("Failed to create value for asset: kind: \(assetStore), id: \(assetId)", level: .error)
        }
    }

    func onAssetBrowserCreate(_ assetKind: AssetKind, _ assetId: UUID) {
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
                    log("failed to import file: \(url): \(error)", level: .error)
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

    func exportImage(_ nodeID: UUID) async throws {
        guard !self.imageExporterState.isPresented else {
            log("Image exporter is already being presented!", level: .warning)
            return
        }

        guard let node = self.flow.nodes[nodeID] else {
            log("node not found: \(nodeID)", level: .error)
            return
        }

        guard let index = node.outputs.firstIndex(where: { $0.type == .image }) else {
            log("node image outputs found for node: \(nodeID)", level: .error)
            return
        }

        let image = try await self.assetStore.getGeneratedResource(ciImageAt: .init(node: nodeID, index: index)).res

        self.imageExporterState = .init(
            isPresented: true,
            image: image,
            defaultFilename: node.name
        )
    }

    func showImageExporter(_ nodeID: UUID) {
        Task {
            do {
                try await self.exportImage(nodeID)
            } catch {
                log("\(error)", level: .error)
                self.error = .init(inner: SimpleMessageLocalizedError(message: error.localizedDescription))
            }
        }
    }

    func showImageExporter(_ image: CIImage, _ defaultFilename: String?) {
        self.imageExporterState = .init(isPresented: true, image: image, defaultFilename: defaultFilename)
    }
}

extension MainContentViewModel: AssetBrowserViewModel.Delegate {
    func onDismiss(_ result: AssetBrowserResult) {
        self.onAssetBrowserDismiss(result)
    }

    func openFileImporter(_ types: [UTType]) {
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

struct SimpleMessageLocalizedError: LocalizedError {
    var message: String

    var errorDescription: String? { self.message }
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
