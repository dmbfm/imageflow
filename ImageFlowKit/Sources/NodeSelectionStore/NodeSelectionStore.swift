import Foundation
import Models

public struct NodeSelectionStore: Sendable, Equatable, Codable {

    public private(set) var selection: Set<UUID> = []

    public enum SelectionMode {
        case union
        case replace
    }

    public init(selection: Set<UUID> = []) {
        self.selection = selection
    }

    public func isSelected(_ node: UUID) -> Bool {
        self.selection.contains(node)
    }

    public mutating func select(node: UUID, mode: SelectionMode = .replace) {
        self.select(nodes: [node], mode: mode)
    }

    public mutating func select(nodes: [UUID], mode: SelectionMode = .replace) {
        self.select(nodes: Set(nodes), mode: mode)
    }

    public mutating func select(nodes: Set<UUID>, mode: SelectionMode = .replace) {
        switch mode {
        case .replace:
            self.selection = nodes
            break
        case .union:
            self.selection.formUnion(nodes)
        }
    }

    public mutating func deselectNodes(node: UUID) {
        self.deselectNodes(nodes: [node])
    }

    public mutating func deselectNodes(nodes: Set<UUID>) {
        self.selection.subtract(nodes)
    }

    public mutating func deselectAll() {
        self.selection = []
    }
}

extension NodeSelectionStore: Storable {
    public typealias StorableData = NodeSelectionStore

    public init(_ data: NodeSelectionStore) {
        self = data
    }

    public func snapshot() async throws -> NodeSelectionStore {
        self
    }
}
