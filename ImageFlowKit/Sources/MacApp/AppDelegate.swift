import AppKit
import Logging

class AppDelegate: NSObject, NSApplicationDelegate {

    var openRecentMenu: NSMenu!
    var targets: [OpenRecentDocumentMenuItemTarget] = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // self.buildMainMenu()
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        self.openRecentMenu.removeAllItems()
        self.targets.removeAll()

        for url in NSDocumentController.shared.recentDocumentURLs {
            let target = OpenRecentDocumentMenuItemTarget(url: url)
            self.targets.append(target)
            let item = NSMenuItem(
                title: url.lastPathComponent,
                action: #selector(OpenRecentDocumentMenuItemTarget.open(_:)),
                keyEquivalent: ""
            )
            item.target = target
            item.image = NSWorkspace.shared.icon(for: .init("com.dmbfm.imageflowdoc")!)
            item.image?.size = .init(width: 14, height: 16)
            self.openRecentMenu.addItem(item)
        }

        if self.openRecentMenu.items.count > 0 {
            self.openRecentMenu.addItem(.separator())
        }
        self.openRecentMenu.addItem(
            .init(
                title: "Clear Menu",
                action: #selector(NSDocumentController.clearRecentDocuments(_:)),
                keyEquivalent: ""
            )
        )
    }
}

@MainActor
class OpenRecentDocumentMenuItemTarget {
    init(url: URL? = nil) {
        self.url = url
    }

    var url: URL?

    @objc func open(_ sender: Any?) {
        if let url = self.url {
            NSDocumentController.shared.openDocument(withContentsOf: url, display: true) { _, _, err in
                if let err {
                    NSApp.presentError(err)
                }
            }
        }
    }
}

extension AppDelegate {

    @objc private func openPreferences(_ sender: Any?) {
        // show your Preferences window here
    }

