import Helpers
import SwiftUI
import Values

protocol NodeControl: PlatformView {
    var tint: PlatformColor { get set }
    var value: Value { get set }
    var onEvent: ((NodeControlEvent) -> ())? { get set }
    var isEditable: Bool { get set }
}

extension NodeControl {
    func emit(_ event: NodeControlEvent) {
        self.onEvent?(event)
    }

    var isEditable: Bool {
        get { true }
        set {}
    }
}

public enum NodeControlEvent {
    case valueDidChange(Value)
    case sizeDidChange
}
