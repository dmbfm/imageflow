import CIImageView
import Controls
import CoreImage
import Foundation
import Helpers
import Logging
import SharedModels
import SwiftUI

extension Set where Element == PreviewContentViewModel.AvailableEntry {
    func contains(_ loc: OutputPortLocation) -> Bool {
        self.contains(where: { $0.location == loc })
    }
}

struct PreviewContentViewModel {

    var available: Set<AvailableEntry> = []

    var state: State = .nothing

    var image: CIImage? {
        self.state.image
    }

    var currentLocation: OutputPortLocation? {
        self.state.location
    }

    var currentName: String? {
        if let loc = self.currentLocation {
            self.available.first(where: { $0.location == loc })?.name
        } else {
            nil
        }
    }

    var locked: Bool {
        switch self.state {
        case .nothing: false
        case .error(let locked, _, _),
            .loading(let locked, _, _),
            .loaded(let locked, _, _):
            locked
        }
    }

    struct AvailableEntry: Hashable {
        var location: OutputPortLocation
        var name: String
    }

    enum State: Equatable {
        case nothing
        case loading(Bool, OutputPortLocation, CIImage?)
        case loaded(Bool, OutputPortLocation, CIImage)
        case error(Bool, OutputPortLocation, String)

        var image: CIImage? {
            switch self {
            case .loaded(_, _, let image): image
            case .loading(_, _, let image): image
            case .nothing, .error: nil
            }
        }

        var location: OutputPortLocation? {
            switch self {
            case .loading(_, let loc, _), .loaded(_, let loc, _), .error(_, let loc, _): loc
            case .nothing: nil
            }
        }

        var lockAndLocation: (Bool, OutputPortLocation)? {
            switch self {
            case .error(let lock, let loc, _),
                .loaded(let lock, let loc, _),
                .loading(let lock, let loc, _):
                (lock, loc)
            case .nothing: nil
            }
        }

        func mapLock(_ f: (Bool) -> Bool) -> State {
            switch self {
            case .loading(let lock, let a, let b): .loading(f(lock), a, b)
            case .loaded(let lock, let a, let b): .loaded(f(lock), a, b)
            case .error(let lock, let a, let b): .error(f(lock), a, b)
            case .nothing: .nothing
            }
        }

        func mapLocation(_ f: (OutputPortLocation) -> OutputPortLocation) -> State {
            switch self {
            case .loading(let a, let loc, let b): .loading(a, f(loc), b)
            case .loaded(let a, let loc, let b): .loaded(a, f(loc), b)
            case .error(let a, let loc, let b): .error(a, f(loc), b)
            case .nothing: .nothing
            }
        }
    }

    enum Effect: Equatable {
        case startLoading(OutputPortLocation)
    }

    enum Input {
        case sel(Set<AvailableEntry>)
        case pick(OutputPortLocation)
        case imageUpdated(OutputPortLocation)
        case imageLoaded(OutputPortLocation, CIImage)
        case imageError(OutputPortLocation, String)
        case lock
        case unlock
        case toggleLock
    }

    init?(available: Set<AvailableEntry> = [], state: State = .nothing) {
        self.available = available
        self.state = state

        switch self.state {
        case .nothing: break
        case .loaded(true, _, _), .loading(true, _, _), .error(true, _, _): break
        case .loaded(false, let loc, _), .loading(false, let loc, _), .error(false, let loc, _):
            if !self.available.contains(loc) {
                return nil
            }
        }
    }

    mutating func input(_ input: Input) -> Effect? {
        switch input {
        case .imageUpdated(let loc):
            return self.imageUpdated(loc)
        case .imageLoaded(let loc, let image):
            return self.imageLoaded(loc, image)
        case .imageError(let loc, let message):
            return self.imageError(loc, message)
        case .lock:
            return self.lock()
        case .unlock:
            return self.unlock()
        case .toggleLock:
            return self.toggleLock()
        case .pick(let loc):
            return self.pick(loc)
        case .sel(let sel):
            return self.selection(sel)
        }
    }

    mutating func imageError(_ loc: OutputPortLocation, _ message: String) -> Effect? {
        switch self.state {
        case .loading(let lock, loc, _):
            self.state = .error(lock, loc, message)
        default:
            break
        }

        return nil
    }

    mutating func imageLoaded(_ loc: OutputPortLocation, _ image: CIImage) -> Effect? {
        switch self.state {
        case .loading(let lock, loc, _):
            self.state = .loaded(lock, loc, image)
        default:
            break
        }

        return nil
    }

