#if os(macOS)

import SwiftUI
import CIImageView
import Logging
import Helpers
import AppKit
import SharedModels
import Design
import ImageExporter

class WindowPreviewController: NSWindowController, NSWindowDelegate {

    let viewModel: WindowPreviewViewModel
    let rootView: WindowPreviewContentView!
    var windowWillCloseCallback: (() -> ())?

    init(
        frame: CGRect,
        center: Bool,
        scrollCache: any CIImageScrollViewCache,
        assetStore: any AssetStoreService,
        flow: Flow,
        location: OutputPortLocation,
        windowWillClose: (() -> ())? = nil
    ) {
        let window = NSWindow(
            contentRect: .zero,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "Preview"
        window.level = .normal
        window.isReleasedWhenClosed = false
        window.toolbarStyle = .unified

        self.windowWillCloseCallback = windowWillClose
        self.viewModel = .init(
            location,
            assetStore,
            flow,
            scrollCache,
            { [weak window] level in window?.level = level }
        )

        self.rootView =
            WindowPreviewContentView(vm: self.viewModel)

        window.contentView = NSHostingView(
            rootView: self.rootView
        )

        window.setFrame(frame, display: false)

        if center {
            window.center()
        }

        super.init(window: window)

        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: .main) {
            [weak self] _ in
            MainActor.assumeIsolated {
                self?.windowWillCloseCallback?()
            }
        }

        // window.delegate = self
    }

    func windowWillClose(_ notification: Notification) {
        log("window will close")
        self.windowWillCloseCallback?()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    deinit {
        log("deinit", level: .debug)
    }
}

@Observable
@MainActor
public class WindowPreviewViewModel {

    let location: OutputPortLocation
    var image: CIImage? = nil
    var name: String? = nil
    var zoom: CGFloat = 1.0
    var pinned: Bool = false { didSet { self.updateWindow() } }
    public var action: CIImageScrollView.Action? = nil
    var showImageExporter: Bool = false
    var imageExporterAlertError: LocalizedAlertError? = nil

    @ObservationIgnored
    var assetStore: any AssetStoreService

    @ObservationIgnored
    var flow: Flow

    @ObservationIgnored
    var cache: any CIImageScrollViewCache

    @ObservationIgnored
    var cancellable: Set<AnyEventEmitterCancellable> = []

    @ObservationIgnored
    var setWindowLevel: (NSWindow.Level) -> ()

    public var actionBinding: Binding<CIImageScrollView.Action?> {
        .init(
            get: { [weak self] in
                self?.action
            },
            set: { [weak self] newValue in
                self?.action = newValue
            }
        )
    }

    public var pinnedBinding: Binding<Bool> {
        .init(
            get: { [weak self] in self?.pinned ?? false },
            set: { [weak self] newValue in self?.pinned = newValue }
        )
    }

    public init(
        _ location: OutputPortLocation,
        _ assetStore: any AssetStoreService,
        _ flow: Flow,
        _ cache: any CIImageScrollViewCache,
        _ setWindowLevel: @escaping (NSWindow.Level) -> (),
    ) {
        self.setWindowLevel = setWindowLevel
        self.location = location
        self.assetStore = assetStore
        self.flow = flow
        self.cache = cache
        self.name = flow.nodes[location.node]?.name

        assetStore.emitter.on { [weak self] event in
            // guard let self else { return }
            switch event {
            case .modifiedGeneratedAsset(let loc):
                if loc == self?.location {
                    self?.startLoadingImage()
                }
            }
        }.store(in: &self.cancellable)

        self.updateWindow()
        self.startLoadingImage()
    }

    deinit {
        log("deinit", level: .debug)
    }

    func updateWindow() {
        self.setWindowLevel(self.pinned ? .floating : .normal)
    }

    func startLoadingImage() {
        Task {
            await self.loadImageAsync()
        }
    }

    func loadImageAsync() async {
        do {
            let r = try await self.assetStore.getGeneratedResource(ciImageAt: self.location)
            self.image = r.res
        } catch {}
    }

    @ObservationIgnored
    let pasteboardWriter = PasteboarImageWriter()

    func copy() {
        if let image = self.image {
            self.pasteboardWriter.copy(image)
        }
    }
}

struct WindowPreviewContentView: View {
    let vm: WindowPreviewViewModel

    var body: some View {

        @Bindable var vm = self.vm

        ZStack {
            Colors.canvasBackground.color

            if let image = self.vm.image {
                CIImageScrollView(
                    id: "",
                    image: image,
                    configuration: .init(initialViewport: .fit),
                    action: self.vm.actionBinding,
                    cache: self.vm.cache,
                    zoomDidChange: { [weak vm = self.vm] in vm?.zoom = $0 }
                )
            }
        }
        .focusedSceneValue(self.vm)
        .toolbar { self.toolbarContent }
        .imageExporter(
            isPresented: $vm.showImageExporter,
            image: self.vm.image,
            defaultFilename: self.vm.name,
            errorMessage: $vm.imageExporterAlertError
        )
        .errorAlert($vm.imageExporterAlertError)
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .principal) {
            Button {
                self.vm.action = .zoomIn(animate: true)
            } label: {
                Image(systemName: "plus.magnifyingglass")
            }

            Button {
                self.vm.action = .zoomOut(animate: true)
            } label: {
                Image(systemName: "minus.magnifyingglass")
            }

            Text(zoomFormatter.string(for: self.vm.zoom) ?? "")

            Button {
                self.vm.action = .actualSize(animate: true)
            } label: {
                Image(systemName: "1.magnifyingglass")
            }
            Button {
                self.vm.action = .zoomToFit(animate: true)
            } label: {
                Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
            }
        }

        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                self.vm.copy()
            } label: {
                Image(systemName: "document.on.document")
            }

            Button {
                self.vm.showImageExporter = true
            } label: {
                Image(systemName: "square.and.arrow.down")
            }
        }

        ToolbarSpacer(.fixed)

        ToolbarItem(placement: .primaryAction) {
            Button {
                self.vm.pinned.toggle()
            } label: {
                Image(systemName: self.vm.pinned ? "pin.fill" : "pin")
            }
        }
    }
}

private let zoomFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .percent
    return f
}()

#endif
