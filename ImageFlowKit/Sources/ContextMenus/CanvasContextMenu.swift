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

    weak var coordinator: GlobalCoordinator?

    public init(coordinator: GlobalCoordinator?) {
        self.coordinator = coordinator
    }

    func pickItem(_ item: NodePaletteItem, _ pos: CGPoint) {
        self.coordinator?.perform(userAction: .newNode(kind: item.nodeKind, at: .canvasView(pos)))
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
    public func makeMenu(at location: CGPoint) -> NSMenu? {
        NSHostingMenu(rootView: self._canvasContextMenu(at: location))
    }

    private func _canvasContextMenu(at location: CGPoint) -> some View {
        Group {
            Section("Canvas") {
                Menu("Add Node", systemImage: "plus") {
                    Button {
                        self.coordinator?.perform(
                            userAction: .showNodeSearch(typedPortLocation: nil, canvasPosition: location)
                        )
                    } label: {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    ForEach(NodePaletteService.shared.categories()) { cat in
                        Menu(cat.name.rawValue) {
                            ForEach(cat.items) { item in
                                Button {
                                    self.pickItem(item, location)
                                } label: {
                                    Label(item.displayName, systemImage: item.icon)
                                }
                            }
                        }
                    }
                }

                ZoomMenu()

                Button {
                    self.coordinator?.perform(userAction: .pasteNodes(nil))
                } label: {
                    Label("Paste", systemImage: "document.on.clipboard")
                }
                .keyboardShortcut("v")
                .disabled(!PasteboardObserver.shared.canPaste)

                Button {
                    self.coordinator?.perform(userAction: .selectAllNodes)
                } label: {
                    Label("Select All", systemImage: .systemIconMenuSelectAll)
                }
                .keyboardShortcut("a")
            }
        }
    }
    #endif
}
