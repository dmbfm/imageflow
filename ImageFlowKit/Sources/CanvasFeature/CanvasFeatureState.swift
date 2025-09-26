import Backend
import CanvasView
import CommonUtils
import Design
import Logging
import Models
import NodeDataStore
import NodeView
import SwiftUI
import SwiftUIUtils

@Observable
@MainActor
public final class CanvasFeatureState {

    public var viewport: CanvasViewport = .init()
    public var nodePositions: [UUID: CGPoint] = .init()

    public enum Action {
        case addNode(AddNode, ActionUndoData?)
        case removeNode(UUID, ActionUndoData?)
        case moveNode(MoveNode, ActionUndoData?)
        case moveNodes(ModeNodes, ActionUndoData?)

        public struct AddNode {
            public var id: UUID
            public var position: CGPoint
            public init(id: UUID, position: CGPoint) {
                self.id = id
                self.position = position
            }
        }

        public struct MoveNode {
            public var id: UUID
            public var position: CGPoint
            public var previousOverride: CGPoint? = nil

            public init(id: UUID, position: CGPoint, previousOverride: CGPoint? = nil) {
                self.id = id
                self.position = position
                self.previousOverride = previousOverride
            }

        }

        public struct ModeNodes {
            public var positions: [UUID: CGPoint]
            public var previousOverride: [UUID: CGPoint]? = nil

            public init(positions: [UUID: CGPoint], previousOverride: [UUID: CGPoint]? = nil) {
                self.positions = positions
                self.previousOverride = previousOverride
            }

        }
    }

    public init(viewport: CanvasViewport = .init(), nodePositions: [UUID: CGPoint] = .init()) {
        self.viewport = viewport
        self.nodePositions = nodePositions
    }

    public func perform(_ action: Action) throws {
        switch action {
        case let .moveNode(data, um):
            self.move(
                node: data.id,
                to: data.position,
                previousOverride: data.previousOverride,
                undoManager: um?.undoManager,
                undoTitle: um?.title
            )

        case let .moveNodes(moveNodes, um):
            self.move(
                nodes: moveNodes.positions,
                previousOverride: moveNodes.previousOverride,
                undoManager: um?.undoManager,
                undoTitle: um?.title
            )

        case let .addNode(addNode, um):
            try self.addNode(addNode.id, at: addNode.position, undoManager: um?.undoManager, undoTitle: um?.title)

        case let .removeNode(id, um):
            try self.removeNode(id, undoManager: um?.undoManager, undoTitle: um?.title)
        }
    }

    public func move(
        nodes: [UUID: CGPoint],
        previousOverride previous: [UUID: CGPoint]?,
        undoManager um: UndoManager? = nil,
        undoTitle: String? = "Mode Nodes"
    ) {
        um?.beginUndoGrouping()
        for (id, pos) in nodes {
            self.move(node: id, to: pos, previousOverride: previous?[id], undoManager: um, undoTitle: nil)
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
    ) {
        guard let current = self.nodePositions[id] else {
            log("Node \(id) not found!")
            return
        }

        let prev = previous ?? current
        self.nodePositions[id] = position

        um?.registerUndo(
            withTarget: self,
            handler: { [weak um] this in
                this.move(node: id, to: prev, undoManager: um, undoTitle: undoTitle)
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
        undoTitle: String? = "Create Node"
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
