import Controls
import CoreImage
import Foundation
import Helpers
import Logging
import SwiftUI

public enum PreviewPosition: String, Equatable, CaseIterable {
    case topLeft = "Top Left"
    case bottomLeft = "Bottom Left"
    case topRight = "Top Right"
    case bottomRight = "Bottom Right"
    case bottomDock = "Bottom"
    case topDock = "Top"

    var isDocked: Bool {
        switch self {
        case .bottomDock, .topDock: true
        default: false
        }
    }
}

@Observable
@MainActor
class PreviewFeatureState<F: FlowService, A: AssetStoreService> {

    let flow: F
    let assetStore: A

    var cardSize: Bounded<CGFloat> = .init(50...600, 300)!
    var cardAlignment: CardAlignment = .bottomTrailing
    var cardDockLocation: CardDockLocation? = .down
    var cardDockHeights: CardDockHeights = .init(up: .init(50...1000, 200)!, down: .init(50...1000, 200)!)

    var isLocked: Bool {
        self.sm.output.lock
    }

    var previewContent: PreviewContent {
        self.sm.output.content
    }

    var previewContentViewModel: PreviewContentViewModel {
        .init(
            content: self.previewContent,
            isLocked: self.isLocked,
            lockButtonDisabled: self.image == nil,
            dockLocation: self.cardDockLocation
        )
    }

    var isDocked: Bool {
        self.previewPosition.isDocked
    }

    var image: CIImage? {
        switch self.previewContent {
        case .image(let image): image
        default: nil
        }
    }

    private var sm: StateMachineStore<SM> = .init()
    private var task: Task<(), Never>? = nil
    private var selectedImagePorts: Set<OutputPortLocation> = []

    init(flow: F, assetStore: A) {
        self.flow = flow
        self.assetStore = assetStore

        Task { await self.observeSelection() }
        Task { await self.observeModifiedImages() }
    }

    public func toggleLocked() {
        self.sm.input(.toggleLock) { newState in
            self.sm.state = newState

            switch newState {
            case .loaded(false, _, _), .loading(false, _, _):
                self.sm.input(.selection(self.selectedImagePorts), onTransition: self.onStateTransition(_:))
            default:
                break
            }
        }
    }

    var selCount: Int = 0
    let instanceID = UUID()
    private func observeSelection() async {
        log("observeSelection: start")
        for await _ in Observations({ self.flow.selection }) {
            log("[\(self.instanceID)] update(\(selCount)): \(self.flow.selection)")
            self.selectedImagePorts = self.flow.getSelectedImagePorts()
            log("[\(self.instanceID)] update(\(selCount)): \(self.selectedImagePorts)")
            self.sm.input(.selection(self.selectedImagePorts), onTransition: self.onStateTransition)
            selCount += 1
        }
    }

    private func observeModifiedImages() async {
        for await loc in self.assetStore.modifiedGeneratedAssetStream {
            log("modified image: \(loc)")
            self.sm.input(.image(loc, self.selectedImagePorts), onTransition: self.onStateTransition)
        }
    }

    private func onStateTransition(_ nextState: SM.State) {
        self.sm.state = nextState
        self.task?.cancel()
        switch self.sm.state {
        case .loading(let locked, let loc, _):
            self.task = Task {
                do {
                    let response = try await self.assetStore.getGeneratedResource(ciImageAt: loc)
                    self.task = nil
                    if !Task.isCancelled {
                        self.sm.state = .loaded(locked, loc, response.res)
                    }
                } catch {
                    self.task = nil
                    if !Task.isCancelled {
                        self.sm.state = .nothing
                    }
                }
            }
        default:
            break
        }
    }
}

// MARK: - PreviewFeatureState + previewPosition

