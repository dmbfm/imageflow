import Foundation
import SharedModels
import SwiftUI

#if os(iOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

@MainActor
public class NodeContextMenuProvider {

    weak var coordinator: (any GlobalCoordinatorImpl)?
    private var id: UUID?

    public init(coordinator: (any GlobalCoordinatorImpl)?) {
        self.coordinator = coordinator
    }

    #if os(macOS)
    public func makeMenu(forNode id: UUID, at location: CGPoint) -> NSMenu? {
        self.id = id
        let menu = NSMenu(title: "Node Context Menu")
        let selectedCount = self.coordinator?.flow.selection.count ?? 0
        let nodeName = selectedCount > 1 ? "Nodes" : "Node"
        let hasSelection = selectedCount > 0

        guard let node = self.coordinator?.flow.nodes[id] else {
            return nil
        }

        menu.autoenablesItems = false

        let deleteItem = NSMenuItem(
            title: "Delete \(nodeName)",
            action: #selector(Self.contextMenuDeleteAction),
            keyEquivalent: "",
        )
        deleteItem.image = .init(
            systemSymbolName: .systemIconMenuDelete,
            accessibilityDescription: "Delete \(nodeName)"
        )
        deleteItem.isEnabled = hasSelection

        let duplicateItem = NSMenuItem(
            title: "Duplicate \(nodeName)",
            action: #selector(Self.contextMenuDuplicateAction),
            keyEquivalent: "d"
        )
        duplicateItem.image = .init(
            systemSymbolName: .systemIconMenuDuplicate,
            accessibilityDescription: "Duplicate \(nodeName)"
        )
        duplicateItem.isEnabled = hasSelection

        let copyItem = NSMenuItem(
            title: "Copy \(nodeName)",
            action: #selector(Self.contextMenuCopyAction),
            keyEquivalent: "c"
        )
        copyItem.image = .init(
            systemSymbolName: .systemIconMenuCopy,
            accessibilityDescription: "Copy \(nodeName)"
        )
        copyItem.isEnabled = hasSelection

        let cutItem = NSMenuItem(
            title: "Cut \(nodeName)",
            action: #selector(Self.contextMenuCutAction),
            keyEquivalent: "x"
        )
        cutItem.image = .init(
            systemSymbolName: .systemIconMenuCut,
            accessibilityDescription: "Cut \(nodeName)"
        )
        cutItem.isEnabled = hasSelection

        let pasteItem = NSMenuItem(
            title: "Paste \(nodeName)",
            action: #selector(Self.contextMenuPasteAction),
            keyEquivalent: "v",
        )
        pasteItem.image = .init(
            systemSymbolName: .systemIconMenuPaste,
            accessibilityDescription: "Paste \(nodeName)"
        )
        pasteItem.isEnabled = PasteboardObserver.shared.canPaste

        let selectAllItem = NSMenuItem(
            title: "Select All",
            action: #selector(Self.contextMenuSelectAllAction),
            keyEquivalent: "a"
        )
        selectAllItem.image = .init(
            systemSymbolName: .systemIconMenuSelectAll,
            accessibilityDescription: "Select All"
        )

        let exportImageItem = NSMenuItem(
            title: "Export Image...",
            action: #selector(Self.contextMenuExportImageAction),
            keyEquivalent: "E",
        )

        menu.addItem(.sectionHeader(title: "\(nodeName)"))
        menu.addItem(cutItem)
        menu.addItem(copyItem)
        menu.addItem(pasteItem)
        menu.addItem(duplicateItem)
        menu.addItem(deleteItem)
        menu.addItem(selectAllItem)

        if node.outputs.contains(where: { $0.type == .image }) {
            menu.addItem(.separator())
            menu.addItem(exportImageItem)
        }

        menu.items.forEach { $0.target = self }

        return menu
    }

    @objc
    func contextMenuExportImageAction() {
        if let id = self.id {
            self.coordinator?.perform(userAction: .exportImageForNode(id))
        }
    }

    @objc
    func contextMenuDeleteAction() {
        self.coordinator?.perform(userAction: .deleteSelectedNodes)
    }

    @objc
    func contextMenuDuplicateAction() {
        self.coordinator?.perform(userAction: .duplicateSelectedNodes)
    }

    @objc
    func contextMenuCopyAction() {
        self.coordinator?.perform(userAction: .copySelectedNodes)
    }

    @objc
    func contextMenuCutAction() {
        self.coordinator?.perform(userAction: .cutSelectedNodes)
    }
    @objc
    func contextMenuPasteAction() {
        self.coordinator?.perform(userAction: .pasteNodes(nil))
    }
    @objc
    func contextMenuSelectAllAction() {
        self.coordinator?.perform(userAction: .selectAllNodes)
    }
    #endif

    #if os(iOS)
    public func makeMenu(forNode id: UUID, at location: CGPoint) -> UIMenu? {

        let selectedCount = self.coordinator?.flow.selection.count ?? 0
        let nodeName = selectedCount > 1 ? "Nodes" : "Node"

        guard let node = self.coordinator?.flow.nodes[id] else {
            return nil
        }

        let deleteAction = UIAction(
            title: "Delete \(nodeName)",
            image: .init(systemName: "trash"),
            attributes: .destructive
        ) { _ in
            self.coordinator?.perform(userAction: .deleteSelectedNodes)
        }

        let duplicateAction = UIAction(
            title: "Duplicate \(nodeName)",
            image: .init(systemName: "plus.square.on.square")
        ) { _ in
            self.coordinator?.perform(userAction: .duplicateSelectedNodes)
        }

        let copyAction = UIAction(
            title: "Copy \(nodeName)",
            image: .init(systemName: "document.on.document")
        ) { _ in
            self.coordinator?.perform(userAction: .copySelectedNodes)
        }

        let cutAction = UIAction(
            title: "Cut \(nodeName)",
            image: .init(systemName: "scissors")
        ) { _ in
            self.coordinator?.perform(userAction: .cutSelectedNodes)
        }

        let pasteAction = UIAction(
            title: "Paste \(nodeName)",
            image: .init(systemName: "document.on.clipboard"),
            attributes: PasteboardObserver.shared.canPaste ? [] : .disabled,
        ) { _ in
            self.coordinator?.perform(userAction: .pasteNodes(.window(location)))
        }

        let selectAllAction = UIAction(
            title: "Select All",
            image: .init(systemName: "character.textbox"),
        ) { _ in
            self.coordinator?.perform(userAction: .selectAllNodes)
        }

        let exportImageAction = UIAction(
            title: "Export Image...",
        ) { _ in
            self.coordinator?.perform(userAction: .exportImageForNode(id))
        }

        let hasImageOutput = node.outputs.contains(where: { $0.type == .image })

        return UIMenu(
            title: "Node",
            children: [
                cutAction,
                copyAction,
                pasteAction,
                duplicateAction,
                deleteAction,
                selectAllAction,
            ]
                + (hasImageOutput
                    ? [
                        UIMenu(title: "", options: [.displayInline], children: [exportImageAction])
                    ] : [])
        )

    }
    #endif
}
