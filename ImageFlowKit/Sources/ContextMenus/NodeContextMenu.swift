import Backend
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

    func update(_ id: UUID) {
        let selectedCount = self.coordinator?.flow.selection.count ?? 0
        let targetSelected = self.coordinator?.flow.isSelected(id) ?? false
        self.id = id
        self.target =
            if targetSelected {
                .selection
            } else {
                .node(id)
            }
        self.nodeLabel =
            if !targetSelected || selectedCount <= 1 {
                "Node"
            } else {
                "Nodes"
            }

        self.node = self.coordinator?.flow.nodes[id]
    }

    var target: UserAction.Target = .selection
    var nodeLabel: String = "Node"
    var node: FlowNode?

    #if os(macOS)

    // swiftlint:disable function_body_length
    public func makeMenu(forNode id: UUID, at location: CGPoint) -> NSMenu? {
        self.update(id)

        let menu = NSMenu(title: "Node Context Menu")

        guard let node = self.node else {
            return nil
        }

        let nodeName = self.nodeLabel

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
        // deleteItem.isEnabled = hasSelection

        let duplicateItem = NSMenuItem(
            title: "Duplicate \(nodeName)",
            action: #selector(Self.contextMenuDuplicateAction),
            keyEquivalent: "d"
        )
        duplicateItem.image = .init(
            systemSymbolName: .systemIconMenuDuplicate,
            accessibilityDescription: "Duplicate \(nodeName)"
        )
        // duplicateItem.isEnabled = hasSelection

        let copyItem = NSMenuItem(
            title: "Copy \(nodeName)",
            action: #selector(Self.contextMenuCopyAction),
            keyEquivalent: "c"
        )
        copyItem.image = .init(
            systemSymbolName: .systemIconMenuCopy,
            accessibilityDescription: "Copy \(nodeName)"
        )
        // copyItem.isEnabled = hasSelection

        let cutItem = NSMenuItem(
            title: "Cut \(nodeName)",
            action: #selector(Self.contextMenuCutAction),
            keyEquivalent: "x"
        )
        cutItem.image = .init(
            systemSymbolName: .systemIconMenuCut,
            accessibilityDescription: "Cut \(nodeName)"
        )
        // cutItem.isEnabled = hasSelection

        let pasteItem = NSMenuItem(
            title: "Paste \(nodeName)",
            action: #selector(Self.contextMenuPasteAction),
            keyEquivalent: "v",
        )
        pasteItem.image = .init(
            systemSymbolName: .systemIconMenuPaste,
            accessibilityDescription: "Paste \(nodeName)"
        )
        // pasteItem.isEnabled = PasteboardObserver.shared.canPaste

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

        if node.variations.count > 1 {
            menu.addItem(self.variationsSubmenu(forNode: node))
        }

        menu.items.forEach { $0.target = self }

        return menu
    }

    struct VariationsMenu: View {

        let node: FlowNode
        weak var coordinator: (any GlobalCoordinatorImpl)?

        @State var selection: NodeKind?

        var binding: Binding<NodeKind?> {
            .init(
                get: {
                    self.node.kind
                },
                set: { newValue in
                    if let kind = newValue {
                        self.coordinator?.perform(userAction: .convertNode(self.node.id, kind))
                    }
                }
            )
        }

        var body: some View {
            Picker("Type", selection: self.binding) {
                ForEach(node.variations, id: \.self) { variation in
                    Text(variation.displayName)
                        .tag(variation)
                }
            }.pickerStyle(.inline)
        }
    }

    func variationsSubmenu(forNode node: FlowNode) -> NSMenuItem {
        let item = NSMenuItem(title: "Convert Node", action: nil, keyEquivalent: "")
        let menu = NSHostingMenu(
            rootView: VariationsMenu(node: node, coordinator: self.coordinator)
        )
        item.submenu = menu
        return item
    }

    @objc
    func contextMenuExportImageAction() {
        if let id = self.id {
            self.coordinator?.perform(userAction: .exportImageForNode(id))
        }
    }

    @objc
    func contextMenuDeleteAction() {
        self.coordinator?.perform(userAction: .delete(self.target))
    }

    @objc
    func contextMenuDuplicateAction() {
        self.coordinator?.perform(userAction: .duplicate(self.target))
    }

    @objc
    func contextMenuCopyAction() {
        self.coordinator?.perform(userAction: .copy(self.target))
    }

    @objc
    func contextMenuCutAction() {
        self.coordinator?.perform(userAction: .cut(self.target))
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
    // swiftlint:disable function_body_length
    public func makeMenu(forNode id: UUID, at location: CGPoint) -> UIMenu? {
        self.update(id)

        let nodeName = self.nodeLabel

        guard let node = self.node else {
            return nil
        }

        let deleteAction = UIAction(
            title: "Delete \(nodeName)",
            image: .init(systemName: "trash"),
            attributes: .destructive
        ) { _ in
            self.coordinator?.perform(userAction: .delete(self.target))
        }

        let duplicateAction = UIAction(
            title: "Duplicate \(nodeName)",
            image: .init(systemName: "plus.square.on.square")
        ) { _ in
            self.coordinator?.perform(userAction: .duplicate(self.target))
        }

        let copyAction = UIAction(
            title: "Copy \(nodeName)",
            image: .init(systemName: "document.on.document")
        ) { _ in
            self.coordinator?.perform(userAction: .copy(self.target))
        }

        let cutAction = UIAction(
            title: "Cut \(nodeName)",
            image: .init(systemName: "scissors")
        ) { _ in
            self.coordinator?.perform(userAction: .cut(self.target))
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
            .appending(
                UIMenu(title: "", options: [.displayInline], children: [exportImageAction]),
                ifCondition: { hasImageOutput }
            )
            .appending(self.variationsSubmenu(forNode: node), ifCondition: { node.variations.count > 1 })
        )
    }

    func variationsSubmenu(forNode node: FlowNode) -> UIMenu {
        UIMenu(
            title: "Convert Node",
            options: [.singleSelection],
            children: node.variations.map { variation in
                UIAction(
                    title: variation.displayName,
                    state: variation == node.kind ? .on : .off,
                    handler: { _ in
                        self.coordinator?.perform(userAction: .convertNode(node.id, variation))
                    }
                )
            }
        )
    }
    #endif
}
