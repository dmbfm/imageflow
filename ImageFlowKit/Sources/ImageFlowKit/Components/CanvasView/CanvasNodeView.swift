import Helpers

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

@MainActor
protocol CanvasNodeView: PlatformView {
    associatedtype Event = ()
    var id: UUID { get }
    var level: Int { get }
    var emitter: EventEmitter<CanvasNodeEvent<Event>> { get }
}

extension CanvasNodeView {
    public var level: Int {
        0
    }
}

enum CanvasNodeEvent<E> {
    case dragGesture(CanvasNodeDragGesture)
    case click
    case sizeChanged
    case other(E)
}

struct CanvasNodeDragGesture: Sendable, Equatable {
    public var phase: GesturePhase
    public var dx: CGFloat
    public var dy: CGFloat

    public init(phase: GesturePhase, dx: CGFloat, dy: CGFloat) {
        self.phase = phase
        self.dx = dx
        self.dy = dy
    }
}
