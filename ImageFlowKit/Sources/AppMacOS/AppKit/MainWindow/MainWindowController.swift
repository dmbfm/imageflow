#if os(macOS)
import AppKit
import SharedModels
import SwiftUI
import AssetSystem
import CanvasFeature

final class MainWindowController: NSWindowController {

    static var cascadingPoint: CGPoint = CGPoint(x: 200, y: 1400)
    static var lastContentSize: CGSize? = nil

    let toolbarController: ToolbarController

    init(_ flow: Flow, _ assetStore: AssetStore, _ canvasState: CanvasFeatureState, undoManager: UndoManager? = nil) {
        let mainVC = MainViewController(flow, assetStore, canvasState)
        self.toolbarController = .init(mainVC: mainVC)
        let window = MainWindow(contentViewController: mainVC)
        window.mainWindowDelegate = mainVC
        window.styleMask.insert(.fullSizeContentView)
        window.toolbarStyle = .unified
        window.titlebarAppearsTransparent = true
        window.minSize = .init(width: 500, height: 400)

        if let screen = window.screen {
            let width = screen.frame.width * 0.8
            let height = screen.frame.height * 0.8
            window.setContentSize(.init(width: width, height: height))
        } else {
            window.setContentSize(.init(width: 1000, height: 700))
        }

        window.center()

        super.init(window: window)
        mainVC.undoService.undoManager = undoManager

        window.delegate = self
        window.toolbar = self.toolbarController.toolbar
        window.setFrameAutosaveName("com.dmbfm.imageflow.macos.main-window")
        window.makeKeyAndOrderFront(nil)
        // window.makeFirstResponder(nil)

        if NSDocumentController.shared.documents.count > 1 {
            Self.cascadingPoint = window.cascadeTopLeft(from: Self.cascadingPoint)
        } else {
            Self.cascadingPoint = window.frame.origin
        }

        if let size = Self.lastContentSize {
            window.setContentSize(size)
        }

        Self.lastContentSize = window.contentRect(forFrameRect: window.frame).size
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}

extension MainWindowController: NSWindowDelegate {
    public func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            Self.lastContentSize = window.contentRect(forFrameRect: window.frame).size
        }
    }

    public func windowDidResize(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            Self.lastContentSize = window.contentRect(forFrameRect: window.frame).size
        }
    }
}
#endif
