#if os(macOS)

import SwiftUI
import AppKit
import SharedModels
import Helpers
import AssetSystem

// swiftlint:disable force_cast
class WindowPreviewWindowController: NSWindowController, NSWindowDelegate {

    var windowWillCloseCallback: ((WindowPreviewCache) -> ())?

    var cache: WindowPreviewCache {
        get {
            (self.contentViewController as! WindowPreviewViewController).cache
        }
        set {
            (self.contentViewController as! WindowPreviewViewController).cache = newValue
        }
    }

    init(
        frame: CGRect,
        center: Bool,
        cache: WindowPreviewCache,
        assetStore: AssetStore,
        flow: Flow,
        coordinator: GlobalCoordinator,
        location: OutputPortLocation,
        windowWillClose: ((WindowPreviewCache) -> ())? = nil
    ) {
        self.windowWillCloseCallback = windowWillClose

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
        window.contentViewController = WindowPreviewViewController(
            location: location,
            cache: cache,
            flow: flow,
            assetStore: assetStore,
            coordinator: coordinator
        )

        window.setFrame(cache.get()?.windowFrame ?? frame, display: false)

        if center && cache.get() == nil {
            window.center()
        }

        super.init(window: window)

        window.delegate = self
    }

    func windowDidResize(_ notification: Notification) {
        self.saveCache()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func saveCache() {
        let viewport =
            (self.contentViewController as! WindowPreviewViewController).imageScrollView.viewport
        self.cache.set(
            .init(viewport: viewport, windowFrame: self.window?.frame ?? .zero)
        )
    }

    func windowWillClose(_ notification: Notification) {
        self.saveCache()
        self.windowWillCloseCallback?(self.cache)
    }
}
#endif
