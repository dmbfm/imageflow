#if os(macOS)

import SwiftUI
import AppKit
import SharedModels
import Helpers
import CIImageView

class WindowPreviewViewController: NSViewController {

    let location: OutputPortLocation
    let flow: Flow
    let assetStore: any AssetStoreService
    let coordinator: GlobalCoordinator
    var toolbarVM: ToolbarHostingView.VM? = nil
    var imageScrollView: CIImageScrollXView!
    var cache: WindowPreviewCache
    var restoreConfig: RestoreConfiguration? = nil
    var cancellables: Set<AnyEventEmitterCancellable> = []

    var image: CIImage? {
        get {
            self.imageScrollView.image
        }

        set {
            self.imageScrollView.image = newValue
            self.toolbarVM?.hasImage = newValue != nil
        }
    }

    var exportName: String = "image"

    var pinned: Bool = false {
        didSet {
            if self.pinned != oldValue {
                self.toolbarVM!.isPinned = self.pinned
                self.view.window?.level = self.pinned ? .floating : .normal
            }
        }
    }

    init(
        location: OutputPortLocation,
        cache: WindowPreviewCache,
        flow: Flow,
        assetStore: any AssetStoreService,
        coordinator: GlobalCoordinator
    ) {

        self.location = location
        self.flow = flow
        self.assetStore = assetStore
        self.coordinator = coordinator
        self.cache = cache

        super.init(nibName: nil, bundle: nil)

        self.toolbarVM = .init(
            zoom: 1.0,
            isPinned: self.pinned,
            hasImage: false,
            handle: { [weak self] item in self?.toolbarHandler(item) },
        )
    }

    func toolbarHandler(_ item: ToolbarHostingView.ItemName) {
        switch item {
        case .copy:
            self.doCopy()
        case .export:
            self.doExport()
        case .pin:
            self.pinned.toggle()
        case .zoomActualSize:
            self.imageScrollView.dispatch(.actualSize(animate: true))
        case .zoomIn:
            self.imageScrollView.dispatch(.zoomIn(animate: true))
        case .zoomOut:
            self.imageScrollView.dispatch(.zoomOut(animate: true))
        case .zoomToFit:
            self.imageScrollView.dispatch(.zoomToFit(animate: true))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.imageScrollView = .init(frame: .zero, configuration: .init())
        self.imageScrollView.delegate = self
        self.view = self.imageScrollView
        let host = NSHostingView(
            rootView:
                ToolbarHostingView(vm: self.toolbarVM!)
        )
        host.sceneBridgingOptions = [.toolbars]
        self.view.addSubview(host)
    }

    enum RestoreConfiguration {
        case rect(CGRect)
        case fit
    }

    override func viewDidLoad() {

        if let entry = self.cache.get() {
            self.restoreConfig = .rect(entry.viewport)
        } else {
            self.restoreConfig = .fit
        }

        self.loadImage()

        self.flow.emitter.on({ [weak self] event in
            self?.onFlowEvent(event)
        }).store(in: &self.cancellables)

        self.assetStore.emitter.on({ [weak self] event in
            self?.onAssetStoreEvent(event)
        }).store(in: &self.cancellables)

        self.exportName = self.flow.nodes[self.location.node]?.name ?? "image"
    }

    func onFlowEvent(_ event: FlowEvent) {
        switch event {
        case .didDeleteNode(let id) where id == self.location.node:
            self.view.window?.close()
        default:
            break
        }
    }

    func onAssetStoreEvent(_ event: AssetStoreServiceEvent) {
        switch event {
        case .modifiedGeneratedAsset(let location) where location == self.location:
            self.loadImage()
        default:
            break
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        NSMenu.popUpContextMenu(self.contextMenu, with: event, for: self.view)
    }

    func doCopy() {
        if let image = self.imageScrollView.image {
            PasteboarImageWriter().copy(image)
        }
    }

    func doExport() {
        if let image = self.image {
            self.toolbarVM?.imageExporterState = .init(image: image, defaultFilename: self.exportName)
        }
    }

    @objc func contextMenuCopy() {
        self.doCopy()
    }

    @objc func exportImageCommand(_: Any?) {
        self.doExport()
    }

    @objc
    func validateUserInterfaceItem(_ item: any NSValidatedUserInterfaceItem) -> Bool {
        if item.action == #selector(Self.exportImageCommand(_:)) {
            return self.image != nil
        }

        return true
    }

    var contextMenu: NSMenu {
        let menu = NSMenu()
        menu.items = [
            .init(
                title: "Copy Image to Clipboard",
                action: #selector(Self.contextMenuCopy),
                target: self,
                keyEquivalent: "c",
                systemSymbolName: .systemIconMenuCopy,
                accessibilityDescription: "Copy Image to Clipboard"
            ),
            .init(
                title: "Export Image",
                action: #selector(Self.exportImageCommand(_:)),
                target: self,
                keyEquivalent: "E",
                systemSymbolName: .systemIconSave,
                accessibilityDescription: "Export Image"
            ),
        ]
        return menu
    }

    func loadImage() {
        Task {
            await self.loadImageAsync()
        }
    }

    func loadImageAsync() async {
        do {
            self.image = try await self.assetStore.getGeneratedResource(ciImageAt: self.location)
                .res

            if let config = self.restoreConfig {
                switch config {
                case .fit:
                    self.imageScrollView.dispatch(.zoomToFit(animate: false))
                case .rect(let rect):
                    self.imageScrollView.viewport = rect
                }
                self.restoreConfig = nil
            }

        } catch {
            self.image = nil
            logger.critical("Failed to load image!")
        }
    }
}

extension WindowPreviewViewController: CIImageScrollXViewDelegate {
    func ciImageScrollViewViewportDidChange(_ view: CIImageScrollXView, _ viewport: CGRect) {
        self.cache.set(.init(viewport: viewport, windowFrame: self.view.window?.frame ?? .zero))
    }

    func ciImageScrollViewZoomDidChange(_ view: CIImageScrollXView, _ zoom: CGFloat) {
        self.toolbarVM?.zoom = zoom
        self.toolbarVM?.canZoomIn = zoom < self.imageScrollView.configuration.zoomRange.upperBound
        self.toolbarVM?.canZoomOut = zoom > self.imageScrollView.configuration.zoomRange.lowerBound
    }
}

private let zoomFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .percent
    return f
}()

#endif
