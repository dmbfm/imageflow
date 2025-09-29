import SwiftUI

@Observable
@MainActor
public final class CanvasFeatureState {

    public var viewport: CanvasViewport = .init()
    public var nodePositions: [UUID: CGPoint] = .init()

    @ObservationIgnored
    private var tempNodePositions: [UUID: CGPoint] = [:]

    public init(viewport: CanvasViewport = .init(), nodePositions: [UUID: CGPoint] = .init()) {
        self.viewport = viewport
        self.nodePositions = nodePositions
    }

    public func move(
        nodes: [UUID: CGPoint],
        previousOverride previous: [UUID: CGPoint]?,
        undoManager um: UndoManager? = nil,
        undoTitle: String? = "Move Nodes"
    ) throws(NodeNotFoundError) {
        um?.beginUndoGrouping()
        for (id, pos) in nodes {
            try self.move(node: id, to: pos, previousOverride: previous?[id], undoManager: um, undoTitle: nil)
        }
        um?.endUndoGrouping()
        if let undoTitle {
            um?.setActionName(undoTitle)
        }
    }

    public func move(
        node id: UUID,
        to position: CGPoint,
        previousOverride previous: CGPoint? = nil,
        undoManager um: UndoManager? = nil,
        undoTitle: String? = "Move Node"
    ) throws(NodeNotFoundError) {
        guard let current = self.nodePositions[id] else {
            throw .init(id: id)
        }

        let prev = previous ?? current
        self.nodePositions[id] = position

        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                try! this.move(node: id, to: prev, undoManager: um, undoTitle: undoTitle)
            }
        )

        if let undoTitle {
            um?.setActionName(undoTitle)
        }
    }

    public func addNode(
        _ id: UUID,
        at position: CGPoint,
        undoManager um: UndoManager? = nil,
        undoTitle: String? = "Create Node"
    ) throws(AddNodeError) {

        if self.nodePositions[id] != nil {
            throw .nodeAlreadyExists
        }

        self.nodePositions[id] = position

        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                do {
                    try this.removeNode(id, undoManager: um, undoTitle: undoTitle)
                } catch {
                    log("failed to undo: \(error)", level: .error)
                }
            }
        )

        if let undoTitle { um?.setActionName(undoTitle) }

    }

    public enum AddNodeError: Error {
        case nodeAlreadyExists
    }

    public func removeNode(
        _ id: UUID,
        undoManager um: UndoManager? = nil,
        undoTitle: String? = "Delete Node"
    ) throws(RemoveNodeError) {

        guard let pos = self.nodePositions.removeValue(forKey: id) else {
            throw .nodeNotFound
        }

        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                do {
                    try this.addNode(id, at: pos, undoManager: um, undoTitle: undoTitle)
                } catch {
                    log("failed to undo: \(error)", level: .error)
                }
            }
        )

        if let undoTitle { um?.setActionName(undoTitle) }

    }

    public enum RemoveNodeError: Error {
        case nodeNotFound
    }
}

extension CanvasFeatureState: Storable {
    public struct StorableData: Sendable, Codable, Equatable {
        public var viewport: CanvasViewport
        public var nodePositions: [UUID: CGPoint]

        public init(viewport: CanvasViewport = .init(), nodePositions: [UUID: CGPoint] = [:]) {
            self.viewport = viewport
            self.nodePositions = nodePositions
        }
    }

    public convenience init(_ store: StorableData) {
        self.init(viewport: store.viewport, nodePositions: store.nodePositions)
    }

    public func snapshot() -> StorableData {
        .init(viewport: self.viewport, nodePositions: self.nodePositions)
    }

    public func restore(_ snapshot: StorableData) {
        self.viewport = snapshot.viewport
        self.nodePositions = snapshot.nodePositions
    }
}