    mutating func imageUpdated(_ loc: OutputPortLocation) -> Effect? {
        if self.currentLocation == loc {
            self.state = .loading(self.locked, loc, self.image)
            return .startLoading(loc)
        }

        return nil
    }

    mutating func pick(_ loc: OutputPortLocation) -> Effect? {

        guard !self.locked, self.currentLocation != loc else { return nil }

        self.state = .loading(false, loc, self.image)
        return .startLoading(loc)
    }

    mutating func toggleLock() -> Effect? {
        if !self.locked {
            self.lock()
        } else {
            self.unlock()
        }
    }

    mutating func lock() -> Effect? {
        self.state = self.state.mapLock { _ in
            true
        }

        return nil
    }

    mutating func unlock() -> Effect? {

        guard self.locked else { return nil }

        if let loc = self.currentLocation {
            if !self.available.contains(loc) {
                if let first = self.available.first {
                    self.state = .loading(false, first.location, self.image)
                    return .startLoading(first.location)
                } else {
                    self.state = .nothing
                }
            }
        }

        return nil
    }

    mutating func selection(_ sel: Set<AvailableEntry>) -> Effect? {
        self.available = sel

        switch self.state.lockAndLocation {
        case .none:
            if let first = self.available.first {
                self.state = .loading(false, first.location, self.image)
                return .startLoading(first.location)
            }

        case .some((true, _)):
            break

        case .some((false, let loc)):

            if let first = self.available.first {
                if !self.available.contains(loc) {
                    self.state = .loading(false, first.location, self.image)
                    return .startLoading(first.location)
                }
            } else {
                self.state = .nothing
            }
        }

        return nil
    }
}

@Observable
@MainActor
public final class PreviewFeatureState {

    let flow: Flow
    let assetStore: any AssetStoreService
    var scrollCache: [String: CIImageScrollView.CacheEntry] = [:]

    var cardSize: Bounded<CGFloat> = .init(50...600, 300)
    var cardAlignment: CardAlignment = .bottomTrailing
    var cardDockLocation: CardDockLocation? = nil
    var cardDockHeights: CardDockHeights = .init(up: .init(50...1000, 200), down: .init(100...1000, 300))

    var showImageExporter: Bool = false
    var imageExportAlertError: LocalizedAlertError? = nil

    @ObservationIgnored
    var cachedName: (OutputPortLocation?, String?) = (nil, nil)

    #if os(macOS)
    var windows: [OutputPortLocation: PreviewWindowState] = [:]
    #endif

    var previewContentViewModel: PreviewContentViewModel = .init()!

    public var isDocked: Bool {
        self.previewPosition.isDocked
    }

    public var image: CIImage? {
        self.previewContentViewModel.image
    }

    public var location: OutputPortLocation? {
        self.previewContentViewModel.currentLocation
    }

    public var name: String? {
        if self.cachedName.0 == self.location {
            return self.cachedName.1
        } else {
            let name = self.previewContentViewModel.currentName
            self.cachedName = (self.location, name)
            return name
        }
    }

    @ObservationIgnored
    private var task: Task<(), Never>? = nil

    @ObservationIgnored
    private var cancellables: Set<AnyEventEmitterCancellable> = []

    @ObservationIgnored
    let pasteboardWriter = PasteboarImageWriter()

    init(flow: Flow, assetStore: some AssetStoreService, cardDockLocation: CardDockLocation? = nil) {
        self.flow = flow
        self.assetStore = assetStore
        self.cardDockLocation = cardDockLocation

        self.observeSelection()
        self.observeModifiedImages()
    }

