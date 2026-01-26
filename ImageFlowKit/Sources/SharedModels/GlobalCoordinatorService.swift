import Foundation
import Helpers

public protocol GlobalCoordinatorService: AnyObject {
    var emitter: EventEmitter<GlobalCoordinatorEvent> { get }
    var nodeSelectionCount: Int { get }
    init(flow: Flow)
}

public enum GlobalCoordinatorEvent {
    case deleteSelectedNodes
    case duplicateSelectedNodes
    case showNodeSearch(typedPortLocation: TypedPortLocation?, canvasPosition: CGPoint?)
}
