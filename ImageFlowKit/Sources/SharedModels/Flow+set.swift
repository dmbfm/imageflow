import Foundation

extension Flow {
    public func setNodeName(
        id: UUID,
        newValue: String,
        oldValue: String? = nil,
        undoManager um: UndoManager?
    ) {
        guard let node = self.nodes[id], node.name != newValue else {
            return
        }

        let oldValue = oldValue ?? node.name

        self.nodes[id]?.name = newValue

        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.setNodeName(
                    id: id,
                    newValue: oldValue,
                    oldValue: newValue,
                    undoManager: um
                )
            }
        )
        um?.setActionName("Change Node Name")
    }
}
