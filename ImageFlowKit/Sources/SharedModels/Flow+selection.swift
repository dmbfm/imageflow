//
//  Flow+selection.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 29/09/25.
//

import Foundation

// MARK: - Flow - Selection Methods

extension Flow {
    public func isSelected(_ id: UUID) -> Bool {
        self.selection.contains(id)
    }

    public func toggleSelected(_ id: UUID) {
        if self.selection.contains(id) {
            self.selection.remove(id)
        } else {
            self.selection.insert(id)
        }
    }

    @discardableResult
    public func selectAll(undoManager um: UndoManager? = nil) -> Set<UUID>? {
        self.select(Set(self.nodes.keys), undoManager: um)
    }

    @discardableResult
    public func selectNone(undoManager um: UndoManager? = nil) -> Set<UUID>? {
        self.select([], undoManager: um)
    }

    @discardableResult
    public func select(
        _ nodes: Set<UUID>,
        previousOverride: Set<UUID>? = nil,
        mode: SelectionMode = .replace,
        undoManager um: UndoManager? = nil
    ) -> Set<UUID>? {
        let filteredNodes = nodes.filter({ id in self.hasNode(id) })
        let prev = previousOverride ?? self.selection
        let next = mode == .replace ? filteredNodes : self.selection.union(filteredNodes)

        if prev == next {
            return nil
        }

        self.selection = next

        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                _ = this.select(prev, undoManager: um)
            }
        )

        return prev
    }

    public func selectNodeIfNotSelected(_ node: UUID) {
        guard !self.selection.contains(node) else { return }
        self.select([node])
    }

    public func liveSelectStart() {
        self.liveSelectSnapshot = self.selection
    }

    public func liveSelectEnd(undoManager um: UndoManager?) {
        guard let snapshot = self.liveSelectSnapshot else {
            fatalError("Called `leveSelectEnd` withoult calling `liveSelectStart`")
        }
        if snapshot != self.selection {
            self.select(self.selection, previousOverride: snapshot, mode: .replace, undoManager: um)
        }
    }

    public func liveSelectUpdate(_ nodes: Set<UUID>, mode: SelectionMode = .replace) {
        guard let snapshot = self.liveSelectSnapshot else {
            fatalError("Called `leveSelectUpdate` withoult calling `liveSelectStart`")
        }
        let filteredNodes = nodes.filter({ id in self.hasNode(id) })
        let next = mode == .replace ? filteredNodes : snapshot.union(filteredNodes)
        self.selection = next
    }

    func liveSelectCancel() {
        guard let snapshot = self.liveSelectSnapshot else {
            fatalError("Called `leveSelectCancel` withoult calling `liveSelectStart`")
        }
        self.selection = snapshot
        self.liveSelectSnapshot = nil
    }
}
