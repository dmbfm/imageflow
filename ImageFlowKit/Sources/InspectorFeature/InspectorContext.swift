import ContextMenus
import Foundation
import SharedModels
import XKit

@MainActor
protocol InspectorContext {
    var undoManager: UndoManager? { get }
    var coordinator: GlobalCoordinator? { get }
    var nodeContextMenuProvider: (UUID) -> XMenu? { get }
}

extension InspectorContext where Self == DummyInspectorContext {
    static var dummy: DummyInspectorContext { DummyInspectorContext() }
}

struct InspectorFeatureControllerProxy: InspectorContext {
    weak var controller: InspectorFeatureController?

    var coordinator: GlobalCoordinator? {
        self.controller?.coordinator
    }

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

struct DummyInspectorContext: InspectorContext {
    let coordinator: SharedModels.GlobalCoordinator? = nil

    let undoManager: UndoManager? = nil

    let nodeContextMenuProvider: (UUID) -> XKit.XMenu? = { _ in nil }
}
