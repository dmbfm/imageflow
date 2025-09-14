//
//  AppMac.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 13/09/25.
//

#if canImport(AppKit)

import AppKit
import SwiftUI
import Logging
import CommonUtils

@MainActor
public struct ImageFlowApp {
    public static func main() {
        let delegate = AppDelegate()
        NSApplication.shared.delegate = delegate
        _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        log("", level: .trace)
        NSApp.buildMainMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        log("", level: .trace)
    }
}

extension NSApplication {
    var appName: String {
        ProcessInfo.processInfo.processName
    }

    func buildMainMenu() {

        let menu = Menu {
            SubMenu(appName) {
                Item("About \(appName)", #selector(orderFrontStandardAboutPanel(_:)))
                Separator()
                Item("Preferences...", nil,  ",")
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
                Item("Deselect All Nodes", #selector(FlowDocument.deselectAllNodes(_:)), "a").modifierFlags([.command, .shift])
            }

            SubMenu("View") {
            }

            SubMenu("Window") {}.withNSMenuItem {  self.windowsMenu = $0.submenu }

            SubMenu("Help") {}.withNSMenuItem { self.helpMenu = $0.submenu }

        }

        self.mainMenu = menu.build()
    }
}

@objc protocol EditMenuActions {
    func redo(_ sender:AnyObject)
    func undo(_ sender:AnyObject)
    func cut(_ sender:AnyObject)
    func copy(_ sender:AnyObject)
    func paste(_ sender:AnyObject)
}

struct Menu {

    var title: String
    var items: [MenuItem]

    init(title: String, items: [MenuItem]) {
        self.title = title
        self.items = items
    }

    init(title: String = "", @MenuBuilder _ items: () -> [MenuItem]) {
        self.init(title: title, items: items())
    }

    @MainActor
    func build() -> NSMenu {
        let menu = NSMenu(title: title)
        for item in self.items {
            menu.addItem(item.build())
        }
        return menu
    }
}

protocol AnyMenuItem {
    var item: MenuItem { get }
}

struct SubMenu: AnyMenuItem {
    var title: String
    var items: [MenuItem]
    var ref: ((NSMenuItem) -> ())? = nil

    init(_ title: String = "", @MenuBuilder _ items: () -> [MenuItem]) {
        self.title = title
        self.items = items()
    }

    func withNSMenuItem(_ ref: @escaping ((NSMenuItem) -> ())) ->  Self {
        var r = self
        r.ref = ref
        return r
    }

    var item: MenuItem {
        .subMenu(title, items, ref)
    }
}

struct Separator: AnyMenuItem {
    var item: MenuItem { .separator }
}

struct Item: AnyMenuItem {

    var title: String
    var action: Selector?
    var keyEquivalent: String
    var modifierFlags: NSEvent.ModifierFlags

    init(_ title: String, _ action: Selector? = nil, _ keyEquivalent: String = "") {
        self.title = title
        self.action = action
        self.keyEquivalent = keyEquivalent
        self.modifierFlags = [.command]
    }

    func modifierFlags(_ flags: NSEvent.ModifierFlags) -> Self {
        var r = self
        r.modifierFlags = flags
        return r
    }

    var item: MenuItem {
        .simple(title, action, keyEquivalent, modifierFlags)
    }
}

@MainActor
enum MenuItem {
    case simple(String, Selector? = nil, String = "", NSEvent.ModifierFlags = [])
    case separator
    case subMenu(String, [MenuItem], ((NSMenuItem) ->())?  = nil)

    func build() -> NSMenuItem {
        switch self {
        case .separator:
            .separator()
        case let .simple(title, selector, keyEquivalent, flags):
            {
                let item =  NSMenuItem(title: title, action: selector, keyEquivalent: keyEquivalent)
                item.keyEquivalentModifierMask = flags
                log("xxx \(item.title), \(item.keyEquivalent), \(item.keyEquivalentModifierMask)")
                return item
            }()
        case let .subMenu(title, items, ref):
            {
                let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
                item.submenu = Menu(title: title, items: items).build()
                if let ref {
                    ref(item)
                }
                // if title == "Services" {
                //     NSApp.servicesMenu = item.submenu
                // }
                return item
            }()
        }
    }
}

@resultBuilder
struct MenuBuilder {
    // static func buildBlock(_ components: MenuItem...) -> [MenuItem] {
    //     components
    // }

    static func buildBlock(_ components: AnyMenuItem...) -> [MenuItem] {
        components.map { $0.item }
    }
}

// struct MenuItem {
//     var title: String
//     var items: [MenuItem]

//     func build() -> NSMenuItem {
//         if items.isEmpty {
//              return .init(title: self.title, action: nil, keyEquivalent: "")
//         } else {
//             let item = NSMenuItem()
//             item.menu = Menu(title: self.title, items: items).build()
//             return item
//         }
//     }
// }

#endif