    @MainActor
    private func buildMainMenu() {
        let app = NSApplication.shared
        let appName = ProcessInfo.processInfo.processName

        // MARK: – Main menu
        let mainMenu = NSMenu()
        app.mainMenu = mainMenu

        // MARK: • Application
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu(title: appName)
        appMenuItem.submenu = appMenu

        appMenu.addItem(
            withTitle: "About \(appName)",
            action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
            keyEquivalent: ""
        )

        let prefs = NSMenuItem(
            title: "Preferences…",
            action: #selector(openPreferences(_:)),
            keyEquivalent: ","
        )
        prefs.target = self
        appMenu.addItem(prefs)

        appMenu.addItem(.separator())

        let servicesItem = NSMenuItem(title: "Services", action: nil, keyEquivalent: "")
        let servicesMenu = NSMenu(title: "Services")
        servicesItem.submenu = servicesMenu
        NSApp.servicesMenu = servicesMenu
        appMenu.addItem(servicesItem)

        appMenu.addItem(.separator())

        appMenu.addItem(
            withTitle: "Hide \(appName)",
            action: #selector(NSApplication.hide(_:)),
            keyEquivalent: "h"
        )
        let hideOthers = NSMenuItem(
            title: "Hide Others",
            action: #selector(NSApplication.hideOtherApplications(_:)),
            keyEquivalent: "h"
        )
        hideOthers.keyEquivalentModifierMask = [.command, .option]
        appMenu.addItem(hideOthers)
        appMenu.addItem(
            withTitle: "Show All",
            action: #selector(NSApplication.unhideAllApplications(_:)),
            keyEquivalent: ""
        )

        appMenu.addItem(.separator())
        appMenu.addItem(
            withTitle: "Quit \(appName)",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )

        // MARK: • File
        let fileMenuItem = NSMenuItem()
        mainMenu.addItem(fileMenuItem)
        let fileMenu = NSMenu(title: "File")
        fileMenuItem.submenu = fileMenu
        fileMenu.delegate = self

        fileMenu.addItem(withTitle: "New", action: #selector(NSDocumentController.newDocument(_:)), keyEquivalent: "n")
        fileMenu.addItem(
            withTitle: "Open…",
            action: #selector(NSDocumentController.openDocument(_:)),
            keyEquivalent: "o"
        )

        // Open Recent
        fileMenu.addItem(.separator())
        let openRecentItem = NSMenuItem(title: "Open Recent", action: nil, keyEquivalent: "")
        self.openRecentMenu = NSMenu(title: "Open Recent")
        // self.openRecentMenu.delegate = self
        openRecentItem.submenu = self.openRecentMenu
        // NSDocumentController.shared.recentDocumentMenu = openRecentMenu
        fileMenu.addItem(openRecentItem)

        fileMenu.addItem(.separator())
        fileMenu.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        fileMenu.addItem(.separator())
        fileMenu.addItem(
            withTitle: "Save",
            action: #selector(NSDocument.save(_:)),
            keyEquivalent: "s"
        )
        fileMenu.addItem(
            withTitle: "Save As…",
            action: #selector(NSDocument.saveAs(_:)),
            keyEquivalent: "S"
        )
        fileMenu.addItem(
            withTitle: "Revert To Saved",
            action: #selector(NSDocument.revertToSaved(_:)),
            keyEquivalent: ""
        )

        // MARK: • Edit
        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)
        let editMenu = NSMenu(title: "Edit")
        editMenuItem.submenu = editMenu

        editMenu.addItem(withTitle: "Undo", action: #selector(UndoManager.undo), keyEquivalent: "z")
        editMenu.addItem(withTitle: "Redo", action: #selector(UndoManager.redo), keyEquivalent: "Z")
        editMenu.addItem(.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Delete", action: #selector(NSText.delete(_:)), keyEquivalent: "")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        // MARK: • View
        let viewMenuItem = NSMenuItem()
        mainMenu.addItem(viewMenuItem)
        let viewMenu = NSMenu(title: "View")
        viewMenuItem.submenu = viewMenu

        viewMenu.addItem(
            withTitle: "Show Tab Bar",
            action: #selector(NSWindow.toggleTabBar(_:)),
            keyEquivalent: "t"
        )
        viewMenu.addItem(
            withTitle: "Show Toolbar",
            action: #selector(NSWindow.toggleToolbarShown(_:)),
            keyEquivalent: ""
        )
        viewMenu.addItem(
            withTitle: "Customize Toolbar…",
            action: #selector(NSWindow.runToolbarCustomizationPalette(_:)),
            keyEquivalent: ""
        )
        viewMenu.addItem(.separator())
        let fullScreen = viewMenu.addItem(
            withTitle: "Enter Full Screen",
            action: #selector(NSWindow.toggleFullScreen(_:)),
            keyEquivalent: "f"
        )
        fullScreen.keyEquivalentModifierMask = [.control, .command]

        // MARK: • Window
        let windowMenuItem = NSMenuItem()
        mainMenu.addItem(windowMenuItem)
        let windowMenu = NSMenu(title: "Window")
        windowMenuItem.submenu = windowMenu
        NSApp.windowsMenu = windowMenu

        windowMenu.addItem(
            withTitle: "Minimize",
            action: #selector(NSWindow.performMiniaturize(_:)),
            keyEquivalent: "m"
        )
        windowMenu.addItem(withTitle: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
        windowMenu.addItem(.separator())
        windowMenu.addItem(
            withTitle: "Bring All to Front",
            action: #selector(NSApplication.arrangeInFront(_:)),
            keyEquivalent: ""
        )

        // MARK: • Help
        let helpMenuItem = NSMenuItem()
        mainMenu.addItem(helpMenuItem)
        let helpMenu = NSMenu(title: "Help")
        helpMenuItem.submenu = helpMenu
        NSApp.helpMenu = helpMenu

        helpMenu.addItem(
            withTitle: "\(appName) Help",
            action: #selector(NSApplication.showHelp(_:)),
            keyEquivalent: "?"
        )
    }
}
