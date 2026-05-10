#if canImport(AppKit)

import AppKit
import SharedModels
import CardStage
import CoreImage
import Helpers
import CIImageView
import XKit

public class PreviewFeatureController: XViewController {

    // MARK: - Constants

    let toolbarHideSize: CGFloat = 120

    // MARK: - Internal Properties

    /// A reference to the `Flow` model
    let flow: Flow
    /// A reference to the `GlobalCoordinator`
    let coordinator: GlobalCoordinator
    /// A reference to the `AssetStoreServices`
    let assetStore: any AssetStoreService
    /// The Preview's state machine
    var state: PreviewStateMachine.State = .init() {
        didSet {
            if self.state != oldValue {
                logger.debug("\("\(self.state)")")
                self.updateView(oldValue)
            }
        }
    }

    // MARK: - Private Properties

    private var availablePreviewLocations: Set<PreviewLocation> = []
    private var cancellabes: Set<AnyEventEmitterCancellable> = []
    private var imageTask: Task<(), Never>?

    private lazy var dockedToolbarVM: DockedToolbarView.ViewModel = {
        .init(
            image: self.state.image,
            currentLocation: self.state.location,
            dockLocation: self.state.dockLocation ?? .bottom,
            locked: self.state.locked,
            available: self.state.availableLocations,
            zoom: 1.0,
            dispatch: { [weak self] action in self?.dockedToolbarHandler(action) }
        )
    }()

    private lazy var cardControlsVM: CardControlsView.ViewModel = {
        .init(
            isVisible: false,
            locked: self.state.locked,
            toolbarHandler: { [weak self] item in self?.cardToolbarHandler(item) }
        )
    }()

    // MARK: - Subviews

    lazy var cardStageView: CardStageView = {
        .init()
    }()

    lazy var dockedContentView: DockedContentView = {
        let view = DockedContentView(self.dockedToolbarVM)
        if let dockLocation = self.state.dockLocation {
            view.dockLocation = dockLocation
        }
        return view
    }()

    lazy var cardContentView: CardContentView = {
        let v = CardContentView(self.cardControlsVM)
        v.delegate = self
        return v
    }()

    // MARK: - Init

