#if canImport(AppKit)

import AppKit

extension NSApplication {
    var appName: String {
        ProcessInfo.processInfo.processName
    }

    func setupMainMenu() {
        let menu = Menu {
            SubMenu(appName) {
                Item("About \(appName)", #selector(orderFrontStandardAboutPanel(_:)))
                Separator()
                Item("Settings...", nil, ",")
                Separator()
                SubMenu("Services") {}
                    .withNSMenuItem { NSApp.servicesMenu = $0.submenu }
                Separator()
                Item("Hide \(appName)", #selector(hide(_:)), "h")
                Item("Hide Others", #selector(hideOtherApplications(_:)), "h")
                    .modifierFlags([.option])
                Separator()
                Item("Quit \(appName)", #selector(terminate(_:)), "q")
            }

            SubMenu("File") {
                Item("New", #selector(NSDocumentController.newDocument(_:)), "n")
                Item("Open...", #selector(NSDocumentController.openDocument(_:)), "o")
                SubMenu("Open Recent...") {}
                Separator()
                Item("Close", #selector(NSWindow.performClose(_:)), "w")
                Item("Save", #selector(NSDocument.save(_:)), "s")
                Item("Save As...", #selector(NSDocument.saveAs(_:)), "s").modifierFlags([.command, .shift])
                Item("Revert to Saved", #selector(NSDocument.revertToSaved(_:)), "r")
            }

            SubMenu("Edit") {
                Item("Undo", #selector(EditMenuActions.undo(_:)), "z")
                Item("Redo", #selector(EditMenuActions.redo(_:)), "z").modifierFlags([.command, .shift])
                Separator()
                Item("Cut", #selector(EditMenuActions.cut(_:)), "x")
                Item("Copy", #selector(EditMenuActions.copy(_:)), "c")
                Item("Paste", #selector(EditMenuActions.paste(_:)), "v")
                Separator()
                Item("Select All Nodes", #selector(FlowDocument.selectAllNodes(_:)), "a")
                Item("Deselect All Nodes", #selector(FlowDocument.deselectAllNodes(_:)), "a").modifierFlags([
                    .command, .shift,
                ])
            }

            SubMenu("View") {
            }

            SubMenu("Window") {}.withNSMenuItem { self.windowsMenu = $0.submenu }

            SubMenu("Help") {}.withNSMenuItem { self.helpMenu = $0.submenu }

        }

        self.mainMenu = menu.build()
    }
}

@objc protocol EditMenuActions {
    func redo(_ sender: AnyObject)
    func undo(_ sender: AnyObject)
    func cut(_ sender: AnyObject)
    func copy(_ sender: AnyObject)
    func paste(_ sender: AnyObject)
}

#endif
