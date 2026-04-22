import AssetManager
import Backend
import CanvasFeature
import CanvasView
import Combine
import ContextMenus
import Helpers
import Logging
import NodeView
import PreviewFeature
import SharedModels
import SwiftUI
import UniformTypeIdentifiers
import Values

import struct SharedModels.Edge
import class SharedModels.Flow

@Observable
@MainActor
public final class GlobalCoordinatorDefaultImpl: GlobalCoordinatorImpl {

    public var available: ComponentAvailability = .init()

    public var nodeSelectionCount: Int {
        self.flow.selection.count
    }

    public var canPaste: Bool {
        PasteboardObserver.shared.canPaste
    }

    #if os(macOS)
    let maxZoom: CGFloat = 4
    #else
    let maxZoom: CGFloat = 1
    #endif
    let minZoom: CGFloat = 0.1

    var currentZoom: CGFloat {
        self.canvasViewModel?.viewport.scale ?? 1.0
    }

    public var canZoomIn: Bool {
        self.currentZoom < self.maxZoom
    }

    public var canZoomOut: Bool {
        self.currentZoom > self.minZoom
    }

    #if os(iOS)
    public var pointerData: PointerData?
    #else
    public var pointerData: PointerData? {
        get {
            if let canvas = self.canvasViewModel,
                let view = canvas.view,
                let windowPos = NSApp.keyWindow?.mouseLocationOutsideOfEventStream
            {
                let canvasViewPos = view.convert(windowPos, from: nil)
                let canvasPos = canvas.viewport.convert(canvasViewPos, from: .screen, to: .canvas)
                return .init(positionInCanvasView: canvasViewPos, positionInCanvas: canvasPos)
            } else {
                return nil
            }
        }

        // swiftlint:disable unused_setter_value
        set {}
    }
    #endif

    public let flow: Flow

    private var activeViewObserver: ActiveViewObserver
    private var errorToShow: LocalizedAlertError?

    weak var previewState: PreviewFeatureState?
    weak var mainContentViewModel: MainContentViewModel? {
        didSet {
            self.mainContentViewModelDidChange()
        }
    }
    weak var canvasViewModel: CanvasFeatureViewModel?
    weak var dockedPreview: DockedPreviewMenuActionCoordinator?
    #if os(macOS)
    weak var windowPreviewViewModel: WindowPreviewViewModel?
    #endif

    public var hasWindowPreview: Bool = false

    @ObservationIgnored
    public var emitter: EventEmitter<SharedModels.GlobalCoordinatorEvent> = .init()

    @ObservationIgnored
    var cancellables: Set<AnyEventEmitterCancellable> = []

    @ObservationIgnored
    public var undoManager: UndoManager? = nil

    required public init(flow: SharedModels.Flow) {
        self.flow = flow
        self.activeViewObserver = .init()
        self.activeViewObserver.coordinator = self

        self.flow.emitter.on({ [weak self] event in
            self?.onFlowEvent(event)
        }).store(in: &self.cancellables)
    }

    private func mainContentViewModelDidChange() {
        if let vm = self.mainContentViewModel, let err = self.errorToShow {
            vm.error = err
            self.errorToShow = nil
        }
    }

    public func isAvailable(_ name: ComponentName) -> Bool {
        switch name {
        case .previewFeature: self.previewState != nil
        case .windowPreviewFeature:
            #if os(macOS)
            self.windowPreviewViewModel != nil
            #else
            false
            #endif
        }
    }

    func onFlowEvent(_ event: FlowEvent) {
        switch event {
        case let .didEndPortDragWithoutCreatingEdge(typedPortLocation, canvasPosition, travelDistance):
            if travelDistance >= GlobalConstants.minTravelDistanceToCreateNode {
                self.perform(
                    userAction: .showNodeSearch(typedPortLocation: typedPortLocation, canvasPosition: canvasPosition)
                )
            }
        case let .didDeleteNode(id):
            self.mainContentViewModel?.assetStore.remove(generatedAssetsForNode: id)
        case let .didDeleteEdge(edge):
            self.mainContentViewModel?.assetStore.remove(generatedAssetsForNode: edge.to.node)
        default:
            break
        }
    }

    public func titleForAsset(id: AssetIdentifier?) -> String? {
        if case let .asset(id) = id {
            self.mainContentViewModel?.assetStore.assets[id]?.filename
        } else {
            nil
        }
    }

    public func perform(internalAction action: InternalAction) {
        switch action {
        case .errorAlert(let err):
            if let vm = self.mainContentViewModel {
                vm.error = .init(inner: err)
                self.errorToShow = nil
            } else {
                self.errorToShow = .init(inner: err)
            }
        }
    }

