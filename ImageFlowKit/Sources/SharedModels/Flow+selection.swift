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
    public func selectAll() -> Set<UUID>? {
        self.select(Set(self.nodes.keys))
    }

    @discardableResult
    public func selectNone() -> Set<UUID>? {
        self.select([])
    }

    @discardableResult
    public func select(
        _ nodes: Set<UUID>,
        previousOverride: Set<UUID>? = nil,
        mode: SelectionMode = .replace
    ) -> Set<UUID>? {
        let filteredNodes = nodes.filter({ id in self.hasNode(id) })
        let prev = previousOverride ?? self.selection
        let next = mode == .replace ? filteredNodes : self.selection.union(filteredNodes)

        if prev == next {
            return nil
        }

        self.selection = next

        return prev
    }

    public func selectNodeIfNotSelected(_ node: UUID) {
        guard !self.selection.contains(node) else { return }
        self.select([node])
    }

    public func select(nodeConnectedToNode id: UUID, atInputPort index: Int) {
        if let edge = self.edges(ofPort: .init(node: id, port: .input(index))).first {
            self.select([edge.from.node])
        }
    }

    public func liveSelectStart() {
        self.liveSelectSnapshot = self.selection
    }

    public func liveSelectEnd() {
        guard let snapshot = self.liveSelectSnapshot else {
            fatalError("Called `leveSelectEnd` withoult calling `liveSelectStart`")
        }
        if snapshot != self.selection {
            self.select(self.selection, previousOverride: snapshot, mode: .replace)
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
