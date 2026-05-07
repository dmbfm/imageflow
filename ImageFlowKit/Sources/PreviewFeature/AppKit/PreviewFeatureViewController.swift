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
                    self.update()
                }
            }
        }

        private var cancellabes: Set<AnyEventEmitterCancellable> = []

        private var availablePreviewLocations: Set<PreviewLocation> = []

        lazy var cardView: CardContentView = {
            let v = CardContentView()
            v.backgroundColor = .init(white: 0.5, alpha: 1.1)
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

public struct PreviewFeature {}

extension PreviewFeature {

    struct PreviewLocation: Hashable {
        var name: String
        var location: OutputPortLocation
    }

    enum Input {
        case updatedImage(OutputPortLocation)
        case previewLocations(Set<PreviewLocation>)
        case imageLoaded(OutputPortLocation, CIImage)
    }

    enum Effect {
        case loadImage(OutputPortLocation)
    }

    enum State: Equatable, With {
        case nothing
        case loading(locked: Bool, location: OutputPortLocation, image: CIImage?)
        case loaded(locked: Bool, location: OutputPortLocation, image: CIImage)
        case error(locked: Bool, location: OutputPortLocation, message: String)

        var image: CIImage? {
            switch self {
            case .loaded(_, _, let image): image
            case .loading(_, _, let image): image
            default: nil
            }
        }

        var location: OutputPortLocation? {
            get {
                switch self {
                case .loading(_, let location, _),
                    .loaded(_, let location, _),
                    .error(_, let location, _):
                    location
                default:
                    nil
                }
            }
            set {
                guard let newValue else { return }
                switch self {
                case .nothing: break
                case .error(let a, _, let c): self = .error(locked: a, location: newValue, message: c)
                case .loaded(let a, _, let c): self = .loaded(locked: a, location: newValue, image: c)
                case .loading(let a, _, let c): self = .loading(locked: a, location: newValue, image: c)
                }
            }
        }

        var locked: Bool {
            get {
                switch self {
                case .nothing: false
                case .error(let locked, _, _), .loading(let locked, _, _), .loaded(let locked, _, _): locked
                }
            }

            set {
                switch self {
                case .nothing: break
                case .error(_, let b, let c): self = .error(locked: newValue, location: b, message: c)
                case .loading(_, let b, let c): self = .loading(locked: locked, location: b, image: c)
                case .loaded(_, let b, let c): self = .loaded(locked: locked, location: b, image: c)
                }
            }
        }

        func input(_ input: Input) -> (State, Effect?) {
            switch input {

            case .previewLocations([]):
                if !self.locked {
                    return (.nothing, nil)
                } else {
                    return (self, nil)
                }

            case .previewLocations(let locs):
                switch self {

                case .nothing, .error:
                    let loc = locs.first!.location
                    return (
                        .loading(locked: false, location: loc, image: nil), .loadImage(loc)
                    )

                case let .loading(locked, location, image):
                    if locs.contains(where: { $0.location == location }) || locked {
                        return (self, nil)
                    } else {
                        let loc = locs.first!.location
                        return (.loading(locked: locked, location: loc, image: image), .loadImage(loc))
                    }

                case let .loaded(locked, location, image):
                    if locs.contains(where: { $0.location == location }) || locked {
                        return (self, nil)
                    } else {
                        let loc = locs.first!.location
                        return (.loading(locked: locked, location: loc, image: image), .loadImage(loc))
                    }
                }

            case let .imageLoaded(loc, image):
                return (.loaded(locked: self.locked, location: loc, image: image), nil)

            case .updatedImage(let location):
                guard let current = self.location, current == location else { return (self, nil) }

                return (.loading(locked: self.locked, location: location, image: self.image), .loadImage(location))
            }
        }
    }

}
#endif
