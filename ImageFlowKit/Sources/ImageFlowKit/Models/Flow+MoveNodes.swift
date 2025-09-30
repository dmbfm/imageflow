import Foundation

extension Flow {
    var nodePositionsWithLiveMove: [UUID: CGPoint] {
        if let snapshot = self.liveMoveNodesSnapshot {
            self.nodes.reduce(
                into: [:],
                { acc, el in
                    let pos = snapshot[el.key] ?? self.nodes[el.key]!.position
                    acc[el.key] = pos
                }
            )
        } else {
            self.nodePositions
        }
    }

    @discardableResult
    func moveNode(_ id: UUID, to position: CGPoint, undoManager um: UndoManager? = nil) -> CGPoint? {
        guard let prev = self.nodes[id]?.position else {
            return nil
        }

        if position != prev {
            self.nodes[id]!.position = position
            um?.registerUndo(
                withTarget: self,
                handler: { [weak um] this in
                    this.moveNode(id, to: prev, undoManager: um)
                }
            )
        }

        return prev
    }

    func liveMoveNodesStart(_ nodes: Set<UUID>) -> [UUID: CGPoint] {
        self.liveMoveNodesSnapshot = nodes.reduce(
            into: [:],
            { acc, id in
                if let pos = self.nodes[id]?.position {
                    acc[id] = pos
                }
            }
        )

        return self.liveMoveNodesSnapshot!
    }

    @discardableResult
    func liveMoveNodesUpdate(_ positions: [UUID: CGPoint]) -> [UUID: CGPoint] {
        guard let prev = self.liveMoveNodesSnapshot else {
            fatalError("called `liveMoveNodesEnd` before calling `liveMoveNodesStart` ")
        }

        self.liveMoveNodesSnapshot = positions.reduce(into: [:], {acc, item in
            if prev[item.key] != nil {
                acc[item.key] = item.value
            }
        })

        return prev
    }

    func liveMoveNodesEnd(undoManager um: UndoManager?) {
        guard let snap = self.liveMoveNodesSnapshot else {
            fatalError("called `liveMoveNodesEnd` before calling `liveMoveNodesStart` ")
        }

        um?.beginUndoGrouping()

        var didMoveNode: Bool = false

        for (id, pos) in snap {
            if self.hasNode(id) {
                if let _ = self.moveNode(id, to: pos, undoManager: um) {
                    didMoveNode = true
                }
            }
        }

        um?.endUndoGrouping()

        if !didMoveNode {
            um?.undoNestedGroup()
        }

        self.liveMoveNodesSnapshot = nil
    }

    func liveMoveNodesCancel() {
        self.liveMoveNodesSnapshot = nil
    }
}
