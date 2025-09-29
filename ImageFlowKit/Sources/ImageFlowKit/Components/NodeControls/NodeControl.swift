import Helpers
import SwiftUI
import Values

public protocol NodeControl: PlatformView {
    var tint: PlatformColor { get set }
    var value: Value { get set }
    var onEvent: ((NodeControlEvent) -> ())? { get set }
}

extension NodeControl {
    func emit(_ event: NodeControlEvent) {
        self.onEvent?(event)
    }
}

public enum NodeControlEvent {
    case valueDidChange(Value)
    case sizeDidChange
}
