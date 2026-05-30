import Foundation
import Helpers
import SharedModels

enum NodeInspectorViewModel: Equatable {
    case empty
    case content(node: FlowNode, selection: Set<UUID>, locked: Bool)

    enum Input {
        case selection(nodes: [UUID: FlowNode], selection: Set<UUID>)
    }

    func input(_ input: Input) -> Self {
        switch input {
        case .selection(let nodes, let selection):
            self.selection(nodes, selection)
        }
    }

    mutating func update(_ input: Input) {
        self = self.input(input)
    }

    private func selection(_ nodes: [UUID: FlowNode], _ selection: Set<UUID>) -> Self {
        switch self {
        case .empty:
            if let id = selection.first, let node = nodes[id] {
                .content(node: node, selection: selection, locked: false)
            } else {
                .empty
            }
        case .content(_, _, locked: true):
            self
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
