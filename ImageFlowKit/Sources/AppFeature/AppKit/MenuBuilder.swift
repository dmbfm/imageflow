#if canImport(AppKit)

import AppKit

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

    func withNSMenuItem(_ ref: @escaping ((NSMenuItem) -> ())) -> Self {
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
    case subMenu(String, [MenuItem], ((NSMenuItem) -> ())? = nil)

    func build() -> NSMenuItem {
        switch self {
        case .separator:
            .separator()
        case let .simple(title, selector, keyEquivalent, flags):
            {
                let item = NSMenuItem(title: title, action: selector, keyEquivalent: keyEquivalent)
                item.keyEquivalentModifierMask = flags
                return item
            }()
        case let .subMenu(title, items, ref):
            {
                let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
                item.submenu = Menu(title: title, items: items).build()
                if let ref {
                    ref(item)
                }
                return item
            }()
        }
    }
}

@resultBuilder
struct MenuBuilder {
    static func buildBlock(_ components: AnyMenuItem...) -> [MenuItem] {
        components.map { $0.item }
    }
}
#endif