    public init(flow: Flow, coordinator: GlobalCoordinator, assetStore: any AssetStoreService) {
        self.flow = flow
        self.coordinator = coordinator
        self.assetStore = assetStore

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    // MARK: - View Lifecycle

    public override func loadView() {
        self.view = self.cardStageView
    }

    public override func viewDidLoad() {
        self.flow.emitter.on({ [weak self] event in
            self?.onFlowEvent(event)
        }).store(in: &self.cancellabes)

        self.assetStore.emitter.on({ [weak self] event in
            self?.onAssetStoreEvent(event)
        }).store(in: &self.cancellabes)

        self.coordinator.emitter.on({ [weak self] event in
            self?.onCoordinatorEvent(event)
        }).store(in: &self.cancellabes)

        self.cardStageView.delegate = self

        self.updateView(nil)
    }

    // MARK: - Toolbars / Controls

    func dockedToolbarHandler(_ action: DockedToolbarView.Action) {
        switch action {
        case .copy:
            self.copyImage()
        case .dockOpposite:
            if let dockLocation = self.state.dockLocation {
                if dockLocation == .bottom {
                    self.state.dockLocation = .top
                } else {
                    self.state.dockLocation = .bottom
                }
            }
        case .export:
            self.exportImage()
        case .openWindow:
            break
        case .pick(_):
            break
        case .toggleLock:
            self.input(.toggleLock)
        case .undock:
            self.state.dockLocation = nil
        case .zoomActualSize:
            break
        case .zoomIn:
            break
        case .zoomOut:
            break
        case .zoomToFit:
            break
        }
    }

    func cardToolbarHandler(_ name: CardToolbarItemName) {
        switch name {
        case .lock:
            self.input(.toggleLock)
        case .export:
            self.exportImage()
        case .copy:
            self.copyImage()
        case .dockDown:
            self.state.dockLocation = .bottom
        case .dockUp:
            self.state.dockLocation = .top
        case .window:
            break
        }
    }

    func exportImage() {
        if let image = self.state.image {
            let name = self.state.location.flatMap({ self.flow.nodes[$0.node]?.name })
            self.coordinator.perform(userAction: .exportImage(image: image, filename: name))
        }
    }

    func copyImage() {
        if let image = self.state.image {
            PasteboarImageWriter().copy(image)
        }
    }

    // MARK: - Event Handlers

    func onCoordinatorEvent(_ event: GlobalCoordinatorEvent) {
        switch event {
        case .backendDidRun:
            Task {
                await self.upadateAvailablePreviewLocations()
            }
        }
    }

    func onAssetStoreEvent(_ event: AssetStoreServiceEvent) {
        switch event {
        case .modifiedGeneratedAsset(let loc):
            self.input(.updatedImage(loc))
        case .assetsChanged:
            break
        }
    }

    func onFlowEvent(_ event: FlowEvent) {
        switch event {
        case .selectionDidChange(_, _):
            Task {
                await self.upadateAvailablePreviewLocations()
            }
        default:
            break
        }
    }

    // MARK: - State Machine

    func input(_ input: PreviewStateMachine.Input) {
        let (newState, effect) = self.state.input(input).pair

        self.state = newState

        guard let effect else { return }

        switch effect {

        case .loadImage(let loc):

            if self.imageTask != nil {
                self.imageTask?.cancel()
            }

            self.imageTask = Task { [weak self] in
                do {
                    guard let self else { return }
                    let res = try await self.assetStore.getGeneratedResource(ciImageAt: loc)
                    self.imageTask = nil
                    self.input(.imageLoaded(loc, res.res))
                } catch {
                    logger.error("\(error)")
                }
            }
        }
    }

    // MARK: - Update

    func updateView(_ oldValue: PreviewStateMachine.State?) {
        // Unlocked -> locked

        if self.state.dockLocation == nil {
            if let image = self.state.image {
                self.cardContentView.image = image
                if self.cardStageView.contentView != self.cardContentView {
                    self.cardStageView.contentView = self.cardContentView
                }
                self.cardStageView.cardVisibility = .visible
            } else {
                self.cardStageView.cardVisibility = .hidden
            }
        } else {
            self.dockedContentView.image = self.state.image
        }

        if self.state.anchor != self.cardStageView.anchor {
            self.cardStageView.anchor = self.state.anchor
        }

        if self.state.dockLocation != self.cardStageView.dockLocation {
            self.cardStageView.dockLocation = self.state.dockLocation
        }

        if self.state.dockLocation != nil && oldValue?.dockLocation == nil {
            self.cardStageView.contentView = self.dockedContentView
            self.dockedContentView.image = self.state.image
        }

        if let dockLocation = self.state.dockLocation, self.dockedContentView.dockLocation != dockLocation {
            self.dockedContentView.dockLocation = dockLocation
        }

        self.updateDockedToolbarVM()

        self.updateCardControlsVM()
    }

    func updateCardControlsVM() {
        let vm = self.cardControlsVM

        if vm.locked != self.state.locked {
            vm.locked = self.state.locked
        }
    }

    func updateDockedToolbarVM() {
        if self.state.dockLocation == nil { return }

        let vm = self.dockedToolbarVM

        if vm.image != self.state.image {
            vm.image = self.state.image
        }

        if vm.currentLocation != self.state.location {
            vm.currentLocation = self.state.location
        }

        if let loc = self.state.dockLocation, vm.dockLocation != loc {
            vm.dockLocation = loc
        }

        if vm.available != self.state.availableLocations {
            vm.available = self.state.availableLocations
        }
    }

    func upadateAvailablePreviewLocations() async {
        self.availablePreviewLocations.removeAll(keepingCapacity: true)
        for id in self.flow.selection {
            if let node = self.flow.nodes[id] {
                for output in node.outputs where output.type == .image {
                    if await self.assetStore.hasGeneratedResource(ciImageAt: .init(node: id, index: output.index)) {
                        self.availablePreviewLocations.insert(
                            .init(name: output.label, location: .init(node: id, index: output.index))
                        )
                    }
                }
            }
        }

        self.input(.previewLocations(self.availablePreviewLocations))
    }

    public override func viewDidLayout() {
        if self.cardContentView.bounds.width < self.toolbarHideSize {
            if self.cardControlsVM.isVisible {
                self.cardControlsVM.isVisible = false
                // Task {
                // self..isVisible = false
                // }
            }
        }
    }
}

// MARK: - CardStageViewDelegate

extension PreviewFeatureController: CardStageViewDelegate {
    public func cardStageAnchorDidChange(_ sender: CardStage.CardStageView) {
        self.state.anchor = sender.anchor
    }

    public func cardStageDockLocationDidChange(_ sender: CardStage.CardStageView) {
        self.state.dockLocation = sender.dockLocation
    }
}

// MARK: - CardContentView.Delegate

extension PreviewFeatureController: CardContentView.Delegate {
    func cardContentViewMouseEntered(_ view: CardContentView) {
        let vm = self.cardControlsVM

        if !vm.isVisible {
            if view.bounds.width >= self.toolbarHideSize {
                vm.isVisible = true
            }
        }
    }

    func cardContentViewMouseExited(_ view: CardContentView) {
        let vm = self.cardControlsVM

        if vm.isVisible {
            vm.isVisible = false
        }
    }
}
#endif
