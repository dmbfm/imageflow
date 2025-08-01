import EventEmitter
import PlatformUtils

#if canImport(AppKit)
import AppKit

public typealias PlatformView = NSView
#endif

#if canImport(UIKit)
import UIKit

public typealias PlatformView = UIView
#endif


@MainActor
public protocol CanvasNodeView: PlatformView {
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

public enum CanvasNodeEvent<E> {
    case dragGesture(DragGestureEvent)
    case click
    case sizeChanged
    case other(E)
}

extension CanvasNodeEvent {
    public struct DragGestureEvent: Sendable, Equatable {
        public var phase: GesturePhase
        public var dx: CGFloat
        public var dy: CGFloat
    }
}

