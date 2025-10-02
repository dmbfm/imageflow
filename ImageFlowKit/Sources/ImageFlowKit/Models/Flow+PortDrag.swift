import Foundation
import Logging

// MARK: - Port Dragging

extension Flow {

    struct DrawPortAsConnected: Equatable, Sendable {
        var port: PortLocation
        var value: Bool
    }

    enum PortDraggingState: Equatable {
        case idle
        case dragging(PortLocation, removedEdge: Edge? = nil)

        var isIdle: Bool {
            self == .idle
        }

        var isDragging: Bool {
            self != .idle
        }

        var port: PortLocation? {
            switch self {
            case .idle: nil
            case .dragging(let port, _): port
            }
        }

        var removedEdge: Edge? {
            switch self {
            case .idle: nil
            case .dragging(_, removedEdge: let edge): edge
            }
        }
    }

    func portDragStart(port: PortLocation) {
        precondition(self.portDraggingState == .idle)

        let isInput = port.slot.isInput
        let isConnected = self.getPortConnected(port)  // self.nodeDataStore.getPortConnected(port) == .success(true)

        if isInput && isConnected {
            guard let edgeToRemove = self.edges(ofPort: port).first else {  //self.nodeDataStore.edges(to: port).first else {
                log("Failed to get edge starting at \(port)", level: .error)
                return
            }

            self.deleteEdgeAction(edgeToRemove, undoManager: nil)
            self.portDraggingState = .dragging(port, removedEdge: edgeToRemove)
        } else {
            self.portDraggingState = .dragging(port)
        }

        self.drawPortAsConnected = .init(port: port, value: true)

        log("\(self.portDraggingState)")
    }

    func portDragUpdate(_ pointer: CGPoint, _ hoveredPort: PortLocation?) {
        precondition(self.portDraggingState.isDragging)
        self.partialEdge = .init(port: self.portDraggingState.port!, pointer: pointer)
        if let hoveredPort {
            if let edge = Edge(self.portDraggingState.port!, hoveredPort) {
                switch self.canCreateEdge(edge) {
                case .success:
                    self.partialEdge?.state = .canConnect
                case .failure(let reason):
                    log("\(reason)")
                    self.partialEdge?.state = .cantConnect
                }
            } else {
                self.partialEdge?.state = .cantConnect
            }
        } else {
            self.partialEdge?.state = .default
        }
    }

    func portDragEnd(_ pointer: CGPoint, undoManager um: UndoManager?) {
        precondition(self.portDraggingState.isDragging)
        self.drawPortAsConnected = .init(port: self.portDraggingState.port!, value: false)
        self.portDragStateRestore()
        self.portDraggingState = .idle
        self.partialEdge = nil
    }

    func portDragCancel() {
        precondition(self.portDraggingState.isDragging)
        self.drawPortAsConnected = .init(port: self.portDraggingState.port!, value: false)
        self.portDragStateRestore()
        self.portDraggingState = .idle
        self.partialEdge = nil
    }

    private func portDragStateRestore() {
        precondition(self.portDraggingState.isDragging)
        if let edge = self.portDraggingState.removedEdge {
            self.newEdgeAction(edge)
        }
        // switch self.portDraggingState.restoreData! {
        // case .nothing:
        //     break
        // case .connected:
        //     self.setNodePortConnected(self.portDraggingState.port!, false)
        // case .removedEdge(let edge):
        //     self.setNodePortConnected(self.portDraggingState.port!, false)
        //     self.newEdgeAction(edge)
        // }
    }

    // private func canDropPort(_ port: PortLocation) -> Result<(), CanDropPortError> {
    //     return .success(())
    // }

    // enum CanDropPortError: Error {
    //     case noPort
    //     case samePort
    //     case invalidEdge
    //     case createEdgeError(CanAddEdgeError)
    // }
}
