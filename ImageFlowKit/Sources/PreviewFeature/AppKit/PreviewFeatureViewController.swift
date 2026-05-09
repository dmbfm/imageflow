#if canImport(AppKit)

import AppKit
import SharedModels
import CardStage
import CoreImage
import Helpers
import CIImageView
import XKit

extension PreviewFeature {

    public final class Controller: NSViewController {

        let flow: Flow
        let coordinator: GlobalCoordinator
        let assetStore: any AssetStoreService

        var state: State = .init() {
            didSet {
                if self.state != oldValue {
                    logger.debug("\("\(self.state)")")
                    self.updateView(oldValue)
                }
            }
        }

        private var cancellabes: Set<AnyEventEmitterCancellable> = []

        private var availablePreviewLocations: Set<PreviewLocation> = []

        var cardStageView: CardStageView = .init()

        lazy var cardContentView: CardContentView = {
            let v = CardContentView()
            return v
        }()

        public init(flow: Flow, coordinator: GlobalCoordinator, assetStore: any AssetStoreService) {
            self.flow = flow
            self.coordinator = coordinator
            self.assetStore = assetStore

            super.init(nibName: nil, bundle: nil)
        }

        public required init?(coder: NSCoder) {
            nil
        }

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

            self.cardContentView.toolbarButtonHandler = { [weak self] name in
                self?.onToolbarButtonClick(name)
            }

            self.updateView(nil)
        }

        func onToolbarButtonClick(_ name: CardToolbarItemName) {
            switch name {
            case .lock:
                self.input(.toggleLock)
            case .export:
                if let image = self.state.image {
                    let name = self.state.location.flatMap({ self.flow.nodes[$0.node]?.name })
                    self.coordinator.perform(userAction: .exportImage(image: image, filename: name))
                }
                break
            case .dockDown:
                break
            case .dockUp:
                break
            case .window:
                break
            }
        }

        func onCoordinatorEvent(_ event: GlobalCoordinatorEvent) {
            switch event {
            case .backendDidRun:
                Task { await self.upadateAvailablePreviewLocations() }
                break
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

        var task: Task<(), Never>?

        func input(_ input: Input) {
            let (newState, effect) = self.state.input(input).pair

            self.state = newState

            guard let effect else { return }

            switch effect {

            case .loadImage(let loc):

                if self.task != nil {
                    self.task?.cancel()
                }

                self.task = Task { [weak self] in
                    do {
                        guard let self else { return }
                        let res = try await self.assetStore.getGeneratedResource(ciImageAt: loc)
                        self.task = nil
                        self.input(.imageLoaded(loc, res.res))
                    } catch {
                        logger.error("\(error)")
                    }
                }
            }
        }

        func updateView(_ oldValue: State?) {
            if self.state.locked != oldValue?.locked {
                self.cardContentView.cardControlsViewModel.locked = self.state.locked
            }

            if let image = self.state.image {
                self.cardContentView.image = image
                if self.cardStageView.contentView != self.cardContentView {
                    self.cardStageView.contentView = self.cardContentView
                }
                self.cardStageView.cardVisibility = .visible
            } else {
                self.cardStageView.cardVisibility = .hidden
            }
        }
    }
}

#endif
