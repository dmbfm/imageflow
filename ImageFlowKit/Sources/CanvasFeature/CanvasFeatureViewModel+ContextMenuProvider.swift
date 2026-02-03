import CanvasView
import Helpers
import Logging
import SharedModels
import SwiftUI

extension CanvasFeatureViewModel: PositionedContextMenuProvider {
    #if os(iOS)
    public func canvasContextMenu(at location: CGPoint) -> UIMenu? {

        let pasteAction = UIAction(
            title: "Paste",
            image: .init(systemName: "document.on.clipboard"),
            attributes: PasteboardObserver.shared.canPaste ? [] : .disabled,
            handler: { [weak self] _ in
                self?.coordinator.perform(userAction: .pasteNodes(.canvasView(location)))
            },
        )

        let selectAllAction = UIAction(
            title: "Select All",
            image: .init(systemName: "character.textbox"),
        ) { [weak self] _ in
            self?.coordinator.perform(userAction: .selectAllNodes)
        }

        return UIMenu(
            title: "Canvas",
            children: [
                UIMenu(
                    title: "Add",
                    image: .init(systemName: "plus"),
                    children: NodePaletteService.shared.categories().map { category in
                        UIMenu(
                            title: category.name.rawValue,
                            children: category.items.map { item in
                                UIAction(
                                    title: item.displayName,
                                    image: .init(systemName: item.icon),
                                    handler: { [weak self] _ in
                                        self?.addButtonClick(item, location)
                                    }
                                )
                            }
                        )
                    }
                ),
                pasteAction,
                selectAllAction,
            ]
        )
    }
    #endif

    private func addButtonClick(_ item: NodePaletteItem, _ pos: CGPoint) {
        self.flow.newNodeAction(
            .init(kind: item.nodeKind),
            at: self.state.viewport.convert(pos, from: .screen, to: .canvas),
            undoManager: self.undoManager
        )
    }

    #if os(macOS)
    public func canvasContextMenu(at location: CGPoint) -> NSMenu? {
        NSHostingMenu(rootView: self._canvasContextMenu(at: location))
    }

    private func _canvasContextMenu(at location: CGPoint) -> some View {
        Group {
            Section("Canvas") {
                Menu("Add Node", systemImage: "plus") {
                    Button {
                        self.nodeSearchPopoverPresent()
                    } label: {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    ForEach(NodePaletteService.shared.categories()) { cat in
                        Menu(cat.name.rawValue) {
                            ForEach(cat.items) { item in
                                Button {
                                    self.addButtonClick(item, location)
                                } label: {
                                    Label(item.displayName, systemImage: item.icon)
                                }
                            }
                        }
                    }
                }

                Button { [weak self] in
                    self?.coordinator.perform(userAction: .pasteNodes(nil))
                } label: {
                    Label("Paste", systemImage: "document.on.clipboard")
                }
                .keyboardShortcut("v")
                .disabled(!PasteboardObserver.shared.canPaste)

                Button { [weak self] in
                    self?.coordinator.perform(userAction: .selectAllNodes)
                } label: {
                    Label("Select All", systemImage: .systemIconMenuSelectAll)
                }
                .keyboardShortcut("a")
            }
        }
    }
    #endif
}