    // swiftlint:disable function_body_length
    public func perform(userAction action: UserAction) {
        log("user action: \(action)", level: .info)
        switch action {
        case .newNode(let node, at: let point, let typedPort):
            self.newNode(node: node, at: point, typedPort: typedPort)
        case .newNodeWithKind(let kind, at: let point):
            self.newNode(kind: kind, at: point)
        case .copy(let target):
            self.copy(target)
        case .copySelectedNodes:
            self.copySelectedNodes()
        case .cut(let target):
            self.cut(target)
        case .cutSelectedNodes:
            self.cutSelectedNodes()
        case .delete(let target):
            self.delete(target)
        case .rename(let node):
            self.rename(node)
        case .deleteSelectedNodes:
            self.flow.deleteSelectedNodesAction(undoManager: self.undoManager)
        case .duplicate(let target):
            self.duplicate(target)
        case .duplicateSelectedNodes:
            self.flow.duplidateSelectedNodesAction(undoManager: self.undoManager)
        case .exportImageForNode(let id):
            self.mainContentViewModel?.showImageExporter(id)
        case .exportImage(let image, let filename):
            self.exportImage(image, filename)
        case .exportPreviewedImage:
            self.exportPreviewedImage()
        case .pasteNodes(let maybePosition):
            self.pasteFlowNodes(maybePosition)
            self.pasteImages(maybePosition)
        case .selectAllNodes:
            self.flow.selectAll()
        case .showNodeSearch(let typedPortLocation, let canvasPosition):
            self.showNodeSearch(typedPortLocation: typedPortLocation, canvasPosition: canvasPosition)
        case .preview(let action):
            self.perform(previewAction: action)
        case .selectNodesInteractive:
            self.canvasViewModel?.startInteractiveSelection()
        case .selectNone:
            self.flow.selectNone()
        case let .openAssetPicker(node, portIndex, kind):
            self.mainContentViewModel?.openAssetPicker(
                picker: .init(assetKind: kind, portLocation: .init(node: node, index: portIndex))
            )
        case .viewport(.zoomIn):
            self.canvasViewModel?.view?.perform(canvasAction: .zoomIn)
        case .viewport(.zoomOut):
            self.canvasViewModel?.view?.perform(canvasAction: .zoomOut)
        case .viewport(.setZoom(let value)):
            self.canvasViewModel?.view?.perform(canvasAction: .zoom(value))
        case .viewport(.zoomToFitContent):
            self.canvasViewModel?.view?.perform(canvasAction: .zoomToFitContent)
        case .viewport(.zoomToFitSelection):
            self.canvasViewModel?.view?.perform(canvasAction: .zoomToFitSelection(self.flow.selection))
        case .convertNode(let id, let kind):
            self.flow.convertNodeAction(id, kind: kind, undoManager: self.undoManager)
        case .disconnect(port: let port):
            self.flow.deleteEdge(connectedToInput: port, undoManager: self.undoManager)
        }
    }

    @discardableResult
    func perform(dockedPreviewAction action: UserAction.PreviewAction) -> Bool {

        guard let preview = self.dockedPreview else { return false }

        switch action {
        case .zoomIn:
            preview.action = .zoomIn
        case .zoomOut:
            preview.action = .zoomOut
        case .zoomToFit:
            preview.action = .zoomToFit
        case .actualSize:
            preview.action = .actualSize
        case .openWindow:
            #if os(macOS)
            if let loc = self.previewState?.location {
                self.previewState?.openPreviewWindow(loc)
            }
            #else
            break
            #endif
        }

        return true
    }

    func perform(windowPreviewAction action: UserAction.PreviewAction) -> Bool {

        #if os(iOS)
        return false
        #endif

        #if os(macOS)
        guard let preview = self.windowPreviewViewModel else { return false }

        switch action {
        case .zoomIn:
            preview.action = .zoomIn(animate: true)
        case .zoomOut:
            preview.action = .zoomOut(animate: true)
        case .zoomToFit:
            preview.action = .zoomToFit(animate: true)
        case .actualSize:
            preview.action = .actualSize(animate: true)
        case .openWindow:
            break
        }

        return true
        #endif
    }

    func perform(previewAction action: UserAction.PreviewAction) {
        if !self.perform(windowPreviewAction: action) {
            self.perform(dockedPreviewAction: action)
        }
    }

    func exportPreviewedImage() {
        #if os(macOS)
        if let preview = self.windowPreviewViewModel {
            preview.exportImage()
            return
        }
        #endif

        if let preview = self.previewState, let image = preview.image {
            self.exportImage(image, preview.name)
        }
    }

    func newNode(kind: NodeKind, at point: Point?) {
        self.newNode(node: .init(kind: kind), at: point, typedPort: nil)
    }

