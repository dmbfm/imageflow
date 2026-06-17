import Foundation
import Helpers
import SharedModels

enum NodeInspectorViewModel: Equatable {
    case empty
    case content(node: FlowNode, selection: Set<UUID>, locked: Bool)

    enum Input {
        case nodesDidChange(nodes: [UUID: FlowNode])
        case selection(nodes: [UUID: FlowNode], selection: Set<UUID>)
        case toggleLock(nodes: [UUID: FlowNode])
    }

    var node: FlowNode? {
        switch self {
        case .content(let node, _, _):
            node
        case .empty:
            nil
        }
    }

    func input(_ input: Input) -> Self {
        switch input {
        case .selection(let nodes, let selection):
            self.selection(nodes, selection)
        case .toggleLock(let nodes):
            self.toggleLock(nodes)
        case .nodesDidChange(let nodes):
            self.nodesDidChange(nodes)
        }
    }

    mutating func update(_ input: Input) {
        self = self.input(input)
    }

    private func nodesDidChange(_ nodes: [UUID: FlowNode]) -> Self {
        switch self {
        case .empty:
            .empty
        case .content(let node, let selection, let locked):
            if let newNode = nodes[node.id] {
                .content(node: newNode, selection: selection, locked: locked)
            } else {
                self
            }
        }
    }

    private func toggleLock(_ nodes: [UUID: FlowNode]) -> Self {
        switch self {
        case .empty:
            .empty
        case .content(let node, let sel, locked: false):
            .content(node: node, selection: sel, locked: true)
        case .content(let node, let sel, locked: true):
            if sel.contains(node.id) {
                .content(node: node, selection: sel, locked: false)
            } else if let id = sel.first, let node = nodes[id] {
                .content(node: node, selection: sel, locked: false)
            } else {
                .empty
            }
        }
    }

    private func selection(_ nodes: [UUID: FlowNode], _ selection: Set<UUID>) -> Self {
        switch self {
        case .empty:
            if let id = selection.first, let node = nodes[id] {
                .content(node: node, selection: selection, locked: false)
            } else {
                .empty
            }
        case .content(let node, _, locked: true):
            .content(node: node, selection: selection, locked: true)
        case .content(let node, _, locked: false):
            if selection.contains(node.id) {
                .content(node: node, selection: selection, locked: false)
            } else if let id = selection.first, let node = nodes[id] {
                .content(node: node, selection: selection, locked: false)
            } else {
                .empty
            }
        }
    }
}
