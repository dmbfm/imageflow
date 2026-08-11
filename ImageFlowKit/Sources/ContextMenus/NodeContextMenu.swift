#if os(macOS)

import AppKit
import SharedModels

public struct NodeContextMenu {
    @MainActor
    public static func make(_ flow: Flow, _ node: UUID, showSelectAll: Bool = true) -> NSMenu? {

        let menu = NSMenu()

        let nodeName = flow.selection.count > 1 && flow.selection.contains(node) ? "Nodes" : "Node"
        let hasSlug = flow.nodes[node]?.kind.docSlug != nil

        menu.addItem(.sectionHeader(title: "Node"))
        menu.addItem(
            NSMenuItemForNode(
                node: node,
                title: "Rename Node",
                systemSymbolName: "character.cursor.ibeam",
                accessibilityDescription: "Rename Node",
                action: #selector(ImageFlowResponding.rename(_:)),
                keyEquivalent: ""
            )
        )
        menu.addItem(
            NSMenuItemForNode(
                node: node,
                title: "Cut \(nodeName)",
                systemSymbolName: .systemIconMenuCut,
                accessibilityDescription: "Cut \(nodeName)",
                action: #selector(NSText.cut(_:)),
                keyEquivalent: "x"
            )
        )
        menu.addItem(
            NSMenuItemForNode(
                node: node,
                title: "Copy \(nodeName)",
                systemSymbolName: .systemIconMenuCopy,
                accessibilityDescription: "Copy \(nodeName)",
                action: #selector(NSText.copy(_:)),
                keyEquivalent: "c"
            )
        )
        menu.addItem(
            NSMenuItemForNode(
                node: node,
                title: "Paste",
                systemSymbolName: .systemIconMenuPaste,
                accessibilityDescription: "Paste",
                action: #selector(NSText.paste(_:)),
                keyEquivalent: "v"
            )
        )
        menu.addItem(
            NSMenuItemForNode(
                node: node,
                title: "Duplicate \(nodeName)",
                systemSymbolName: .systemIconMenuDuplicate,
                accessibilityDescription: "Duplicate \(nodeName)",
                action: #selector(ImageFlowResponding.duplicate(_:)),
                keyEquivalent: "d"
            )
        )
        menu.addItem(
            NSMenuItemForNode(
                node: node,
                title: "Delete \(nodeName)",
                systemSymbolName: .systemIconMenuDelete,
                accessibilityDescription: "Delete \(nodeName)",
                action: #selector(NSText.delete(_:)),
                keyEquivalent: "\u{08}",
                keyEquivatletModifierMask: []
            )
        )
        if showSelectAll {
            menu.addItem(
                NSMenuItemForNode(
                    node: node,
                    title: "Select All",
                    systemSymbolName: .systemIconMenuSelectAll,
                    accessibilityDescription: "Select All",
                    action: #selector(NSResponder.selectAll(_:)),
                    keyEquivalent: "a"
                )
            )
        }
        let item = NSMenuItemForNode(
            node: node,
            title: "Open Documentation",
            systemSymbolName: .systemIconDocumentation,
            accessibilityDescription: "Open Documentation",
            action: hasSlug ? #selector(ImageFlowResponding.openNodeDocumentation(_:)) : nil,
            keyEquivalent: "",
            keyEquivatletModifierMask: nil
        )
        menu.addItem(item)
        return menu
    }
}

#endif
