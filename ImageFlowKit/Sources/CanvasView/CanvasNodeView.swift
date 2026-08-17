import Helpers
import XKit

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

@MainActor
public protocol CanvasNodeView: XView {
    associatedtype Event = ()
    var id: UUID { get }
    var level: Int { get set }
    var emitter: EventEmitter<CanvasNodeEvent<Event>> { get }
    func emitDragGesture(_ drag: CanvasNodeDragGesture)
    func emitClick()
}

public enum CanvasNodeEvent<E> {
    case dragGesture(CanvasNodeDragGesture)
    case click
    case sizeChanged
    case other(E)
    case keyboardWillShow(windowVerticalOverlap: CGFloat, duration: CGFloat)
}

// extension CanvasNodeEvent: CustomStringConvertible where E: CustomStringConvertible {
//     public var description: String {
//         // "\(self."
//     }
// }

public struct CanvasNodeDragGesture: Sendable, Equatable {
    public var phase: XGestureRecognizer.State
    public var dx: CGFloat
    public var dy: CGFloat
    public var t: CGPoint

    public init(phase: XGestureRecognizer.State, dx: CGFloat, dy: CGFloat, t: CGPoint) {
        self.phase = phase
        self.dx = dx
        self.dy = dy
        self.t = t
    }
}
