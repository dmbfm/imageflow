import Helpers
import Logging
import SharedModels
import SwiftUI

@MainActor
@Observable
public final class GlobalCoordinator: GlobalCoordinatorService {

    public var nodeSelectionCount: Int {
        self.flow.selection.count
    }

    @ObservationIgnored
    public var emitter: EventEmitter<SharedModels.GlobalCoordinatorEvent> = .init()

    @ObservationIgnored
    let flow: Flow

    @ObservationIgnored
    var cancellables: Set<AnyEventEmitterCancellable> = []

    @ObservationIgnored
    var undoManager: UndoManager? = nil

    required public init(flow: SharedModels.Flow) {
        self.flow = flow

        self.flow.emitter.on({ [weak self] event in
            self?.onFlowEvent(event)
        }).store(in: &self.cancellables)

        self.emitter.on({ [weak self] event in
            self?.onEvent(event)
        }).store(in: &self.cancellables)
    }

    func onFlowEvent(_ event: FlowEvent) {
        switch event {
        case let .didEndPortDragWithoutCreatingEdge(typedPortLocation, canvasPosition):
            self.emitter.emit(
                .showNodeSearch(
                    typedPortLocation: typedPortLocation,
                    canvasPosition: canvasPosition
                )
            )
        default:
            break
        }
    }

    func onEvent(_ event: GlobalCoordinatorEvent) {
        log("onEvent: \(event)")

        switch event {
        case .duplicateSelectedNodes:
            self.flow.duplidateSelectedNodesAction(undoManager: self.undoManager)
        case .deleteSelectedNodes:
            self.flow.deleteSelectedNodesAction(undoManager: self.undoManager)
        default:
            break
        }
    }

}
