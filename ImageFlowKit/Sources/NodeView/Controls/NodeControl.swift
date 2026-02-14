import Helpers
import SwiftUI
import Values

protocol NodeControl: PlatformView {
    var tint: PlatformColor { get set }
    var value: Value { get set }
    var onEvent: ((NodeControlEvent) -> ())? { get set }
    var isEditable: Bool { get set }
    var context: NodeControlContext { get set }
}

extension NodeControl {
    func emit(_ event: NodeControlEvent) {
        self.onEvent?(event)
    }

    // swiftlint:disable unused_setter_value
    var isEditable: Bool {
        get { true }
        set {}
    }

    func setValue(newValue: Value, oldValue: Value? = nil, registerUndo: Bool = false) {
        if registerUndo, let undo = self.context.undo {
            let old = oldValue ?? self.value
            if newValue != old {
                undo.register(old, newValue)
            }
        }

        if newValue != self.value {
            self.value = newValue
            self.emit(.valueDidChange(newValue))
        }
    }
}

public enum NodeControlEvent {
    case valueDidChange(Value)
    case sizeDidChange
    case keyboardWillShow(windowVerticalOverlap: CGFloat, duration: CGFloat)
}

public struct NodeControlContext {
    var undo: (any NodeControlUndoManager)? = nil
}

protocol NodeControlUndoManager {
    func register(_ oldValue: Value, _ newValue: Value)
}