    func newNode(node: FlowNode, at point: Point?, typedPort: TypedPortLocation?) {
        if let view = self.canvasViewModel?.view, let viewport = self.canvasViewModel?.viewport {
            let point = point ?? .canvasView(view.safeAreaRect.center)
            let nodeView = NodeView(node)
            let nodeSize = nodeView.intrinsicContentSize
            nodeView.frame.size = nodeSize
            let nodeTopLeft = point.canvas(view: view, viewport: viewport).cgPoint
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
            self.flow.select([node.id])
        }
    }

    func pasteImages(_ maybePoint: Point? = nil) {
        #if os(iOS)
        let pb = UIPasteboard.general
        guard
            let (data, ext): (Data, String) = pb.data(forPasteboardType: "public.tiff").map({ ($0, "tiff") })
                ?? pb.data(forPasteboardType: "public.png").map({ ($0, "png") })
                ?? pb.data(forPasteboardType: "public.avif").map({ ($0, "avif") })
        else { return }
        #endif
        #if os(macOS)
        let pb = NSPasteboard.general

        guard
            let (data, ext) = pb.data(forType: .tiff).map({ ($0, "tiff") })
                ?? pb.data(forType: .png).map({ ($0, "png") })
        else { return }
        #endif

        Task { @MainActor in
            do {
                guard let vm = self.mainContentViewModel else { return }
                let id = try await vm.assetStore.addAsset(
                    data: data,
                    filename: "pastboard_image.\(ext)",
                    kind: .image,
                    undoManager: self.undoManager
                )
                self.undoManager?.setActionName("Paste Image")
                self.undoManager?.endUndoGrouping()

                var node = FlowNode(kind: .valueNode(.image))
                node.inputs[0].value = .image(.asset(id))
                self.undoManager?.beginUndoGrouping()
                self.flow.newNodeAction(node, at: self.pastePosition(), undoManager: self.undoManager)
                log("pasteImages: id: \(id)")
            } catch {
                log("pasteImages: \(error)", level: .error)
            }
        }

    }

    func pasteFlowNodes(_ maybePoint: Point? = nil) {
        #if os(macOS)
        if let objects = NSPasteboard.general.readObjects(forClasses: [FlowPasteboardItem.self]) {
            for o in objects {
                if let data = (o as? FlowPasteboardItem?)??.flowPasteboardData {
                    self.flow.paste(pasteboardData: data, at: self.pastePosition(), undoManager: self.undoManager)
                }
            }
        }
        #endif

        #if os(iOS)
        let pb = UIPasteboard.general

        if let data = pb.data(forPasteboardType: UTType.imageFlowNode.identifier),
            let flowPasteboardData = FlowPasteboardData(data: data)
        {
            self.flow.paste(
                pasteboardData: flowPasteboardData,
                at: self.pastePosition(maybePoint),
                undoManager: self.undoManager
            )
        }
        #endif
    }

    func pastePosition(_ maybePoint: Point? = nil) -> CGPoint {
        #if os(macOS)
        if let mwp = NSApp.keyWindow?.mouseLocationOutsideOfEventStream,
            let view = self.canvasViewModel?.view,
            let viewport = self.canvasViewModel?.viewport
        {
            let mp = view.convert(mwp, from: nil)
            if view.safeAreaRect.contains(mp) {
                return viewport.convert(mp, from: .screen, to: .canvas)
            } else {
                return viewport.convert(view.bounds.center, from: .screen, to: .canvas)
            }
        } else {
            return .zero
        }
        #endif

        #if os(iOS)
        if let point = maybePoint, let view = self.canvasViewModel?.view, let viewport = self.canvasViewModel?.viewport
        {
            return point.canvas(view: view, viewport: viewport).cgPoint
        } else {
            return self.pointerData?.positionInCanvas ?? self.canvasViewModel?.view?.bounds.center ?? .zero
        }
        #endif
    }

    func exportImage(_ image: CIImage, _ filename: String?) {
        guard let vm = self.mainContentViewModel else {
            log("MainContentViewModel not found!", level: .warning)
            return
        }

        vm.showImageExporter(image, filename)
    }

    func rename(_ node: UUID) {
        self.mainContentViewModel?.renameNodeModalState.show(node)
    }

    func delete(_ target: UserAction.Target) {
        switch target {
        case .selection: self.flow.deleteSelectedNodesAction(undoManager: self.undoManager)
        case .node(let id): self.flow.deleteNodeAction(id, undoManager: self.undoManager)
        }
    }

    func duplicate(_ target: UserAction.Target) {
        switch target {
        case .selection: self.flow.duplidateSelectedNodesAction(undoManager: self.undoManager)
        case .node(let id): self.flow.duplicateNode(id, undoManager: self.undoManager)
        }
    }

    func cut(_ target: UserAction.Target) {
        switch target {
        case .selection: self.cutSelectedNodes()
        case .node(let id):
            self.copyNodes([id])
            self.flow.deleteNodeAction(id, undoManager: self.undoManager)
        }
    }

