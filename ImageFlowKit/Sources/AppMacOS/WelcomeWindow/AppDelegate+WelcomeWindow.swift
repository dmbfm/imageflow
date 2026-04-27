import AppKit
import Helpers
import SwiftUI

extension AppDelegate {

    func closeWelcomeWindow() {
        if let wc = self.welcomeWindowController {
            wc.close()
        }
    }

    func openWelcomeWindow() {
        let window = NSWindow(
            contentRect: .init(x: 0, y: 0, width: 740, height: 460),
            styleMask: [
                .titled,
                .closable,
                .fullSizeContentView,
            ],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true

        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.isOpaque = false
        window.backgroundColor = .clear
        let toolbar = NSToolbar()
        toolbar.displayMode = .iconOnly
        toolbar.allowsDisplayModeCustomization = false
        window.toolbar = toolbar
        window.titleVisibility = .hidden

        window.centerScreen()

        var recentDocuments: [RecentDocumentItem] = [
            .init(name: "Some Document", path: "/Users/dfortes/some_document.imageflow")
        ]
        for url in NSDocumentController.shared.recentDocumentURLs {
            if !FileManager.default.fileExists(atPath: url.path()) {
                continue
            }
            let name = url.deletingPathExtension().lastPathComponent
            let path = url.deletingLastPathComponent().path().trimmingSuffix("/")
            recentDocuments.append(.init(url: url, name: name, path: path))
        }

        let view = ZStack {
            Color.clear.ignoresSafeArea()
            WelcomeWindowView(recentDocuments: recentDocuments)
                .ignoresSafeArea()
        }
        .frame(width: 740, height: 460 - 66)
        window.contentView = NSHostingView(rootView: view)

        let wc = WelcomeWindowController(window: window)
        wc.showWindow(nil)

        self.welcomeWindowController = wc
    }
}

extension NSWindow {
    func centerScreen() {
        guard let screen = self.screen else {
            self.center()
            return
        }

        let sh = screen.frame.height
        let sw = screen.frame.width
        let wh = self.frame.height
        let ww = self.frame.width
        let y = sh * 0.5 - wh * 0.5
        let x = sw * 0.5 - ww * 0.5
        self.setFrameOrigin(.init(x: x, y: y))
    }
}
