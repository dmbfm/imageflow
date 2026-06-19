import ContextMenus
import Foundation
import XKit

@MainActor
protocol InspectorContext {
    var undoManager: UndoManager? { get }
    var nodeContextMenuProvider: (UUID) -> XMenu? { get }
}

struct InspectorFeatureControllerProxy: InspectorContext {

    weak var controller: InspectorFeatureController?

    init(_ controller: InspectorFeatureController) {
        self.controller = controller
    }

    @MainActor
    var undoManager: UndoManager? {
        self.controller?.undoManager
    }

    var nodeContextMenuProvider: (UUID) -> XMenu? {
        { id in
            guard let flow = self.controller?.flow else { return nil }
            return NodeContextMenu.make(flow, id, showSelectAll: false)
        }
    }
}
