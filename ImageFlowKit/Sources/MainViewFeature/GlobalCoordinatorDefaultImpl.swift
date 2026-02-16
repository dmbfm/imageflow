import AssetManager
import Backend
import CanvasFeature
import CanvasView
import Combine
import ContextMenus
import Helpers
import Logging
import PreviewFeature
import SharedModels
import SwiftUI
import UniformTypeIdentifiers

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

    weak var previewState: PreviewFeatureState?
    weak var mainContentViewModel: MainContentViewModel?
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
            if travelDistance >= 50 {
                self.perform(
                    userAction: .showNodeSearch(typedPortLocation: typedPortLocation, canvasPosition: canvasPosition)
                )
            }
        case let .didDeleteNode(id):
            self.mainContentViewModel?.assetStore.remove(generatedAssetsForNode: id)
        default:
            break
        }
    }

    public func perform(userAction action: UserAction) {
        log("user action: \(action)", level: .info)
        switch action {
        case .newNode(let kind, at: let point):
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
        if let point, let view = self.canvasViewModel?.view, let viewport = self.canvasViewModel?.viewport {
            let pos = point.canvas(view: view, viewport: viewport).cgPoint
            self.flow.newNodeAction(kind: kind, at: pos, undoManager: self.undoManager)
        }
    }

    func pasteFlowNodes(_ maybePoint: Point? = nil) {
        #if os(macOS)
        if let objects = NSPasteboard.general.readObjects(forClasses: [FlowPasteboardItem.self]) {
            for o in objects {
                if let data = (o as? FlowPasteboardItem?)??.flowPasteboardData {
                    self.doPaste(data: data, at: nil)
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

    func doPaste(data: FlowPasteboardData, at maybePos: CGPoint? = nil) {
        #if os(macOS)
        if let mwp = NSApp.keyWindow?.mouseLocationOutsideOfEventStream,
            let view = self.canvasViewModel?.view,
            let viewport = self.canvasViewModel?.viewport
        {
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

    func exportImage(_ image: CIImage, _ filename: String?) {
        guard let vm = self.mainContentViewModel else {
            log("MainContentViewModel not found!", level: .warning)
            return
        }

        vm.showImageExporter(image, filename)
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
            pb.setData(jsonData, forPasteboardType: UTType.flowNode.identifier)
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
