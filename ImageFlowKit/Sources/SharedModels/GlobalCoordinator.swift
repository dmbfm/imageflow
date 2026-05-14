import Backend
import CoreImage
import Foundation
import Helpers
import UniformTypeIdentifiers

public protocol GlobalCoordinatorProtocol: AnyObject {
    func perform(userAction: UserAction)
    func canZoomIn() -> Bool
    func canZoomOut() -> Bool
    func currentZoom() -> CGFloat
    func nodeCount() -> Int
    func selectedNodeCount() -> Int
    var emitter: EventEmitter<GlobalCoordinatorEvent> { get }
}

public enum GlobalCoordinatorEvent {
    case backendDidRun
}

@MainActor
public class GlobalCoordinator: GlobalCoordinatorProtocol {

    public var emitter: Helpers.EventEmitter<GlobalCoordinatorEvent> {
        self.impl?.emitter ?? self.dummy.emitter
    }

    private weak var impl: (any GlobalCoordinatorProtocol)?
    private var dummy = MockGlobalCoordinator()

    public init(_ impl: some GlobalCoordinatorProtocol) {
        self.impl = impl
    }

    public func perform(userAction: UserAction) {
        self.impl?.perform(userAction: userAction)
    }

    public func canZoomIn() -> Bool {
        self.impl?.canZoomIn() ?? self.dummy.canZoomIn()
    }

    public func canZoomOut() -> Bool {
        self.impl?.canZoomOut() ?? self.dummy.canZoomOut()
    }

    public func currentZoom() -> CGFloat {
        self.impl?.currentZoom() ?? self.dummy.currentZoom()
    }

    public func nodeCount() -> Int {
        self.impl?.nodeCount() ?? self.dummy.nodeCount()
    }

    public func selectedNodeCount() -> Int {
        self.impl?.selectedNodeCount() ?? self.dummy.selectedNodeCount()
    }

}

public enum UserAction {
    case delete(Target)
    case rename(UUID)
    case copy(Target)
    case cut(Target)
    case duplicate(Target)
    case deleteSelectedNodes
    case duplicateSelectedNodes
    case copySelectedNodes
    case cutSelectedNodes
    case selectNone
    case selectAllNodes
    case selectNodesInteractive
    case pasteNodes(Point?)
    case exportPreviewedImage
    case exportImage(image: CIImage, filename: String?)
    case exportImageForNode(UUID)
    case showNodeSearch(typedPortLocation: TypedPortLocation?, canvasPosition: CGPoint?)
    case preview(PreviewAction)
    case newNodeWithKind(kind: NodeKind, at: Point?)
    case newNode(FlowNode, at: Point?, connectingToExistingPort: TypedPortLocation?)
    case convertNode(UUID, NodeKind)
    case openAssetPicker(node: UUID, portIndex: Int, kind: AssetKind)
    case openAssetBrowser
    case viewport(ViewportAction)
    case disconnect(InputPortLocation)
    case openFileImporter([UTType])

    public enum Target {
        case selection
        case node(UUID)
    }

    public enum PreviewAction {
        case zoomIn
        case zoomOut
        case zoomToFit
        case actualSize
        case openWindow
    }

    public enum ViewportAction {
        case zoomIn
        case zoomOut
        case setZoom(CGFloat)
        case zoomToFitContent
        case zoomToFitSelection
    }
}

public enum Point {
    case canvas(CGPoint)
    case canvasView(CGPoint)
    case window(CGPoint)

    public var cgPoint: CGPoint {
        switch self {
        case .canvas(let p): p
        case .canvasView(let p): p
        case .window(let p): p
        }
    }
}

public class MockGlobalCoordinator: GlobalCoordinatorProtocol {
    public let emitter: Helpers.EventEmitter<GlobalCoordinatorEvent> = .init()

    public func perform(userAction: UserAction) {

    }

    public func canZoomIn() -> Bool {
        true
    }

    public func canZoomOut() -> Bool {
        true
    }

    public func currentZoom() -> CGFloat {
        1.0
    }

    public func nodeCount() -> Int {
        0
    }

    public func selectedNodeCount() -> Int {
        0
    }
}
