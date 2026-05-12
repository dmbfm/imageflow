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

    /// If the floating preview is smaller than this value, hide the card's toolbar.
    let toolbarHideSize: CGFloat = 120
    /// The height of the docked preview's toolbar.
    let dockedToolbarHeight: CGFloat = 28

    /// The maximum size of the floating preview square, in units of fraction of the main view's height.
    /// TODO: Add to settings.
    let floatingPreviewMaxSize: CGFloat? = 0.8

    /// The maximum height of the docked preview panel, in units of fraction of the main view's height.
    /// TODO: Add to settings.
    let dockedPreviewMaxHeight: CGFloat? = 0.8

    // MARK: - Internal Properties

    /// A reference to the `Flow` model
    public let flow: Flow
    /// A reference to the `GlobalCoordinator`
    public let coordinator: GlobalCoordinator
    /// A reference to the `AssetStoreServices`
    public let assetStore: any AssetStoreService

    // MARK: - Private Properties

    /// The Preview's state machine
    private var state: PreviewStateMachine.State = .init() {
        didSet {
            if self.state != oldValue {
                self.updateView(oldValue)
            }
        }
    }

    private var imageScrollViewportCache: SimpleCache<ViewportCacheKey, CGRect> = .init()
    private var cancellabes: Set<AnyEventEmitterCancellable> = []
    private var imageTask: Task<(), Never>?
    private var viewport: CGRect = .zero

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
            toolbarHandler: { [weak self] item in self?.cardToolbarHandler(item) },
            available: self.state.availableLocations,
            currentLocation: self.state.location,
            didSetCurrentLocation: { [weak self] loc in
                guard let self else { return }

                if let loc, self.state.location != loc {
                    self.input(.pick(loc))
                }
            }
        )
    }()

    // MARK: - Subviews

    let cardStageView: CardStageView = .init()

    lazy var dockedContentView: DockedContentView = {
        let view = DockedContentView(self.dockedToolbarVM)
        if let dockLocation = self.state.dockLocation {
            view.dockLocation = dockLocation
        }
        view.imageScrollView.delegate = self
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
        self.dockedContentView.delegate = self

        self.dockedToolbarVM.zoom = self.dockedContentView.zoom

        self.updateView(nil)
    }

    public override func viewWillLayout() {
        let viewSize = self.view.bounds.size

        if let ratio = self.floatingPreviewMaxSize {
            self.cardStageView.configuration = self.cardStageView
                .configuration.with(
                    \.cardSizeRange,
                    self.cardStageView.configuration.cardSizeRange.withUpperBound(ratio * viewSize.height)
                )
        }

        if let ratio = self.dockedPreviewMaxHeight {
            self.cardStageView.configuration = self.cardStageView
                .configuration.with(
                    \.dockedHeightRange,
                    self.cardStageView.configuration.dockedHeightRange.withUpperBound(ratio * viewSize.height)
                )
        }

    }

    public override func viewDidLayout() {
        if self.cardContentView.bounds.width < self.toolbarHideSize {
            if self.cardControlsVM.isVisible {
                self.cardControlsVM.isVisible = false
            }
        }
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
        case .pick(let location):
            self.input(.pick(location))
        case .toggleLock:
            self.input(.toggleLock)
        case .undock:
            self.state.dockLocation = nil
        case .zoomActualSize:
            self.dockedContentView.imageScrollView.dispatch(.actualSize(animate: true))
        case .zoomIn:
            self.dockedContentView.imageScrollView.dispatch(.zoomIn(animate: true))
        case .zoomOut:
            self.dockedContentView.imageScrollView.dispatch(.zoomOut(animate: true))
        case .zoomToFit:
            self.dockedContentView.imageScrollView.dispatch(.zoomToFit(animate: true))
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

        self.updateViewportCache(oldValue)

        self.updateDockedView(oldValue)
        self.updateCardView()
        self.updateDockedToolbarVM()
        self.updateCardControlsVM(oldValue)
    }

    func updateViewportCache(_ oldValue: PreviewStateMachine.State?) {
        guard let oldValue else { return }

        if self.state.isDocked && oldValue.isDocked {
            if let location = oldValue.location, location != self.state.location {
                let key = ViewportCacheKey(location: location, size: .zero)
                self.imageScrollViewportCache.set(key, self.viewport)
            }
        } else if oldValue.isDocked && self.state.isFloating {
            if let location = oldValue.location {
                let key = ViewportCacheKey(location: location, size: .zero)
                self.imageScrollViewportCache.set(key, self.viewport)
            }
        }
    }

    func updateCardView() {
        if !self.state.isDocked {
            if let image = self.state.image {
                if self.cardContentView.image != image {
                    self.cardContentView.image = image
                }

                if self.cardStageView.contentView != self.cardContentView {
                    self.cardStageView.contentView = self.cardContentView
                }

                if self.cardStageView.cardVisibility == .hidden {
                    self.cardStageView.cardVisibility = .visible
                }
            } else if self.cardStageView.cardVisibility != .hidden {
                self.cardStageView.cardVisibility = .hidden
            }
        }

        updateProp(source: self.state, \.anchor, dest: self.cardStageView, \.anchor)
        updateProp(source: self.state, \.dockLocation, dest: self.cardStageView, \.dockLocation)
    }

    func updateDockedView(_ oldValue: PreviewStateMachine.State?) {

        enum RestoreCacheFallback {
            case zoomToFit
            case zoomToFitSize(CGSize)
        }

        var restoreCache: RestoreCacheFallback? = nil

        if self.state.isDocked && self.cardStageView.contentView != self.dockedContentView {
            // self.cardStageView.contentView = self.dockedContentView
        }

        if self.state.isDocked && oldValue?.isDocked != true {
            restoreCache = .zoomToFitSize(
                .init(
                    width: self.cardStageView.bounds.width,
                    height: self.cardStageView.dockedHeight - self.dockedToolbarHeight
                )
            )
        }

        if self.state.image != self.dockedContentView.image {
            self.imageScrollViewportCache.whileLocked {
                self.dockedContentView.image = self.state.image
                restoreCache = .zoomToFit
            }
        }

        if let restoreCache {
            if let key = self.state.viewportCacheKey, let cached = self.imageScrollViewportCache.get(key) {
                self.dockedContentView.imageScrollView.viewport = cached
            } else {
                // Task {
                switch restoreCache {
                case .zoomToFit:
                    self.dockedContentView.imageScrollView.dispatch(.zoomToFit(animate: false))
                case .zoomToFitSize(let size):
                    self.dockedContentView.imageScrollView.dispatch(
                        .zoomToFitSize(size, animate: false)
                    )
                }
            }
        }

        updateProp(source: self.state, \.dockLocation, dest: self.dockedContentView, \.dockLocation)
    }

    func updateCardControlsVM(_ oldValue: PreviewStateMachine.State?) {
        let vm = self.cardControlsVM

        updateProp(source: self.state, \.locked, dest: vm, \.locked)
        updateProp(source: self.state, \.availableLocations, dest: vm, \.available)
        updateProp(source: self.state, \.location, dest: vm, \.currentLocation)

        if self.state.isFloating && oldValue?.isDocked == true {
            vm.isVisible = false
        }
    }

    func updateDockedToolbarVM() {
        if self.state.dockLocation == nil { return }

        let vm = self.dockedToolbarVM

        updateProp(source: self.state, \.image, dest: vm, \.image)
        updateProp(source: self.state, \.location, dest: vm, \.currentLocation)
        updateProp(source: self.state, \.availableLocations, dest: vm, \.available)
        updateProp(source: self.state, \.dockLocation, dest: vm, \.dockLocation)
    }

    func upadateAvailablePreviewLocations() async {
        var available: Set<PreviewLocation> = []

        for id in self.flow.selection {
            if let node = self.flow.nodes[id] {
                for output in node.outputs where output.type == .image {
                    if await self.assetStore.hasGeneratedResource(ciImageAt: .init(node: id, index: output.index)) {
                        available.insert(
                            .init(
                                name: "\(node.name) (\(output.label))",
                                location: .init(node: id, index: output.index)
                            )
                        )
                    }
                }
            }
        }

        self.input(.previewLocations(available))
    }
}

