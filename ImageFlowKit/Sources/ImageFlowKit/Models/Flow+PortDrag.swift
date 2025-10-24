import Foundation
import Helpers
import Logging

// MARK: - Port Dragging

struct PortDragStateMachine {

    var state: State

    enum State {
        case idle
        case startedDragging(port: PortLocation, removedEdge: Edge?)
        case dragging(
            port: PortLocation,
            removedEdge: Edge?,
            edgeToCreate: Edge?,
            fix: Flow.TypeError.Fix?
        )
    }

    mutating func startDragging(port: PortLocation, removedEdge: Edge?) throws(TransitionError) {
        switch state {
        case .idle:
            break
        case .dragging, .startedDragging:
            throw .invalid
        }
    }

    mutating func dragging(
        _ pointer: CGPoint,
        hoveredPort: PortLocation?,
        canCreateEdge: (Edge) -> Result<(), Flow.CanAddEdgeError>
    ) throws(TransitionError) -> PartialEdge {
        switch self.state {
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
        ) -> PartialEdge {
            guard let hoveredPort else {
                self.state = .dragging(port: port, removedEdge: removedEdge, edgeToCreate: nil, fix: nil)
                return .init(port: port, pointer: pointer, state: .default)
            }

            guard let edge = Edge(port, hoveredPort) else {
                self.state = .dragging(port: port, removedEdge: removedEdge, edgeToCreate: nil, fix: nil)
                return .init(port: port, pointer: pointer, state: .cantConnect)
            }

            switch canCreateEdge(edge) {
            case .success:
                self.state = .dragging(port: port, removedEdge: removedEdge, edgeToCreate: edge, fix: nil)
                return .init(port: port, pointer: pointer, state: .canConnect)
            case .failure(.typeError(.fixable(let fix))):
                self.state = .dragging(port: port, removedEdge: removedEdge, edgeToCreate: edge, fix: fix)
                return .init(port: port, pointer: pointer, state: .canConnect)
            default:
                self.state = .dragging(port: port, removedEdge: removedEdge, edgeToCreate: nil, fix: nil)
                return .init(port: port, pointer: pointer, state: .cantConnect)
            }
        }
    }

    mutating func endDragging() throws(TransitionError) -> EndDraggingResult {
        switch self.state {
        case .idle:
            throw .invalid
        case .startedDragging:
            self.state = .idle
            return .init(edgeToCreate: nil, removedEdge: nil, fix: nil)
        case let .dragging(port: _, removedEdge: removedEdge, edgeToCreate: edgeToCreate, fix: fix):
            self.state = .idle
            return .init(edgeToCreate: edgeToCreate, removedEdge: removedEdge, fix: fix)
        }
    }

    struct EndDraggingResult {
        var edgeToCreate: Edge?
        var removedEdge: Edge?
        var fix: Flow.TypeError.Fix?
    }

    enum TransitionError: Error { case invalid }
}

// struct PortDrag {

//     var state: State = .idle

//     struct Dragging: With {
//         var port: PortLocation
//         var pointer: CGPoint?
//         var hoveredPort: PortLocation?
//         var removedEdge: Edge?
//         var edgeToCreate: Edge?
//         var fix: Flow.TypeError.Fix?

//         var partialEdgeState: PartialEdge.State {
//             if self.hoveredPort == nil {
//                 .default
//             } else {
//                 if self.edgeToCreate == nil {
//                     .cantConnect
//                 } else {
//                     .canConnect
//                 }
//             }
//         }

//         var partialEdge: PartialEdge? {
//             if let pointer {
//                 .init(port: self.port, pointer: pointer, state: self.partialEdgeState)
//             } else {
//                 nil
//             }
//         }
//     }

//     enum State {
//         case idle
//         case dragging(Dragging)
//     }

//     enum Transition {
//         case startDraggingOutputPort(PortLocation)
//         case startDraggingEmptyInputPort(PortLocation)
//         case startDraggingConnectedInputPort(PortLocation, removedEdge: Edge)
//         case updateDrag(
//             pointer: CGPoint,
//             hoveredPort: PortLocation?,
//             canCreateEdge: (Edge) -> Result<(), Flow.CanAddEdgeError>
//         )
//         case endDrag
//     }

