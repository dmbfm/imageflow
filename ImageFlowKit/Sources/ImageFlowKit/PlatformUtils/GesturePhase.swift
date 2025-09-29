#if canImport(AppKit)
import AppKit

public typealias PlatformGestureRecognizerState = NSGestureRecognizer.State
#endif

#if canImport(UIKit)
import UIKit

public typealias PlatformGestureRecognizerState = UIGestureRecognizer.State
#endif

public enum GesturePhase: Hashable, Sendable {
    case began
    case changed
    case ended
    case cancelled

    public init(gestureRecognizerState state: PlatformGestureRecognizerState) {
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

extension PlatformGestureRecognizerState: @retroactive CustomStringConvertible {
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
