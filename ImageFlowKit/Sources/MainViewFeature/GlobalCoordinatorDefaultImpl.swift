import CanvasFeature
import Combine
import Helpers
import Logging
import PreviewFeature
import SharedModels
import SwiftUI
import UniformTypeIdentifiers

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

    let flow: Flow

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
        case let .didEndPortDragWithoutCreatingEdge(typedPortLocation, canvasPosition):
            self.perform(
                userAction: .showNodeSearch(typedPortLocation: typedPortLocation, canvasPosition: canvasPosition)
            )
        default:
            break
        }
    }

    public func perform(userAction action: UserAction) {
        log("user action: \(action)", level: .info)
        switch action {
        case .copySelectedNodes:
            self.copySelectedNodes()
        case .cutSelectedNodes:
            self.cutSelectedNodes()
        case .deleteSelectedNodes:
            self.flow.deleteSelectedNodesAction(undoManager: self.undoManager)
        case .duplicateSelectedNodes:
            self.flow.duplidateSelectedNodesAction(undoManager: self.undoManager)
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
        }
    }

    func perform(previewAction action: UserAction.PreviewAction) {
        switch action {
        case .zoomIn:
            if let preview = self.dockedPreview {
                preview.action = .zoomIn
            } else if let preview = self.windowPreviewViewModel {
                preview.action = .zoomIn(animate: true)
            }
        case .zoomOut:
            if let preview = self.dockedPreview {
                preview.action = .zoomOut
            } else if let preview = self.windowPreviewViewModel {
                preview.action = .zoomOut(animate: true)
            }
        case .zoomToFit:
            if let preview = self.dockedPreview {
                preview.action = .zoomToFit
            } else if let preview = self.windowPreviewViewModel {
                preview.action = .zoomToFit(animate: true)
            }
        case .actualSize:
            if let preview = self.dockedPreview {
                preview.action = .actualSize
            } else if let preview = self.windowPreviewViewModel {
                preview.action = .actualSize(animate: true)
            }
        case .openWindow:
            #if os(macOS)
            if let loc = self.previewState?.location {
                self.previewState?.openPreviewWindow(loc)
            }
            #else
            break
            #endif
        }
    }

    func exportPreviewedImage() {
        if let preview = self.windowPreviewViewModel {
            preview.exportImage()
        } else if let preview = self.previewState, let image = preview.image {
            self.exportImage(image, preview.name)
        }
    }

    func pasteFlowNodes(_ maybePosition: CGPoint? = nil) {
        #if os(macOS)
        if let objects = NSPasteboard.general.readObjects(forClasses: [FlowPasteboardItem.self]) {
            for o in objects {
                if let data = (o as? FlowPasteboardItem?)??.flowPasteboardData {
                    self.paste(data: data, at: nil)
                }
            }
        }
        #endif

        #if os(iOS)
        let pb = UIPasteboard.general

        if let data = pb.data(forPasteboardType: UTType.flowNode.identifier),
            let flowPasteboardData = FlowPasteboardData(data: data)
        {
            self.paste(data: flowPasteboardData, at: maybePosition)
        }
        #endif
    }

    func paste(data: FlowPasteboardData, at maybePos: CGPoint? = nil) {
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

    func cutSelectedNodes() {
        guard !self.flow.selection.isEmpty else {
            log("Trying to cut an empty selection!", level: .warning)
            return
        }

        self.copySelectedNodes()
        self.flow.deleteSelectedNodesAction(undoManager: self.undoManager)
    }

    func copySelectedNodes() {
        #if os(macOS)
        if let item = FlowPasteboardItem(self.flow) {
            NSPasteboard.general.clearContents()
            if !NSPasteboard.general.writeObjects([item]) {
                log("Failed to write items to pasteboard!", level: .error)
            }
        }
        #else
        let pb = UIPasteboard.general
        if let data = self.flow.pasteboardData, let jsonData = data.jsonData {
            pb.setData(jsonData, forPasteboardType: UTType.flowNode.identifier)
        }
        #endif
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