//     mutating func transition(_ transition: Transition) throws(TransitionError) {
//         switch state {
//         case .idle:
//             switch transition {
//             case .startDraggingOutputPort(let port):
//                 self.state = .dragging(.init(port: port))
//             case .startDraggingEmptyInputPort(let port):
//                 self.state = .dragging(.init(port: port))
//             case .startDraggingConnectedInputPort(let port, let removedEdge):
//                 self.state = .dragging(.init(port: port, removedEdge: removedEdge))
//             case .updateDrag, .endDrag:
//                 throw .invalid
//             }
//         case .dragging(let dragging):
//             switch transition {
//             case .startDraggingConnectedInputPort, .startDraggingEmptyInputPort, .startDraggingOutputPort:
//                 throw .invalid
//             case let .updateDrag(pointer: pointer, hoveredPort: hoveredPort, canCreateEdge: canCreateEdge):
//                 guard let hoveredPort else {
//                     self.state = .dragging(
//                         .init(
//                             port: dragging.port,
//                             pointer: pointer,
//                             hoveredPort: hoveredPort,
//                             removedEdge: dragging.removedEdge,
//                             edgeToCreate: nil,
//                             fix: nil
//                         )
//                     )
//                     break
//                 }

//                 guard let edge = Edge(dragging.port, hoveredPort) else {
//                     self.state = .dragging(
//                         .init(
//                             port: dragging.port,
//                             pointer: pointer,
//                             hoveredPort: hoveredPort,
//                             removedEdge: dragging.removedEdge,
//                             edgeToCreate: nil,
//                             fix: nil
//                         )
//                     )
//                     break
//                 }

//                 switch canCreateEdge(edge) {
//                 case .success:
//                     self.state = .dragging(
//                         .init(
//                             port: dragging.port,
//                             pointer: pointer,
//                             hoveredPort: hoveredPort,
//                             removedEdge: dragging.removedEdge,
//                             edgeToCreate: edge,
//                             fix: nil
//                         )
//                     )
//                 case .failure(.typeError(.fixable(let fix))):
//                     self.state = .dragging(
//                         .init(
//                             port: dragging.port,
//                             pointer: pointer,
//                             hoveredPort: hoveredPort,
//                             removedEdge: dragging.removedEdge,
//                             edgeToCreate: edge,
//                             fix: fix
//                         )
//                     )
//                 default:
//                     self.state = .dragging(
//                         .init(
//                             port: dragging.port,
//                             pointer: pointer,
//                             hoveredPort: hoveredPort,
//                             removedEdge: dragging.removedEdge,
//                             edgeToCreate: nil,
//                             fix: nil
//                         )
//                     )
//                 }
//             case .endDrag:

//                 break
//             }
//         }
//     }

//     enum TransitionError: Error {
//         case invalid
//     }
// }

extension Flow {

    public var partialEdge: PartialEdge? {
        self.portDraggingState.dragging?.partialEdge
    }

    enum PortDraggingState: Equatable {
        case idle
        case dragging(Dragging)

        struct Dragging: Equatable, With {
            var removedEdge: Edge? = nil
            var partialEdge: PartialEdge
            var state: State

            enum State: Equatable {
                case noPort
                case cantConnect
                case canConnect(Edge)
                case canConnectWithFix(Edge, Flow.TypeError.Fix)
            }
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
            self.portDraggingState = .dragging(
                .init(removedEdge: edgeToRemove, partialEdge: .init(port: port, pointer: pointer), state: .noPort)
            )
        } else {
            self.portDraggingState = .dragging(
                .init(removedEdge: nil, partialEdge: .init(port: port, pointer: pointer), state: .noPort)
            )
        }
    }

    func portDragUpdate(_ pointer: CGPoint, _ hoveredPort: PortLocation?) {

        guard case let .dragging(currentState) = self.portDraggingState else {
            fatalError("portDragUpdate: invalid 'idle' state")
        }

        var newState = {
            guard let hoveredPort else {
                return currentState.with(\.state, .noPort)
            }

            guard let edge = Edge(currentState.partialEdge.port, hoveredPort) else {
                return currentState.with(\.state, .cantConnect)
            }

            return switch self.canCreateEdge(edge) {
            case .failure(let reason):
                switch reason {
                case .typeError(.fixable(let fix)):
                    currentState.with(\.state, .canConnectWithFix(edge, fix))
                default:
                    currentState.with(\.state, .cantConnect)
                }
            case .success:
                currentState.with(\.state, .canConnect(edge))
            }
        }()

        newState.partialEdge.pointer = pointer
        newState.partialEdge.state =
            switch newState.state {
            case .noPort: .default
            case .canConnect, .canConnectWithFix: .canConnect
            case .cantConnect: .cantConnect
            }

        self.portDraggingState = .dragging(newState)
    }

    func portDragEnd(_ pointer: CGPoint, undoManager um: UndoManager?) {
        switch self.portDraggingState {
        case .idle:
            break
        case .dragging(let dragging):
            switch dragging.state {
            case .noPort, .cantConnect:
                if let edge = dragging.removedEdge {
                    self.newEdgeAction(edge)
                    self.deleteEdgeAction(edge, undoManager: um)
                }
            case .canConnect(let edge):
                self.newEdgeAction(edge, undoManager: um)
            case .canConnectWithFix(let edge, let fix):
                self.newEdgeWithTypeErrorFixAction(edge, fix, undoManager: um)
            }
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
