import Foundation
import Logging

// MARK: - Port Dragging

extension Flow {

    public var partialEdge: PartialEdge? {
        self.portDraggingState.dragging?.partialEdge
    }

    enum PortDraggingState: Equatable {
        case idle
        case dragging(Dragging)

        mutating func dragging(partialEdge: PartialEdge, removedEdge: Edge? = nil, edgeToCreate: Edge? = nil) {
            self = .dragging(
                .init(
                    partialEdge: partialEdge,
                    removedEdge: removedEdge,
                    edgeToCreate: edgeToCreate
                )
            )
        }

        struct Dragging: Equatable {
            var partialEdge: PartialEdge
            var removedEdge: Edge? = nil
            var edgeToCreate: Edge? = nil
        }

        var dragging: Dragging? {
            switch self {
            case .dragging(let dragging): dragging
            default: nil
            }
        }
    }

    func portDragStart(_ port: PortLocation, _ pointer: CGPoint) {
        precondition(self.portDraggingState == .idle)

        let isInput = port.slot.isInput
        let isConnected = self.getPortConnected(port)

        if isInput && isConnected {
            guard let edgeToRemove = self.edges(ofPort: port).first else {  //self.nodeDataStore.edges(to: port).first else {
                log("Failed to get edge starting at \(port)", level: .error)
                return
            }

            self.deleteEdgeAction(edgeToRemove, undoManager: nil)
            self.portDraggingState.dragging(partialEdge: .init(port: port, pointer: pointer), removedEdge: edgeToRemove)
        } else {
            self.portDraggingState.dragging(partialEdge: .init(port: port, pointer: pointer))
        }
    }

    func portDragUpdate(_ pointer: CGPoint, _ hoveredPort: PortLocation?) {

        guard case var .dragging(state) = self.portDraggingState else {
            fatalError("portDragUpdate: invalid 'idle' state")
        }

        state.partialEdge.pointer = pointer

        if let hoveredPort {
            if let edge = Edge(state.partialEdge.port, hoveredPort) {
                switch self.canCreateEdge(edge) {
                case .success:
                    state.partialEdge.state = .canConnect
                    state.edgeToCreate = edge
                case .failure(let reason):
                    log("\(reason)")
                    state.partialEdge.state = .cantConnect
                }
            } else {
                state.partialEdge.state = .cantConnect
            }
        } else {
            state.partialEdge.state = .default
        }

        self.portDraggingState = .dragging(state)
    }

    func portDragEnd(_ pointer: CGPoint, undoManager um: UndoManager?) {
        guard case let .dragging(state) = self.portDraggingState else {
            fatalError("portDragUpdate: invalid 'idle' state")
        }

        if let edge = state.edgeToCreate {
            self.newEdgeAction(edge, undoManager: um)
        } else if let edge = state.removedEdge {
            self.newEdgeAction(edge)
            self.deleteEdgeAction(edge, undoManager: um)
        }

        self.portDraggingState = .idle
    }

    func portDragCancel() {
        guard case let .dragging(state) = self.portDraggingState else {
            fatalError("portDragUpdate: invalid 'idle' state")
        }

        if let edge = state.removedEdge {
            self.newEdgeAction(edge)
        }

        self.portDraggingState = .idle
    }
}
