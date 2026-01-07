#if os(macOS)

import SwiftUI
import CIImageView
import Logging
import Helpers

class WindowPreviewController: NSWindowController, NSWindowDelegate {

    let viewModel: WindowPreviewViewModel
    let rootView: WindowPreviewContentView!
    var windowWillCloseCallback: (() -> ())?

    init(
        frame: CGRect,
        center: Bool,
        scrollCache: any CIImageScrollViewCache,
        assetStore: any AssetStoreService,
        flow: any FlowService,
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
class WindowPreviewViewModel {

    let location: OutputPortLocation
    var image: CIImage? = nil
    var name: String? = nil
    var zoom: CGFloat = 1.0
    var pinned: Bool = false { didSet { self.updateWindow() } }
    var action: CIImageScrollView.Action? = nil
    var showImageExporter: Bool = false
    var imageExporterAlertError: LocalizedAlertError? = nil

    @ObservationIgnored
    var assetStore: any AssetStoreService

    @ObservationIgnored
    var flow: any FlowService

    @ObservationIgnored
    var cache: any CIImageScrollViewCache

    @ObservationIgnored
    var cancellable: Set<AnyEventEmitterCancellable> = []

    @ObservationIgnored
    var setWindowLevel: (NSWindow.Level) -> ()

    var actionBinding: Binding<CIImageScrollView.Action?> {
        .init(
            get: { [weak self] in
                self?.action
            },
            set: { [weak self] newValue in
                self?.action = newValue
            }
        )
    }

    var pinnedBinding: Binding<Bool> {
        .init(
            get: { [weak self] in self?.pinned ?? false },
            set: { [weak self] newValue in self?.pinned = newValue }
        )
    }

    init(
        _ location: OutputPortLocation,
        _ assetStore: any AssetStoreService,
        _ flow: any FlowService,
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

// struct WindowPreviewContentView: View {

//     let location: OutputPortLocation
//     let assetStore: (any AssetStoreService)
//     let scrollCache: (any CIImageScrollViewCache)?
//     var coordinator: PreviewWindowCoordinator? = nil
//     weak var window: NSWindow? = nil

//     // TODO: Move most of the State to a view-model that is owned by a
//     // WindowController to avoid leaks causaed by the SwiftUI view hierarchy not
//     // deallocating.
//     @State var image: CIImage? = nil
//     @State var zoom: CGFloat = 1.0
//     @State var vm = WindowPreviewViewModel()
//     @State var assetObserver: AssetObserver? = nil

//     class WindowDelegate: NSObject, NSWindowDelegate {
//         var callback: (() -> ())?

//         func windowWillClose(_ notification: Notification) {
//             self.callback?()
//         }
//     }

//     @MainActor
//     class AssetObserver {
//         let assetStore: any AssetStoreService
//         var handle: EventEmitter.Handle
//         init(_ assetStore: any AssetStoreService, _ onImageChanged: @escaping (OutputPortLocation) -> ()) {
//             print("--> AssetObserver init")
//             self.assetStore = assetStore
//             self.handle = 0
//             // self.handle = assetStore.emitter.on { [weak self] event in
//             //     _ = self
//             //     switch event {
//             //     case .modifiedGeneratedAsset(let loc):
//             //         onImageChanged(loc)
//             //     }
//             // }
//         }

//         isolated deinit {
//             print("--> AssotObserver deninit")
//             self.assetStore.emitter.off(self.handle)
//         }
//     }

//     func updateWindow() {
//         if self.vm.pinned {
//             self.window?.level = .floating
//         } else {
//             self.window?.level = .normal
//         }
//     }

//     func startLoadingImage() {
//         Task {
//             await self.loadImageAsync()
//         }
//     }

//     func loadImageAsync() async {
//         do {
//             let r = try await self.assetStore.getGeneratedResource(ciImageAt: self.location)
//             self.image = r.res
//         } catch {}
//     }

//     var body: some View {
//         ZStack {
//             Colors.canvasBackground.color

//             @Bindable var vm = self.vm

//             if let image = self.image {
//                 CIImageScrollView(
//                     id: "",
//                     image: image,
//                     configuration: .init(initialViewport: .fit),
//                     action: $vm.action,
//                     cache: self.scrollCache,
//                     // zoomDidChange: { self.zoom = $0 }
//                 )
//             }
//         }
//         .onChange(of: self.window, initial: true) {
//             self.updateWindow()
//         }
//         .onChange(of: self.vm.pinned, initial: true) {
//             self.updateWindow()
//         }
//         .onChange(of: self.location, initial: true) {
//             self.startLoadingImage()
//         }
//         .onAppear {
//             self.coordinator?.windowWillClose = { @MainActor in
//                 self.vm.action = .cacheSave
//             }
//             self.assetObserver = .init(self.assetStore) { loc in
//                 if loc == self.location {
//                     self.startLoadingImage()
//                 }
//             }
//         }
//         .toolbar {
//             self.toolbarContent
//         }
//         .focusedSceneValue(self.vm)
//     }

//     @ToolbarContentBuilder
//     var toolbarContent: some ToolbarContent {
//         ToolbarItemGroup(placement: .principal) {
//             Button {
//                 self.vm.action = .zoomIn(animate: true)
//             } label: {
//                 Image(systemName: "plus.magnifyingglass")
//             }

//             Button {
//                 self.vm.action = .zoomOut(animate: true)
//             } label: {
//                 Image(systemName: "minus.magnifyingglass")
//             }

//             Text(zoomFormatter.string(for: self.zoom) ?? "")

//             Button {
//                 self.vm.action = .actualSize(animate: true)
//             } label: {
//                 Image(systemName: "1.magnifyingglass")
//             }
//             Button {
//                 self.vm.action = .zoomToFit(animate: true)
//             } label: {
//                 Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
//             }
//         }

//         ToolbarItemGroup(placement: .primaryAction) {
//             Button {
//             } label: {
//                 Image(systemName: "document.on.document")
//             }

//             Button {

//             } label: {
//                 Image(systemName: "square.and.arrow.down")
//             }
//         }

//         ToolbarSpacer(.fixed)

//         ToolbarItem(placement: .primaryAction) {
//             Button {
//                 self.vm.pinned.toggle()
//             } label: {
//                 Image(systemName: self.vm.pinned ? "pin.fill" : "pin")
//             }
//         }
//     }
// }

private let zoomFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .percent
    return f
}()

#endif
