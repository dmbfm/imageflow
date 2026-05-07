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
        let assetStore: any AssetStoreService

        var cardStageView: CardStageView!

        var state: State = .nothing {
            didSet {
                if self.state != oldValue {
                    logger.debug("\(self.state)")
                    self.update()
                }
            }
        }

        private var cancellabes: Set<AnyEventEmitterCancellable> = []

        private var availablePreviewLocations: Set<PreviewLocation> = []

        lazy var cardView: CardContentView = {
            let v = CardContentView()
            return v
        }()

        public init(flow: Flow, assetStore: any AssetStoreService) {
            self.flow = flow
            self.assetStore = assetStore

            super.init(nibName: nil, bundle: nil)
        }

        public required init?(coder: NSCoder) {
            nil
        }

        public override func loadView() {
            let view = CardStageView()
            self.cardStageView = view
            // self.cardStageView.contentView = self.cardView
            self.update()
            self.view = view
        }

        public override func viewDidLoad() {
            self.flow.emitter.on({ [weak self] event in
                self?.onFlowEvent(event)
            }).store(in: &self.cancellabes)

            self.assetStore.emitter.on({ [weak self] event in
                self?.onAssetStoreEvent(event)
            }).store(in: &self.cancellabes)
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
                self.upadateAvailablePreviewLocations()
            default:
                break
            }
        }

        func upadateAvailablePreviewLocations() {
            self.availablePreviewLocations.removeAll(keepingCapacity: true)
            for id in self.flow.selection {
                if let node = self.flow.nodes[id] {
                    for output in node.outputs where output.type == .image {
                        self.availablePreviewLocations.insert(
                            .init(name: output.label, location: .init(node: id, index: output.index))
                        )
                    }
                }
            }

            self.input(.previewLocations(self.availablePreviewLocations))
        }

        func update() {
            switch self.state {
            case .nothing:
                self.cardStageView.cardVisibility = .hidden
            case let .loaded(locked: _, location: _, image: image):
                self.cardView.image = image
                self.cardStageView.contentView = self.cardView
                self.cardStageView.cardVisibility = .visible
            default:
                self.cardStageView.cardVisibility = .visible
            }
        }

        var task: Task<(), Never>?

        func input(_ input: Input) {
            let (newState, effect) = self.state.input(input)

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
    }
}

#endif
