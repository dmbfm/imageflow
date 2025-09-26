import Foundation
import Models

@Observable
@MainActor
public final class NodeSelectionStore {

    public var selection: Set<UUID> = []

    public enum Action {
        case deselectAll(ActionUndoData?)
        case select(Select, ActionUndoData?)
        case deselect(Set<UUID>, ActionUndoData?)

        public struct Select {
            public var nodes: Set<UUID>
            public var prevOverride: Set<UUID>?
            public var mode: SelectionMode

            public init(nodes: Set<UUID>, prevOverride: Set<UUID>?, mode: NodeSelectionStore.SelectionMode) {
                self.nodes = nodes
                self.mode = mode
            }
        }
    }

    public enum SelectionMode {
        case union
        case replace
    }

    public init(selection: Set<UUID> = []) {
        self.selection = selection
    }

    public func perform(_ action: Action) {
        switch action {
        case .deselectAll(let um):
            self.deselectAll(undoManager: um?.undoManager, undoTitle: um?.title)
        case .select(let select, let um):
            self.select(
                nodes: select.nodes,
                mode: select.mode,
                previousOverride: select.prevOverride,
                undoManager: um?.undoManager,
                undoTitle: um?.title
            )
        case .deselect(let ids, let um):
            self.deselectNodes(
                nodes: ids,
                undoManager: um?.undoManager,
                undoTitle: um?.title
            )
        }
    }

    public func isSelected(_ node: UUID) -> Bool {
        self.selection.contains(node)
    }

    public func select(
        nodes: Set<UUID>,
        mode: SelectionMode = .replace,
        previousOverride: Set<UUID>? = nil,
        undoManager um: UndoManager? = nil,
        undoTitle: String? = "Select"
    ) {
        switch mode {
        case .replace:
            self.setSelection(
                nodes: nodes,
                previousOverride: previousOverride,
                undoManager: um,
                undoTitle: undoTitle
            )
        case .union:
            self.setSelection(
                nodes: self.selection.union(nodes),
                previousOverride: previousOverride,
                undoManager: um,
                undoTitle: undoTitle
            )
        }
    }

    public func setSelection(
        nodes: Set<UUID>,
        previousOverride: Set<UUID>? = nil,
        undoManager um: UndoManager? = nil,
        undoTitle: String? = "Selection"
    ) {
        let prev = previousOverride ?? self.selection
        if nodes != prev {
            self.selection = nodes
            um?.registerUndo(
                withTarget: self,
                handler: { [weak um] this in
                    this.setSelection(nodes: prev, previousOverride: nodes, undoManager: um, undoTitle: undoTitle)
                }
            )

            if let undoTitle {
                um?.setActionName(undoTitle)
            }
        }
    }

    public func deselectNode(node: UUID, undoManager um: UndoManager? = nil, undoTitle: String? = "Deselect Node") {
        self.setSelection(nodes: self.selection.subtracting([node]), undoManager: um, undoTitle: undoTitle)
    }

    public func deselectNodes(
        nodes: Set<UUID>,
        undoManager um: UndoManager? = nil,
        undoTitle: String? = "Deselect Nodes"
    ) {
        self.setSelection(nodes: self.selection.subtracting(nodes), undoManager: um, undoTitle: undoTitle)
    }

    public func deselectAll(undoManager um: UndoManager? = nil, undoTitle: String? = "Deselect All") {
        self.setSelection(nodes: [], undoManager: um, undoTitle: undoTitle)
    }
}

extension NodeSelectionStore: Storable {
    public struct StorableData: Equatable, Sendable, Codable {

        public var selection: Set<UUID> = []

        public init(selection: Set<UUID> = []) {
            self.selection = selection
        }
    }
    public convenience init(_ data: StorableData) {
        self.init(selection: data.selection)
    }

    public func snapshot() -> StorableData {
        .init(selection: self.selection)
    }

    public func restore(_ snapshot: StorableData) {
        self.selection = snapshot.selection
    }
}