// MARK: - CardStageViewDelegate

extension PreviewFeatureController: CardStageViewDelegate {
    public func cardStageDidStartResizingCard(_ sender: CardStage.CardStageView, locationInWindow: CGPoint) {
        // self.cardControlsVM.isVisible = false
    }

    public func cardStageDidFinnishResizingCard(_ sender: CardStage.CardStageView, locationInWindow: CGPoint) {
        let loc = self.cardContentView.convert(locationInWindow, from: nil)
        self.cardControlsVM.isVisible = self.cardContentView.bounds.contains(loc)
    }

    public func cardStageDidStartDocking(_ sender: CardStage.CardStageView) {
        logger.debug("cardStageDidStartDocking")
    }

    public func cardStageDidFinnishDocking(_ sender: CardStage.CardStageView) {
        logger.debug("cardStageDidFinnishDocking")
        self.cardStageView.contentView = self.dockedContentView
    }

    public func cardStageDidStartUndocking(_ sender: CardStage.CardStageView) {
        logger.debug("cardStageDidStartUndocking")
        self.cardStageView.contentView = self.cardContentView
    }

    public func cardStageDidFinnishUndocking(_ sender: CardStage.CardStageView) {
        logger.debug("cardStageDidFinnishUndocking")
    }

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

// MARK: - DockedContentView.Delegate

extension PreviewFeatureController: DockedContentView.Delegate {
    func dockedContentViewZoomDidChange(_ view: DockedContentView, _ zoom: CGFloat) {
        self.dockedToolbarVM.zoom = zoom
    }
}

// MARK: - CIImageScrollXViewDelegate

extension PreviewFeatureController: CIImageScrollXViewDelegate {
    public func ciImageScrollViewViewportDidChange(_ view: CIImageScrollXView, _ viewport: CGRect) {
        self.viewport = viewport
        // if let key = self.state.viewportCacheKey {
        //     self.imageScrollViewportCache.set(key, viewport)
        // }
    }

    public func ciImageScrollViewZoomDidChange(_ view: CIImageScrollXView, _ zoom: CGFloat) {
        self.dockedToolbarVM.zoom = zoom
    }
}
#endif