extension PreviewFeatureState {
    var previewPosition: PreviewPosition {
        get {
            switch self.cardDockLocation {
            case .down: .bottomDock
            case .up: .topDock
            case .none:
                switch self.cardAlignment {
                case .topTrailing: .topRight
                case .topLeading: .topLeft
                case .bottomLeading: .bottomLeft
                case .bottomTrailing: .bottomRight
                }
            }
        }

        set {
            let anim: Animation? =
                if !self.previewPosition.isDocked && !newValue.isDocked {
                    .bouncy
                } else {
                    nil
                }

            switch newValue {
            case .bottomDock:
                self.cardDockLocation = .down
            case .topDock:
                self.cardDockLocation = .up
            case .bottomLeft:
                self.cardDockLocation = nil
                withAnimation(anim) {
                    self.cardAlignment = .bottomLeading
                }
            case .bottomRight:
                self.cardDockLocation = nil
                withAnimation(anim) {
                    self.cardAlignment = .bottomTrailing
                }
            case .topLeft:
                self.cardDockLocation = nil
                withAnimation(anim) {
                    self.cardAlignment = .topLeading
                }
            case .topRight:
                self.cardDockLocation = nil
                withAnimation(anim) {
                    self.cardAlignment = .topTrailing
                }
            }
        }
    }
}

// MARK: - SM

private struct SM: @MainActor StateMachineImpl {

    typealias LockState = Bool

    enum State: Sendable {
        case loaded(LockState, OutputPortLocation, CIImage)
        case loading(LockState, OutputPortLocation, CIImage?)
        case error(OutputPortLocation)
        case nothing
    }

    struct S {
        var isLocked: Bool = false
    }

    struct Output {
        var content: PreviewContent
        var lock: LockState = false
    }

    enum Input {
        case selection(Set<OutputPortLocation>)
        case image(OutputPortLocation, Set<OutputPortLocation>)
        case toggleLock
    }

    static var initialState: State {
        .nothing
    }

    static func step(state: State, input: Input) -> State? {
        log("step: \(state), input: \(input)")
        let commonSelection = {
            (sel: Set<OutputPortLocation>, loc: OutputPortLocation, maybeImage: CIImage?) -> State? in
            if sel.contains(loc) {
                nil
            } else if let first = sel.first {
                .loading(false, first, maybeImage)
            } else {
                .nothing
            }
        }

        let commonImage = {
            (
                lockState: LockState,
                loc: OutputPortLocation,
                curr: OutputPortLocation,
                maybeImage: CIImage?
            ) -> State? in
            if curr == loc {
                .loading(lockState, loc, maybeImage)
            } else {
                .nothing
            }
        }

        return switch input {

        case .selection(let sel):
            switch state {
            case .nothing, .error(_):
                if let first = sel.first {
                    .loading(false, first, nil)
                } else {
                    nil
                }
            case .loaded(true, _, _), .loading(true, _, _):
                nil
            case let .loaded(false, loc, image):
                commonSelection(sel, loc, image)
            case .loading(false, let loc, let maybeImage):
                commonSelection(sel, loc, maybeImage)
            }

        case .image(let loc, let sel):
            switch state {
            case .nothing, .error(_):
                if sel.contains(loc) {
                    .loading(false, loc, nil) 
                } else {
                    nil
                }
            case let .loaded(lockState, curr, image):
                commonImage(lockState, loc, curr, image)
            case let .loading(lockState, curr, maybeImage):
                commonImage(lockState, loc, curr, maybeImage)
            }

        case .toggleLock:
            switch state {
            case .nothing, .error(_):
                nil
            case let .loaded(lock, loc, image):
                .loaded(!lock, loc, image)
            case let .loading(lock, loc, image):
                .loading(!lock, loc, image)
            }
        }
    }

    static func output(state: State) -> Output {
        switch state {
        case .nothing:
            .init(content: .unavailable)
        case .error(_):
            .init(content: .unavailable)
        case .loading(let lockState, _, .some(let image)):
            .init(content: .image(image), lock: lockState)
        case .loading(let lockState, _, .none):
            .init(content: .unavailable, lock: lockState)
        case .loaded(let lockState, _, let image):
            .init(content: .image(image), lock: lockState)
        }
    }
}

extension FlowService {
    func getSelectedImagePorts() -> Set<OutputPortLocation> {
        .init(
            self.selection
                .compactMap({ self.nodes[$0] })
                .flatMap({ node in node.outputs.map({ e in (node.id, e) }) })
                .filter({ $0.1.type == .image })
                .map({ (id, e) in OutputPortLocation(node: id, index: e.id) })
        )
    }
}