    func cutSelectedNodes() {
        guard !self.flow.selection.isEmpty else {
            log("Trying to cut an empty selection!", level: .warning)
            return
        }

        self.copySelectedNodes()
        self.flow.deleteSelectedNodesAction(undoManager: self.undoManager)
    }

    func copy(_ target: UserAction.Target) {
        switch target {
        case .selection: self.copySelectedNodes()
        case .node(let id): self.copyNodes([id])
        }
    }

    func copyNodes(_ nodes: Set<UUID>) {
        #if os(macOS)
        if let item = FlowPasteboardItem(nodes: nodes, self.flow) {
            NSPasteboard.general.clearContents()
            if !NSPasteboard.general.writeObjects([item]) {
                log("Failed to write items to pasteboard!", level: .error)
            }
        }
        #else
        let pb = UIPasteboard.general
        if let data = self.flow.pasteboardData(forNodes: nodes), let jsonData = data.jsonData {
            pb.setData(jsonData, forPasteboardType: UTType.imageFlowNode.identifier)
        }
        #endif
    }

    func copySelectedNodes() {
        self.copyNodes(self.flow.selection)
    }

    func showNodeSearch(typedPortLocation: TypedPortLocation?, canvasPosition: CGPoint?) {
        #if os(macOS)
        self.canvasViewModel?.nodeSearchPopoverPresent(typedPortLocation: typedPortLocation)
        #else
        self.mainContentViewModel?.nodePalettePresent(
            typedPortLocation: typedPortLocation,
            canvasPosition: canvasPosition
        )
        #endif
    }

    // MARK: - Previews

    public var previewIsDocked: Bool {
        self.previewState?.isDocked ?? false
    }

    public var previewHasImage: Bool {
        self.previewState?.image != nil
    }

    public var previewPositionBinding: Binding<PreviewPosition?> {
        .init(
            get: { [weak self] in
                self?.previewState?.previewPosition
            },
            set: { [weak self] newValue in
                if let newValue {
                    self?.previewState?.previewPosition = newValue
                }
            }
        )
    }

    public var previewPinnedBinding: Binding<Bool> {
        #if os(macOS)
        self.windowPreviewViewModel?.pinnedBinding ?? .constant(false)
        #else
        .constant(false)
        #endif
    }

    public func statusBar(_ text: String?) {
        if let canvas = self.canvasViewModel {
            if let text {
                canvas.statusBarShow(text)
            } else {
                canvas.statusBarHide()
            }
        }
    }
}

@MainActor
private class ActiveViewObserver {

    weak var coordinator: GlobalCoordinatorDefaultImpl?

    @ActiveViewObjectPublisher(PreviewFeatureState.self) var previewState
    @ActiveViewObjectPublisher(MainContentViewModel.self) var mainContent
    @ActiveViewObjectPublisher(CanvasFeatureViewModel.self) var canvas
    @ActiveViewObjectPublisher(DockedPreviewMenuActionCoordinator.self) var dockedPreview
    #if os(macOS)
    @ActiveViewObjectPublisher(WindowPreviewViewModel.self) var windowPreview
    #endif

    var cancellables: Set<AnyCancellable> = []

    init() {
        self.$previewState.sink { [weak self] _ in
            self?.coordinator?.previewState = self?.previewState
            self?.coordinator?.available.preview = self?.previewState != nil
        }
        .store(in: &self.cancellables)

        #if os(macOS)
        self.$windowPreview.sink { [weak self] _ in
            guard let self, let coordinator = self.coordinator else { return }
            coordinator.windowPreviewViewModel = self.windowPreview
            coordinator.available.windowPreview = self.windowPreview != nil

        }
        .store(in: &self.cancellables)
        #endif

        self.$canvas.sink { [weak self] _ in
            self?.coordinator?.canvasViewModel = self?.canvas
        }
        .store(in: &self.cancellables)

        self.$mainContent.sink { [weak self] _ in
            self?.coordinator?.mainContentViewModel = self?.mainContent
        }
        .store(in: &self.cancellables)

        self.$dockedPreview.sink { [weak self] _ in
            self?.coordinator?.dockedPreview = self?.dockedPreview
        }
        .store(in: &self.cancellables)
    }
}

extension Point {
    @MainActor
    func canvas(
        view: PlatformView,
        viewport: CanvasView.Viewport
    ) -> Point {
        switch self {
        case .canvas: self
        case .canvasView(let point): .canvasView(viewport.convert(point, from: .screen, to: .canvas))
        case .window(let point): .canvasView(view.convert(point, from: nil)).canvas(view: view, viewport: viewport)
        }
    }
}

extension FlowNode {
    @MainActor
    var estimatedViewSize: CGSize {
        NodeView(self).intrinsicContentSize
    }
}
