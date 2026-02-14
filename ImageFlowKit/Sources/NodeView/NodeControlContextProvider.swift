import Foundation
import Values

@MainActor
class NodeControlContextProvider {

    weak var nodeView: NodeView?

    init(_ nodeView: NodeView?) {
        self.nodeView = nodeView
    }

    func nodeControlContext(_ node: UUID, _ index: Int) -> NodeControlContext {
        .init(undo: UndoManager(nodeView: self.nodeView, node: node, index: index))
    }

    @MainActor
    class UndoManager: NodeControlUndoManager {

        weak var nodeView: NodeView?

        var node: UUID
        var index: Int

        internal init(nodeView: NodeView?, node: UUID, index: Int) {
            self.nodeView = nodeView
            self.node = node
            self.index = index
        }

        func register(_ oldValue: Values.Value, _ newValue: Values.Value) {
            self.nodeView?.delegate?.nodeView(
                registerUndoForNode: self.node,
                inputIndex: self.index,
                oldValue: oldValue,
                newValue: newValue
            )
        }
    }
}
