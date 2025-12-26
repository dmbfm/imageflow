import CIImageView
import Controls
import CoreImage
import Foundation
import Helpers
import Logging
import SwiftUI

@Observable
@MainActor
final class PreviewFeatureState {

    let flow: any FlowService
    let assetStore: any AssetStoreService
    var scrollCache: [String: CIImageScrollView.CacheEntry] = [:]

    var cardSize: Bounded<CGFloat> = .init(50...600, 300)
    var cardAlignment: CardAlignment = .bottomTrailing
    var cardDockLocation: CardDockLocation? = nil
    var cardDockHeights: CardDockHeights = .init(up: .init(50...1000, 200), down: .init(100...1000, 300))

    #if os(macOS)
    var windows: [OutputPortLocation: PreviewWindowState] = [:]
    #endif

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
            noImage: self.image == nil,
            dockLocation: self.cardDockLocation,
        )
    }

    var isDocked: Bool {
        self.previewPosition.isDocked
    }

    var image: CIImage? {
        switch self.previewContent {
        case .image(let image, _): image
        default: nil
        }
    }

    var location: OutputPortLocation? {
        switch self.previewContent {
        case .image(_, let loc): loc
        default: nil
        }
    }

    private var sm: StateMachineStore<SM> = .init()

    @ObservationIgnored
    private var task: Task<(), Never>? = nil

    @ObservationIgnored
    private var selectedImagePorts: Set<OutputPortLocation> = []

    init(flow: some FlowService, assetStore: some AssetStoreService, cardDockLocation: CardDockLocation? = nil) {
        self.flow = flow
        self.assetStore = assetStore
        self.cardDockLocation = cardDockLocation

        Task { await self.observeSelection() }
        Task { await self.observeModifiedImages() }
    }

    func viewSizeDidChange(_ newSize: CGSize) {
        // NOTE: This is if clause a *hack* to bypass the fact the the screen changes
        // to many samll sizes during startup on macos... probably won't hurt
        // on iOS as well.
        if newSize.width > 300 && newSize.height > 300 {
            let min = max(newSize.height * 0.1, 100)
            let max = max(newSize.height * 0.85, 2 * min)
            self.cardDockHeights.down = self.cardDockHeights.down.withRange(min...max)
            self.cardDockHeights.up = self.cardDockHeights.down.withRange(min...max)
        }
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

    private func observeSelection() async {
        for await _ in Observations({ self.flow.selection }) {
            self.selectedImagePorts = self.flow.getSelectedImagePorts()
            self.sm.input(.selection(self.selectedImagePorts), onTransition: self.onStateTransition)
        }
    }

    private func observeModifiedImages() async {
        for await loc in self.assetStore.modifiedGeneratedAssetStream {
            self.sm.input(.image(loc, self.selectedImagePorts), onTransition: self.onStateTransition)
        }
    }

    private func onStateTransition(_ nextState: SM.State) {
        self.sm.state = nextState
        self.task?.cancel()
        switch self.sm.state {
        case .loading(let locked, let loc, _):
            self.task = Task { [weak self] in
                guard let self else { return }
                do {
                    let response = try await self.assetStore.getGeneratedResource(ciImageAt: loc)
                    self.task = nil
                    if !Task.isCancelled {
                        self.sm.state = .loaded(locked, loc, response.res)
                    }
                } catch {
                    log("error \(error)", level: .error)
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

// MARK: - PreviewFeatureState: CIImageScrollViewCache

extension PreviewFeatureState: @MainActor CIImageScrollViewCache {
    func get(id: String) -> CIImageScrollView.CacheEntry? {
        self.scrollCache[id]
    }

    func set(id: String, value: CIImageScrollView.CacheEntry) {
        self.scrollCache[id] = value
    }
}

// MARK: - PreviewPosition

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

// MARK: - SM - State Machine

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
                nil
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
        case .loading(let lockState, let loc, .some(let image)):
            .init(content: .image(image, loc), lock: lockState)
        case .loading(let lockState, _, .none):
            .init(content: .unavailable, lock: lockState)
        case .loaded(let lockState, let loc, let image):
            .init(content: .image(image, loc), lock: lockState)
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

// MARK: - PreviewFeatureState + openPreviewWindow

#if os(macOS)
extension PreviewFeatureState {

    enum PreviewWindowState {
        case closed(Closed)
        case open(Open)

        @MainActor
        class ScrollCache: @MainActor CIImageScrollViewCache {
            var entry: CIImageScrollView.CacheEntry?

            func get(id: String) -> CIImageScrollView.CacheEntry? {
                return self.entry
            }

            func set(id: String, value: CIImageScrollView.CacheEntry) {
                self.entry = value
            }
        }

        struct Open {
            var window: NSWindow
            var token: (any NSObjectProtocol)?
            var scrollCache: ScrollCache
        }

        struct Closed {
            var frame: CGRect
            var scrollCache: ScrollCache
        }

        var window: NSWindow? {
            switch self {
            case .open(let open): open.window
            default: nil
            }
        }

        var token: (any NSObjectProtocol)? {
            switch self {
            case .open(let open): open.token
            default: nil
            }
        }

        var frame: CGRect? {
            switch self {
            case .closed(let closed): closed.frame
            default: nil
            }
        }

    }

    func openPreviewWindow(_ loc: OutputPortLocation) {
        if let window = self.windows[loc]?.window {
            window.makeKeyAndOrderFront(nil)
        } else {
            let (frame, center, scrollCache): (CGRect, Bool, PreviewWindowState.ScrollCache) = {
                if case let .closed(closed) = self.windows[loc] {
                    (closed.frame, false, closed.scrollCache)
                } else {
                    (CGRect(origin: .zero, size: .init(width: 800, height: 600)), true, .init())
                }
            }()

            let window = NSWindow(
                contentRect: .zero,
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )

            let coordinator = PreviewWindowCoordinator()

            window.title = "Preview"
            window.level = .normal
            window.isReleasedWhenClosed = false
            window.toolbarStyle = .unified
            window.contentView = NSHostingView(
                rootView: WindowPreviewContentView(
                    location: loc,
                    assetStore: self.assetStore,
                    scrollCache: scrollCache,
                    coordinator: coordinator,
                    window: window
                )
            )

            window.makeKeyAndOrderFront(nil)
            window.setFrame(frame, display: false)

            if center {
                window.center()
            }

            var token: (any NSObjectProtocol)? = nil
            token = NotificationCenter.default.addObserver(
                forName: NSWindow.willCloseNotification,
                object: window,
                queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated {

                    coordinator.windowWillClose?()

                    if let token = self?.windows[loc]?.token {
                        NotificationCenter.default.removeObserver(token)
                    }

                    if case let .open(open) = self?.windows[loc] {
                        self?.windows[loc] = .closed(.init(frame: open.window.frame, scrollCache: open.scrollCache))
                    } else {
                        self?.windows.removeValue(forKey: loc)
                    }

                }
            }

            self.windows[loc] = .open(.init(window: window, token: token, scrollCache: scrollCache))
        }
    }
}

@MainActor
final class PreviewWindowCoordinator {
    var windowWillClose: (() -> ())?
}

#endif
