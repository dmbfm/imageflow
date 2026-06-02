import Values
import XKit

protocol NodeInputControlView: XView {
    var label: String { get set }
    var value: Value { get set }
    var connected: Bool { get set }
    var hasChanges: Bool { get set }
    var context: NodeInputControlContext? { get set }
}

enum NodeInputControlEvent {
    case valueDidChange(ValueChange)
    case portButtonClicked
    case restoreButtonClicked
}

struct ValueChange {
    var newValue: Value
    var oldValue: Value?
    var commit: Bool
}

@MainActor
struct NodeInputControlContext {
    var index: Int
    private weak var controller: NodeInspectorController?

    init(_ controller: NodeInspectorController, _ index: Int) {
        self.controller = controller
        self.index = index
    }

    func onEvent(_ event: NodeInputControlEvent) {
        self.controller?.onNodeInputControlEvent(self.index, event)
    }
}
