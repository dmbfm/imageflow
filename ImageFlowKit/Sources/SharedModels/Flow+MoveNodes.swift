import Foundation

extension Flow {
    public var nodePositionsWithLiveMove: [UUID: CGPoint] {
        if let snapshot = self.liveMoveNodesSnapshot {
            self.nodePositions.reduce(
                into: [:],
                { acc, el in
                    acc[el.key] = snapshot[el.key] ?? el.value
                }
            )
        } else {
            self.nodePositions
        }
    }

    @discardableResult
    public func moveNode(_ id: UUID, to position: CGPoint, undoService: UndoService? = nil) -> CGPoint? {
        guard let prev = self.nodePositions[id] else {
            return nil
        }

        if position != prev {
            self.nodePositions[id] = position
            undoService?.register(
                withTarget: self,
                title: nil,
                icon: nil,
                handler: { [weak undoService] this in
                    this.moveNode(id, to: prev, undoService: undoService)
                }
            )
            return prev
        }

        return nil
    }

    @discardableResult
    public func liveMoveNodesStart(_ nodes: Set<UUID>) -> [UUID: CGPoint] {
        self.liveMoveNodesSnapshot = nodes.reduce(
            into: [:],
            { acc, id in
                if let pos = self.nodePositions[id] {
                    acc[id] = pos
                }
            }
        )

        return self.liveMoveNodesSnapshot!
    }

    @discardableResult
    public func liveMoveNodesUpdate(
        _ positions: [UUID: CGPoint]
    ) -> [UUID: CGPoint] {
        guard let prev = self.liveMoveNodesSnapshot else {
            fatalError("called `liveMoveNodesEnd` before calling `liveMoveNodesStart` ")
        }

        self.liveMoveNodesSnapshot = positions.reduce(
            into: [:],
            { acc, item in
                if prev[item.key] != nil {
                    acc[item.key] = item.value
                }
            }
        )

        return prev
    }

    public func liveMoveNodesEnd(undoService: UndoService? = nil) {
        guard let snap = self.liveMoveNodesSnapshot else {
            fatalError("called `liveMoveNodesEnd` before calling `liveMoveNodesStart` ")
        }

        undoService?.beginUndoGrouping()

        var didMoveNode: Bool = false

        for (id, pos) in snap where self.hasNode(id) && self.moveNode(id, to: pos, undoService: undoService) != nil {
            didMoveNode = true
        }

        undoService?.endUndoGrouping()
        undoService?.setActionName("Move Node" + (snap.count > 1 ? "s" : ""), icon: .systemIconNode)

        if !didMoveNode {
            undoService?.undo()
        }

        self.liveMoveNodesSnapshot = nil
    }

    public func liveMoveNodesCancel() {
        self.liveMoveNodesSnapshot = nil
    }
}
