import Backend
import Combine
import CoreImage
import Foundation
import Helpers
import UniformTypeIdentifiers
import Values

@MainActor
public protocol GlobalCoordinatorProtocol: AnyObject {
    func perform(userAction: UserAction)
    func canZoomIn() -> Bool
    func canZoomOut() -> Bool
    func currentZoom() -> CGFloat
    func nodeCount() -> Int
    func selectedNodeCount() -> Int
    func assetTitle(_ asset: UUID) -> String?
    func canvasNodeSnappingEnabled() -> Bool
    var undoService: UndoService { get }
    var emitter: EventEmitter<GlobalCoordinatorEvent> { get }
    var canvasViewportPublisher: AnyPublisher<CanvasViewportModel, Never> { get }
    var canvasBookmarksPublisher: AnyPublisher<CanvasBookmarks, Never> { get }
    var selectionPublisher: AnyPublisher<Set<UUID>, Never> { get }
    var nodeCountPublisher: AnyPublisher<Int, Never> { get }
    var canvasNodeSnappingEnabledPublisher: AnyPublisher<Bool, Never> { get }
}

public enum GlobalCoordinatorEvent {
    case backendDidRun
}

@MainActor
public class GlobalCoordinator: GlobalCoordinatorProtocol {
    public func canvasNodeSnappingEnabled() -> Bool {
        self.impl?.canvasNodeSnappingEnabled() ?? false
    }

    public var undoService: UndoService {
        self.impl?.undoService ?? .init(nil)
    }

    public var canvasNodeSnappingEnabledPublisher: AnyPublisher<Bool, Never> {
        self.impl?.canvasNodeSnappingEnabledPublisher ?? .init(PassthroughSubject())
    }

    public var canvasViewportPublisher: AnyPublisher<CanvasViewportModel, Never> {
        self.impl?.canvasViewportPublisher ?? .init(PassthroughSubject())
    }

    public var canvasBookmarksPublisher: AnyPublisher<CanvasBookmarks, Never> {
        self.impl?.canvasBookmarksPublisher ?? .init(PassthroughSubject())
    }

    public var selectionPublisher: AnyPublisher<Set<UUID>, Never> {
        self.impl?.selectionPublisher ?? .init(PassthroughSubject())
    }

    public var nodeCountPublisher: AnyPublisher<Int, Never> {
        self.impl?.nodeCountPublisher ?? .init(PassthroughSubject())
    }

    public func assetTitle(_ asset: UUID) -> String? {
        self.impl?.assetTitle(asset)
    }

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
    case selectNodesConnectedToPort(PortLocation)
    case pasteNodes([FlowPasteboardItem], Point?)
    case dropPasteImages(DropPasteImages)
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
    case setCanvasViewPort(CanvasViewportModel)
    case setCanvasNodeSnapping(Bool)
    case setNodeInputValue(port: InputPortLocation, newValue: Value, oldValue: Value?, undo: Bool)
    case restoreNodeInputDefaultValue(InputPortLocation)
    case createBookmark
    case removeBookmark(UUID)
    case renameBookmark(UUID, String)
    case statusBarMessage(String?)

    public enum Target {
        case selection
        case nodes(Set<UUID>)
    }

    public struct DropPasteImages {
        public var payload: Payload
        public var target: Target

        public init(payload: Payload, target: Target) {
            self.payload = payload
            self.target = target
        }

        public enum Payload {
            case url([URL])
            case data(DataPayload)

            public struct DataPayload {
                public var data: Data
                public var filename: String

                public init(data: Data, filename: String) {
                    self.data = data
                    self.filename = filename
                }
            }
        }

        public enum Target: Equatable {
            case canvas(Point?)
            case assetBrowser
        }
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
        case setZoom(CGFloat, anim: Bool)
        case zoomToFitContent
        case zoomToFitSelection
        case setOrigin(CGPoint)
    }
}

public enum Point: Equatable {
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
    public func canvasNodeSnappingEnabled() -> Bool {
        false
    }

    public let canvasNodeSnappingEnabledPublisher: AnyPublisher<Bool, Never> = .init(PassthroughSubject())

    public let selectionPublisher: AnyPublisher<Set<UUID>, Never> = .init(PassthroughSubject())

    public let nodeCountPublisher: AnyPublisher<Int, Never> = .init(PassthroughSubject())

    public var undoService: UndoService {
        .init(nil)
    }

    public var canvasViewportPublisher: AnyPublisher<CanvasViewportModel, Never> = .init(PassthroughSubject())

    public var canvasBookmarksPublisher: AnyPublisher<CanvasBookmarks, Never> = .init(PassthroughSubject())

    public func assetTitle(_ asset: UUID) -> String? {
        return nil
    }

    public init() {}
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
