import SwiftUI
import Logging

@Observable
@MainActor
class ImagePreviewFeatureViewModel {
    let flow: Flow
    let assetStore: AssetStore

    var isLocked: Bool = false {
        didSet {
            self.onChangeOfSelection()
        }
    }

    var isVisible: Bool = true

    private var state: PreviewState = .noImage(.noSelection)

    var previewState: ImagePreviewView.PreviewState {
        switch self.state {
        case .noImage(.noSelection), .loading(_, _, .noImage(.noSelection)):
            .contentUnavailable(.init(systemImage: "photo", message: "Select a node"))
        case .noImage(.nodeHasNoImages), .loading(_, _, .noImage(.nodeHasNoImages)):
            .contentUnavailable(.init(systemImage: "photo.badge.exclamationmark", message: "Node has no images"))
        case .noImage(.nodeImagesAreEmpty), .loading(_, _, .noImage(.nodeImagesAreEmpty)):
            .contentUnavailable(.init(systemImage: "photo.badge.exclamationmark", message: "Node images are blank"))
        case .failed:
            .contentUnavailable(
                .init(systemImage: "photo.badge.exclamationmark.fill", message: "Error loading image preview")
            )
        case .loading(_, _, .reloading(let image)):
            .loaded(image)
        case .loading(_, _, .showLoading):
            .loading
        case .loaded(_, let image):
            .loaded(image)
        }
    }

    init(flow: Flow, assetStore: AssetStore) {
        self.flow = flow
        self.assetStore = assetStore

        Task {
            for await _ in Observations({ self.flow.selection }) {
                self.onChangeOfSelection()
            }
        }

        Task {
            for await loc in self.assetStore.modifiedGeneratedAssetStream {
                if self.state.currentLocation == loc {
                    self.loadImage(loc)
                } else if self.state.currentNode == loc.node {
                    if let index = self.flow.firstOutputImageIndex(loc.node) {
                        self.loadImage(.init(node: loc.node, index: index))
                    } else {
                        self.state = .noImage(.nodeHasNoImages(loc.node))
                    }
                }
            }
        }
    }

    func hide() {
        self.isVisible = false
    }

    func show() {
        self.isVisible = true
    }

    func toggleVisible() {
        self.isVisible.toggle()
    }

    func onChangeOfSelection() {
        guard !self.isLocked else { return }

        guard let nodeID = self.flow.selection.first else {
            log("No selection", level: .debug)
            self.state = .noImage(.noSelection)
            return
        }

        if nodeID == self.state.currentNode {
            log("Selected same node!", level: .debug)
            return
        }

        guard let node = self.flow.nodes[nodeID] else {
            log("Node not found", level: .debug)
            self.state = .failed(.nodeNotFound(nodeID))
            return
        }

        guard let portIndex = node.outputs.firstIndex(where: { $0.type == .image }) else {
            log("Node has no images", level: .debug)
            self.state = .noImage(.nodeHasNoImages(nodeID))
            return
        }

        self.loadImage(OutputPortLocation(node: nodeID, index: portIndex))
    }

    func loadImage(_ location: OutputPortLocation) {
        let task = Task {
            var image: CIImage?
            do {
                image = try await self.assetStore.assetManager.getGeneratedResource(ciImageAt: location).res
            } catch {
                switch error as? AssetManagerError {
                case .getGeneratedResource(.resourceNotFound):
                    self.state = .noImage(.nodeImagesAreEmpty(location))
                default:
                    self.state = .failed(.failedToLoadImage(location))
                }
            }

            if Task.isCancelled { return }

            if let image {
                self.state = .loaded(location, image)
            } else {
                self.state = .noImage(.nodeImagesAreEmpty(location))
            }
        }

        switch self.state {
        case .loaded(_, let image):
            self.state = .loading(location, task, .reloading(image))
        default:
            Task {
                try! await Task.sleep(for: .milliseconds(500))
                if case let .loading(loc, task, .noImage(_)) = self.state {
                    self.state = .loading(loc, task, .showLoading)
                }
            }
        }
    }
}

extension ImagePreviewFeatureViewModel {
    enum PreviewState {
        case noImage(NoImage)
        case loading(OutputPortLocation, Task<Void, Never>, LoadingState)
        case loaded(OutputPortLocation, CIImage)
        case failed(FailureReason)

        enum NoImage {
            case noSelection
            case nodeHasNoImages(UUID)
            case nodeImagesAreEmpty(OutputPortLocation)
        }

        enum LoadingState {
            case reloading(CIImage)
            case noImage(NoImage)
            case showLoading
        }

        enum FailureReason {
            case nodeNotFound(UUID)
            case failedToLoadImage(OutputPortLocation)
        }

        var currentNode: UUID? {
            switch self {
            case .noImage(.noSelection): nil
            case .noImage(.nodeHasNoImages(let node)): node
            case .noImage(.nodeImagesAreEmpty(let loc)): loc.node
            case .loading(let loc, _, _): loc.node
            case .loaded(let loc, _): loc.node
            case .failed(.nodeNotFound(let node)): node
            case .failed(.failedToLoadImage(let loc)): loc.node
            }
        }

        var currentLocation: OutputPortLocation? {
            switch self {
            case .noImage(.noSelection): nil
            case .noImage(.nodeHasNoImages(_)): nil
            case .noImage(.nodeImagesAreEmpty(let loc)): loc
            case .loading(let loc, _, _): loc
            case .loaded(let loc, _): loc
            case .failed(.nodeNotFound(_)): nil
            case .failed(.failedToLoadImage(let loc)): loc
            }
        }

        var task: Task<Void, Never>? {
            switch self {
            case .loading(_, let task, _): task
            default: nil
            }
        }
    }
}

extension Flow {
    func firstOutputImageIndex(_ nodeID: UUID) -> Int? {
        guard let node = self.nodes[nodeID] else { return nil }
        return node.outputs.firstIndex(where: { $0.type == .image })
    }
}

