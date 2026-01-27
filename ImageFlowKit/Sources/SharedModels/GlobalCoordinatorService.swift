import Foundation
import Helpers

public protocol GlobalCoordinatorService: AnyObject {
    var emitter: EventEmitter<GlobalCoordinatorEvent> { get }
    var nodeSelectionCount: Int { get }
    var canPaste: Bool { get }
    var pointerData: PointerData? { get set }
    init(flow: Flow)
}

public struct PointerData {
    public var positionInCanvasView: CGPoint
    public var positionInCanvas: CGPoint

    public init(positionInCanvasView: CGPoint, positionInCanvas: CGPoint) {
        self.positionInCanvasView = positionInCanvasView
        self.positionInCanvas = positionInCanvas
    }
}

public enum GlobalCoordinatorEvent {
    case deleteSelectedNodes
    case duplicateSelectedNodes
    case copySelectedNodes
    case cutSelectedNodes
    case selectAllNodes
    case pasteFlowNodes(CGPoint?)
    case showNodeSearch(typedPortLocation: TypedPortLocation?, canvasPosition: CGPoint?)
    case performPaste(FlowPasteboardData, CGPoint?)
}
