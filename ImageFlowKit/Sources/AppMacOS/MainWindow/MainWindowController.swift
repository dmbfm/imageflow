import AppKit

class MainWindowController: NSWindowController {

    static var cascadingPoint: CGPoint = CGPoint(x: 200, y: 1400)
    static var lastContentSize: CGSize? = nil

    lazy var toolbar: NSToolbar = {
        let toolbar = NSToolbar(identifier: "com.dmbfm.imageflow.macos.toolbar")
        toolbar.insertItem(withItemIdentifier: .flexibleSpace, at: 0)
        toolbar.insertItem(withItemIdentifier: .toggleSidebar, at: 1)
        toolbar.insertItem(withItemIdentifier: .sidebarTrackingSeparator, at: 2)
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        return toolbar
    }()

    init() {
        let mainVC = MainViewController()
        let window = NSWindow(contentViewController: mainVC)
        window.styleMask.insert(.fullSizeContentView)
        window.toolbarStyle = .unified
        window.titlebarAppearsTransparent = true

        if let screen = window.screen {
            let width = screen.frame.width * 0.8
            let height = screen.frame.height * 0.8
            window.setContentSize(.init(width: width, height: height))
        } else {
            window.setContentSize(.init(width: 1000, height: 700))
        }

        window.center()

        super.init(window: window)

        window.delegate = self
        window.toolbar = self.toolbar
        window.setFrameAutosaveName("com.dmbfm.imageflow.macos.main-window")
        window.makeKeyAndOrderFront(nil)

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

    override init(window: NSWindow?) {
        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func close() {
        print("close!!")
        super.close()
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

extension MainWindowController: NSToolbarDelegate {
    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .toggleSidebar:
            let item = NSToolbarItem(itemIdentifier: .toggleSidebar)
            return item
        default:
            return .init(itemIdentifier: itemIdentifier)
        }
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.toggleSidebar, .sidebarTrackingSeparator, .flexibleSpace]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.toggleSidebar, .sidebarTrackingSeparator, .flexibleSpace]
    }
}
