import CanvasView
import Logging
import SharedModels
import SwiftUI

extension CanvasFeatureViewModel: CanvasContextMenuProvider {
    #if os(iOS)
    public func canvasContextMenu(at location: CGPoint) -> UIMenu? {
        UIMenu(
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
                UIAction(
                    title: "Paste",
                    image: .init(systemName: "document.on.clipboard"),
                    attributes: .disabled,
                    handler: { _ in }
                ),
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
            Menu("Add", systemImage: "plus") {
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

            Button {
                log("TODO", level: .warning)
            } label: {
                Label("Paste", systemImage: "document.on.clipboard")
            }

        }
    }
    #endif
}
