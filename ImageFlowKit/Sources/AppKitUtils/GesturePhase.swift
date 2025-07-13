import AppKit

public enum GesturePhase: Hashable, Sendable {
    case began
    case changed
    case ended
    case cancelled

    public init(nsGestureRecognizerState state: NSGestureRecognizer.State) {
        self =
            switch state {
            case .began: .began
            case .changed: .changed
            case .ended: .ended
            default:
                .cancelled
            }
    }
}

extension NSGestureRecognizer.State: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .possible: "possible"
        case .began: "began"
        case .changed: "changed"
        case .ended: "ended"
        case .cancelled: "cancelled"
        case .failed: "failed"
        @unknown default: ""
        }
    }
}

public enum GestureHandlerResponse: Hashable, Sendable {
    case cancel
    case ok
}
