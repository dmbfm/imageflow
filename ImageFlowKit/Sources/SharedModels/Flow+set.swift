import Foundation

extension Flow {
    public func setNodeName(
        id: UUID,
        newValue: String,
        oldValue: String? = nil,
        undoService: UndoService?
    ) {
        guard let node = self.nodes[id], node.name != newValue else {
            return
        }

        let oldValue = oldValue ?? node.name

        self.nodes[id]?.name = newValue

        undoService?.register(
            withTarget: self,
            title: "Change Node Name",
            icon: nil,
            handler: { [weak undoService] this in
                this.setNodeName(
                    id: id,
                    newValue: oldValue,
                    oldValue: newValue,
                    undoService: undoService
                )
            }
        )
    }
}
