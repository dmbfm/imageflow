import CoreImage
import Foundation
import Helpers
import SwiftUI

public protocol GlobalCoordinatorImpl: AnyObject, Observable {
    var emitter: EventEmitter<GlobalCoordinatorEvent> { get }
    var nodeSelectionCount: Int { get }
    var canPaste: Bool { get }

    var undoManager: UndoManager? { get set }
    var pointerData: PointerData? { get set }
    var available: ComponentAvailability { get }

    var previewIsDocked: Bool { get }
    var previewHasImage: Bool { get }
    var previewPositionBinding: Binding<PreviewPosition?> { get }
    var previewPinnedBinding: Binding<Bool> { get }

    func perform(userAction: UserAction)

    init(flow: Flow)
}

public struct ComponentAvailability: Equatable {
    public var preview: Bool = false
    public var windowPreview: Bool = false

    public init(preview: Bool = false, windowPreview: Bool = false) {
        self.preview = preview
        self.windowPreview = windowPreview
    }
}

public enum ComponentName {
    case previewFeature
    case windowPreviewFeature
}

public struct PointerData {
    public var positionInCanvasView: CGPoint
    public var positionInCanvas: CGPoint

    public init(positionInCanvasView: CGPoint, positionInCanvas: CGPoint) {
        self.positionInCanvasView = positionInCanvasView
        self.positionInCanvas = positionInCanvas
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

public enum UserAction {
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

    public enum PreviewAction {
        case zoomIn
        case zoomOut
        case zoomToFit
        case actualSize
        case openWindow
    }
}

public enum GlobalCoordinatorEvent {
    case dummy
}

@Observable
@MainActor
public class GlobalCoordinator: GlobalCoordinatorImpl {
    public var available: ComponentAvailability {
        self.impl.available
    }

    public var emitter: Helpers.EventEmitter<GlobalCoordinatorEvent> {
        self.impl.emitter
    }

    public var nodeSelectionCount: Int {
        self.impl.nodeSelectionCount
    }

    public var canPaste: Bool {
        self.impl.canPaste
    }

    public var pointerData: PointerData? {
        get {
            self.impl.pointerData
        }

        set {
            self.impl.pointerData = newValue
        }
    }

    public required init(flow: Flow) {
        fatalError("Unavailable")
    }

    var impl: any GlobalCoordinatorImpl

    public var undoManager: UndoManager? {
        get {
            self.impl.undoManager
        }

        set {
            self.impl.undoManager = newValue
        }
    }

    public init(_ impl: any GlobalCoordinatorImpl) {
        self.impl = impl
    }

    public func perform(userAction: UserAction) {
        self.impl.perform(userAction: userAction)
    }

    public var previewIsDocked: Bool {
        self.impl.previewIsDocked
    }

    public var previewPositionBinding: Binding<PreviewPosition?> {
        self.impl.previewPositionBinding
    }

    public var previewPinnedBinding: Binding<Bool> {
        self.impl.previewPinnedBinding
    }

    public var previewHasImage: Bool {
        self.impl.previewHasImage
    }

    public var implementation: any GlobalCoordinatorImpl {
        self.impl
    }
}
