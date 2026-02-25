import Foundation
import Helpers
import SharedModels
import SwiftUI
import Values

@MainActor
@Observable
public class MockGlobalCoordinatorService: GlobalCoordinatorImpl {
    public func titleForAsset(id: AssetIdentifier?) -> String? {
        id.map({ _ in "Some Title" })
    }

    public var canZoomIn: Bool = false

    public var canZoomOut: Bool = false

    public var flow: SharedModels.Flow = .init()

    public var previewHasImage: Bool = false

    public var previewPositionBinding: Binding<SharedModels.PreviewPosition?> = .constant(PreviewPosition.bottomDock)

    public var previewPinnedBinding: Binding<Bool> = .constant(false)

    public var previewIsDocked: Bool { false }

    public var available: ComponentAvailability = .init()

    public var undoManager: UndoManager?

    public func isAvailable(_ name: SharedModels.ComponentName) -> Bool {
        false
    }

    public var emitter: EventEmitter<SharedModels.GlobalCoordinatorEvent> = .init()

    public var nodeSelectionCount: Int = 0

    public var canPaste: Bool = false

    public var pointerData: SharedModels.PointerData?

    public required init(flow: SharedModels.Flow) {
    }

    public func perform(userAction: UserAction) {

    }
}
