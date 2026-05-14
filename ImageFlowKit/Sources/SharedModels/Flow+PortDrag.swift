import Foundation
import Helpers

// MARK: - PortDraggingState

extension Flow {
    public struct PortDragUpdateResult {
        public var partialEdge: PartialEdge
        public var error: CanCreateEdgeError?
    }
    /// A state machine that models the accessory state used when the user drags
    /// a port from a node with the intent of creating a new edge connection.
    enum PortDraggingState: Sendable, Equatable {
        /// We are waiting for the user to drag a port
        case idle
        /// The user has started dragging the given `port`. If we had to remove
        /// an existing edge (for instance, when dragging a connected input port), the
        /// removed edge is stored here so that it can be used later when the user cancels
        /// the action or to register an undo item.
        case startedDragging(port: PortLocation, removedEdge: Edge?)
        /// The user is currently dragging the `port`. We still store the
        /// `removedEdge`. If an edge can be created at the positino the user pointer is
        /// we store it in `edgeToCreate`. If a type-fix is necessary for the edge creation
        /// (see `Flow.TypeError.Fix`), we store that as well in `fix`.
        case dragging(
            port: PortLocation,
            removedEdge: Edge?,
            edgeToCreate: Edge?,
            fix: Flow.TypeError.Fix?
        )

        mutating func startDragging(port: PortLocation, removedEdge: Edge?) throws(TransitionError) {
            switch self {
            case .idle:
                self = .startedDragging(port: port, removedEdge: removedEdge)
            case .dragging, .startedDragging:
                throw .invalid
            }
        }

        mutating func dragging(
            _ pointer: CGPoint,
            hoveredPort: PortLocation?,
            canCreateEdge: (Edge) -> Result<(), Flow.CanCreateEdgeError>
        ) throws(TransitionError) -> PortDragUpdateResult {
            switch self {
            case .idle:
                throw .invalid

            case let .startedDragging(port: port, removedEdge: removedEdge):
                return doUpdate(port: port, removedEdge: removedEdge)

            case let .dragging(port: port, removedEdge: removedEdge, edgeToCreate: edgeToCreate, fix: fix):
                return doUpdate(port: port, removedEdge: removedEdge, edgeToCreate: edgeToCreate, fix: fix)
            }

            func doUpdate(
                port: PortLocation,
                removedEdge: Edge? = nil,
                edgeToCreate: Edge? = nil,
                fix: Flow.TypeError.Fix? = nil,
            ) -> PortDragUpdateResult {
                guard let hoveredPort else {
                    self = .dragging(port: port, removedEdge: removedEdge, edgeToCreate: nil, fix: nil)
                    return .init(partialEdge: .init(port: port, pointer: pointer, state: .default))
                }

                let edge: Edge
                switch Edge.fromPorts(port, hoveredPort) {
                case .failure(let err):
                    return .init(
                        partialEdge: .init(port: port, pointer: pointer, state: .cantConnect),
                        error: .edge(err)
                    )
                case .success(let e): edge = e
                }

                let canCreateEdge = canCreateEdge(edge)
                switch canCreateEdge {
                case .success:
                    self = .dragging(port: port, removedEdge: removedEdge, edgeToCreate: edge, fix: nil)
                    return .init(partialEdge: .init(port: port, pointer: pointer, state: .canConnect))
                case .failure(.typeError(.fixable(let fix))):
                    self = .dragging(port: port, removedEdge: removedEdge, edgeToCreate: edge, fix: fix)
                    return .init(
                        partialEdge: .init(port: port, pointer: pointer, state: .canConnect),
                        error: .typeError(.fixable(fix))
                    )
                case .failure(let err):
                    self = .dragging(port: port, removedEdge: removedEdge, edgeToCreate: nil, fix: nil)
                    return .init(
                        partialEdge: .init(port: port, pointer: pointer, state: .cantConnect),
                        error: err
                    )
                }
            }
        }

        mutating func endDragging() throws(TransitionError) -> EndDraggingResult {
            switch self {
            case .idle:
                throw .invalid
            case .startedDragging(port: let port, removedEdge: _):
                self = .idle
                return .init(port: port, edgeToCreate: nil, removedEdge: nil, fix: nil)
            case let .dragging(port: port, removedEdge: removedEdge, edgeToCreate: edgeToCreate, fix: fix):
                self = .idle
                return .init(port: port, edgeToCreate: edgeToCreate, removedEdge: removedEdge, fix: fix)
            }
        }

        struct EndDraggingResult {
            var port: PortLocation
            var edgeToCreate: Edge?
            var removedEdge: Edge?
            var fix: Flow.TypeError.Fix?
        }

        enum TransitionError: Error { case invalid }
    }
}

// MARK: - Flow + portDrag

extension Flow {
    public func portDragStart(_ port: PortLocation, _ pointer: CGPoint) {
        let isInput = port.slot.isInput
        let isConnected = self.getPortConnected(port)

        let removedEdge: Edge? =
            if isInput && isConnected {
                self.edges(ofPort: port).first
            } else {
                nil
            }

        if let edge = removedEdge {
            self.deleteEdgeAction(edge, undoManager: nil)
        }

        do {
            try self.portDraggingState.startDragging(port: port, removedEdge: removedEdge)
        } catch {
            logger.error("Failed to start port dragging: \(error)")

            self.portDraggingState = .idle
        }
    }

    @discardableResult
    public func portDragUpdate(_ pointer: CGPoint, _ hoveredPort: PortLocation?) -> Flow.PortDragUpdateResult? {
        do {
            let result = try self.portDraggingState.dragging(
                pointer,
                hoveredPort: hoveredPort,
                canCreateEdge: self.canCreateEdge(_:)
            )
            self.partialEdge = result.partialEdge

            return result

        } catch {
            logger.error("Failed to update port drag: \(error)")
            self.partialEdge = nil
            self.portDraggingState = .idle
        }

        return nil
    }

    public func portDragEnd(undoManager um: UndoManager?, position: CGPoint?, travelDistance: CGFloat) {
        do {
            let result = try self.portDraggingState.endDragging()

            um?.beginUndoGrouping()

            if let edge = result.removedEdge {
                self.newEdgeAction(edge)
                self.deleteEdgeAction(edge, undoManager: um)
            }

            if let edge = result.edgeToCreate {
                if let fix = result.fix {
                    self.newEdgeWithTypeErrorFixAction(edge, fix, undoManager: um)
                } else {
                    self.newEdgeAction(edge, undoManager: um)
                }
            }

            um?.endUndoGrouping()
            um?.setActionName("Create Edge")

            let cantConnect = self.partialEdge?.state == .cantConnect

            self.partialEdge = nil

            if result.edgeToCreate == nil,
                !(result.port.slot.isInput && result.removedEdge != nil),
                let portType = self.nodes[result.port.node]?[valueTypeAt: result.port.slot],
                !cantConnect
            {
                self.emitter.emit(
                    .didEndPortDragWithoutCreatingEdge(
                        typedPortLocation: .init(type: portType, port: result.port),
                        canvasPosition: position,
                        travelDistance: travelDistance
                    )
                )
            }

        } catch {
            logger.error("Failed to end port drag: \(error)")

            self.portDraggingState = .idle
            self.partialEdge = nil
        }
    }

    public func portDragCancel() {
        do {
            let result = try self.portDraggingState.endDragging()

            if let edge = result.removedEdge {
                self.newEdgeAction(edge)
            }

            self.partialEdge = nil

        } catch {
            logger.error("Failed to end port drag: \(error)")
        }
    }
}
