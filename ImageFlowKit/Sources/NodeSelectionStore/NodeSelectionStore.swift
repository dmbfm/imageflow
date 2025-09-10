import Foundation

public struct NodeSelectionStore: Sendable, Equatable, Codable {

    public private(set) var selection: Set<UUID> = []

    public enum SelectionMode {
        case union
        case replace
    }

    public enum Action {
        case clickNode(UUID, shift: Bool)
    }

    public init(selection: Set<UUID> = []) {
        self.selection = selection
    }

    public mutating func userAction(action: Action) {
        switch action {
        case let .clickNode(id, shift: shift):
            self.select(node: id, mode: shift ? .union : .replace)
        }
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