    func dispatch(_ action: PreviewContentViewAction) {
        switch action {
        case .undock:
            self.cardDockLocation = nil
        case .toggleLock:
            self.toggleLocked()
        case .dockDown:
            self.cardDockLocation = .down
        case .dockUp:
            self.cardDockLocation = .up
        case .dockOpposite:
            self.cardDockLocation = self.cardDockLocation.map { if $0 == .down { .up } else { .down } }
        case .pick(let loc):
            self.previewContentViewModel(input: .pick(loc))
        case .export:
            self.showImageExporter = true
        case .copy:
            self.copy()
        case .openWindow:
            #if os(macOS)
            if let loc = self.location {
                self.openPreviewWindow(loc)
            }
            #else
            break
            #endif
        }
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

    func previewContentViewModel(input: PreviewContentViewModel.Input) {
        if let effect = self.previewContentViewModel.input(input) {
            switch effect {
            case .startLoading(let loc):
                self.task?.cancel()
                self.task = Task { [weak self] in
                    guard let self else { return }
                    do {
                        let response = try await self.assetStore.getGeneratedResource(ciImageAt: loc)
                        self.task = nil
                        if !Task.isCancelled {
                            self.previewContentViewModel(input: .imageLoaded(loc, response.res))
                        }
                    } catch {
                        log("error \(error)", level: .error)
                        self.task = nil
                        if !Task.isCancelled {
                            self.previewContentViewModel(input: .imageError(loc, "\(error)"))
                        }
                    }
                }
            }
        }
    }

    public func toggleLocked() {
        self.previewContentViewModel(input: .toggleLock)
    }

    private func observeSelection() {
        self.flow.emitter.on({ [weak self] event in
            switch event {
            case .selectionDidChange(_):
                Task { @MainActor in
                    await self?.onSelectionChanged()
                }
            default:
                break
            }
        }).store(in: &self.cancellables)
    }

    func onSelectionChanged() async {
        var avail: Set<PreviewContentViewModel.AvailableEntry> = []

        for id in self.flow.selection {
            guard let node = self.flow.nodes[id] else { continue }
            for output in node.outputs {
                let loc = OutputPortLocation(node: id, index: output.index)
                if await self.assetStore.hasGeneratedResource(ciImageAt: loc) {
                    avail.insert(.init(location: loc, name: node.name))
                }
            }
        }

        self.previewContentViewModel(input: .sel(avail))
    }

    private func observeModifiedImages() {
        self.assetStore.emitter.on { [weak self] event in
            switch event {
            case .modifiedGeneratedAsset(let loc):
                self?.previewContentViewModel(input: .imageUpdated(loc))
            }
        }.store(in: &self.cancellables)
    }

    func copy() {
        if let image = self.image {
            self.pasteboardWriter.copy(image)
        }
    }
}

// MARK: - PreviewFeatureState + previewPosition

extension PreviewFeatureState {

    public var previewPositionSafeBinding: Binding<PreviewPosition?> {
        .init(
            get: { [weak self] in
                self?.previewPosition
            },
            set: { [weak self] newValue in
                if let newValue {
                    self?.previewPosition = newValue
                }
            }
        )
    }

    public var previewPosition: PreviewPosition {
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
    public func get(id: String) -> CIImageScrollView.CacheEntry? {
        self.scrollCache[id]
    }

    public func set(id: String, value: CIImageScrollView.CacheEntry) {
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

extension Flow {
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
            var windowController: NSWindowController
            var scrollCache: ScrollCache
        }

        struct Closed {
            var frame: CGRect
            var scrollCache: ScrollCache
        }

        @MainActor
        var window: NSWindow? {
            switch self {
            case .open(let open): open.windowController.window
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

    public func openPreviewWindow(_ loc: OutputPortLocation) {
        if let window = self.windows[loc]?.window {
            window.makeKeyAndOrderFront(nil)
        } else {

            let mainWindow = NSApp.keyWindow

            let (frame, center, scrollCache): (CGRect, Bool, PreviewWindowState.ScrollCache) = {
                if case let .closed(closed) = self.windows[loc] {
                    (closed.frame, false, closed.scrollCache)
                } else {
                    (CGRect(origin: .zero, size: .init(width: 800, height: 600)), true, .init())
                }
            }()

            let windowController = WindowPreviewController(
                frame: frame,
                center: center,
                scrollCache: scrollCache,
                assetStore: self.assetStore,
                flow: self.flow,
                location: loc,
            ) { [weak self] in
                guard let self else { return }

                if case let .open(open) = self.windows[loc], let window = open.windowController.window {
                    self.windows[loc] = .closed(.init(frame: window.frame, scrollCache: open.scrollCache))
                } else {
                    self.windows.removeValue(forKey: loc)
                }
            }

            windowController.showWindow(nil)

            self.windows[loc] = .open(.init(windowController: windowController, scrollCache: scrollCache))

            if let mainWindow {
                NotificationCenter.default.addObserver(
                    forName: NSWindow.willCloseNotification,
                    object: mainWindow,
                    queue: .main,
                    using: { [weak windowController] _ in
                        MainActor.assumeIsolated {
                            windowController?.close()
                        }
                    }
                )
            }
        }
    }
}

@MainActor
final class PreviewWindowCoordinator {
    var windowWillClose: (() -> ())?
}

#endif
