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
public class CanvasContextMenuProvider {

    var coordinator: GlobalCoordinator

    public init(_ coordinator: GlobalCoordinator) {
        self.coordinator = coordinator
    }

    func pickItem(_ item: NodePaletteItem, _ pos: CGPoint) {
        // self.coordinator?.perform(userAction: .newNodeWithKind(kind: item.nodeKind, at: .canvasView(pos)))
    }

    #if os(iOS)
    public func makeMenu(at location: CGPoint) -> UIMenu? {
        let pasteAction = UIAction(
            title: "Paste",
            image: .init(systemName: "document.on.clipboard"),
            attributes: PasteboardObserver.shared.canPaste ? [] : .disabled,
            handler: { [weak self] _ in
                self?.coordinator?.perform(userAction: .pasteNodes(.canvasView(location)))
            },
        )

        let selectAllAction = UIAction(
            title: "Select All",
            image: .init(systemName: "character.textbox"),
        ) { [weak self] _ in
            self?.coordinator?.perform(userAction: .selectAllNodes)
        }

        let selectNodes = UIAction(
            title: "Select Nodes",
            image: .init(systemName: "rectangle.dashed"),
        ) { [weak self] _ in
            self?.coordinator?.perform(userAction: .selectNodesInteractive)
        }

        return UIMenu(
            title: "Canvas",
            children: [
                UIMenu(
                    title: "Add Node",
                    image: .init(systemName: "plus"),
                    children: NodePaletteService.shared.categories().map { category in
                        UIMenu(
                            title: category.name.rawValue,
                            children: category.items.map { item in
                                UIAction(
                                    title: item.displayName,
                                    image: .init(systemName: item.icon),
                                    handler: { [weak self] _ in
                                        self?.pickItem(item, location)
                                    }
                                )
                            }
                        )
                    }
                ),
                pasteAction,
                selectAllAction,
                selectNodes,
                makeZoomUIMenu(self.coordinator),
            ]
        )
    }
    #endif

    #if os(macOS)

    var zoomMenuController: ZoomMenuController?

    public func makeMenu(at location: CGPoint) -> NSMenu? {
        let menu = NSMenu(title: "Canvas")
        let canPaste = PasteboardObserver.shared.canPaste

        self.zoomMenuController = .init(coordinator)

        let addNodeItem = NSMenuItem(
            title: "Add Node",
            action: nil,
            keyEquivalent: "",
            systemSymbolName: "plus",
            accessibilityDescription: "Add a new node"
        )

        addNodeItem.submenu = {
            let menu = NSMenu()

            var catItems: [NSMenuItem] = []

            for cat in NodePaletteService.shared.categories() {
                let item = NSMenuItem.init(title: cat.name.rawValue, action: nil, keyEquivalent: "")
                item.submenu = {
                    let menu = NSMenu()

                    for item in cat.items {
                        let menuItem = NodePaletteNSMenuItem(
                            nodePaletteItem: item,
                            location: location,
                            title: item.displayName,
                            action: #selector(Self.nodePaletteItemAction(_:)),
                            keyEquivalent: "",
                            systemSymbolName: item.icon,
                            accessibilityDescription: "Create a '\(item.displayName)' node"
                        )
                        menuItem.target = self
                        menu.addItem(menuItem)
                    }

                    return menu
                }()
                catItems.append(item)
            }

            menu.items =
                [
                    NodePaletteNSMenuItem(
                        nodePaletteItem: .init(
                            nodeKind: .valueNode(.float),
                            categoryName: .input
                        ),
                        location: location,
                        title: "Search",
                        action: #selector(Self.showNodeSearch(_:)),
                        target: self,
                        keyEquivalent: "",
                        systemSymbolName: "magnifyingglass",
                        accessibilityDescription: "Show node palette search"
                    )
                ] + catItems
            return menu
        }()

        let zoomItem = NSMenuItem(title: "Zoom", action: nil, keyEquivalent: "")
        zoomItem.submenu = self.zoomMenuController?.makeMenu()

        let pasteItem = NSMenuItem(
            title: "Paste",
            action: canPaste ? #selector(Self.paste) : nil,
            target: self,
            keyEquivalent: "v",
            keyEquivalentModifierMask: .command,
            systemSymbolName: .systemIconMenuPaste,
            accessibilityDescription: "Paste"
        )

        let selectAllItem = NSMenuItem(
            title: "Select  All",
            action: #selector(Self.selectAll),
            target: self,
            keyEquivalent: "a",
            keyEquivalentModifierMask: .command,
            systemSymbolName: .systemIconMenuSelectAll,
            accessibilityDescription: "Select All Nodes"
        )

        menu.items = [
            .sectionHeader(title: "Canvas"),
            addNodeItem,
            zoomItem,
            pasteItem,
            selectAllItem,
        ]

        return menu
    }

    @objc func selectAll() {
        self.coordinator.perform(userAction: .selectAllNodes)
    }

    @objc func paste() {
        self.coordinator.perform(userAction: .pasteNodes(nil))
    }

    @objc func showNodeSearch(_ item: NodePaletteNSMenuItem) {
        self.coordinator.perform(userAction: .showNodeSearch(typedPortLocation: nil, canvasPosition: item.location))
    }

    @objc func nodePaletteItemAction(_ item: NodePaletteNSMenuItem) {
        self.coordinator.perform(
            userAction: .newNodeWithKind(kind: item.nodePaletteItem.nodeKind, at: .canvasView(item.location))
        )
    }
    #endif
}

#if os(macOS)
class NodePaletteNSMenuItem: NSMenuItem {

    let nodePaletteItem: NodePaletteItem
    let location: CGPoint

    init(
        nodePaletteItem: NodePaletteItem,
        location: CGPoint,
        title string: String,
        action selector: Selector?,
        target: AnyObject? = nil,
        keyEquivalent charCode: String,
        systemSymbolName: String,
        accessibilityDescription: String?
    ) {
        self.nodePaletteItem = nodePaletteItem
        self.location = location
        super.init(title: string, action: selector, keyEquivalent: charCode)
        self.image = .init(systemSymbolName: systemSymbolName, accessibilityDescription: accessibilityDescription)
        self.target = target
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
