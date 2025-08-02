import EventEmitter
import PlatformUtils

#if canImport(AppKit)
import AppKit
import AppKitUtils
#endif

#if canImport(UIKit)
import UIKit
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
    case dragGesture(CanvasNodeDragGesture)
    case click
    case sizeChanged
    case other(E)
}

public struct CanvasNodeDragGesture: Sendable, Equatable {
    public var phase: GesturePhase
    public var dx: CGFloat
    public var dy: CGFloat

    public init(phase: GesturePhase, dx: CGFloat, dy: CGFloat) {
        self.phase = phase
        self.dx = dx
        self.dy = dy
    }
}

public class ColorNodeView: PlatformView, CanvasNodeView {

    public var id: UUID = UUID()
    public var emitter: EventEmitter<CanvasNodeEvent<()>> = .init()
    public var size: CGSize

    lazy var backgroundDragView: PlatformView = {
        #if os(macOS)
        let view = DragTapPlatformView()
        view.frame = self.bounds
        view.wantsLayer = true
        view.layer?.backgroundColor = .clear
        view.layer?.cornerRadius = 10.0
        view.autoresizingMask = [.width, .height]
        view.onTapGesture = { [weak self] in self?.emitter.emit(.click) }
        view.onDragGesture = { [weak self] (phase, dx, dy) in
            self?.emitter.emit(.dragGesture(.init(phase:  phase, dx: dx, dy: dy)))
        }
        view.clipsToBounds = false
        return view
        #endif

        #if os(iOS)
        let view = DragTapPlatformView()
        view.frame = self.bounds
        view.setAutoresizingMask([.flexibleWidth, .flexibleHeight])
        view.onDragGesture = { [weak self] phase, dx, dy in
            self?.emitter.emit(.dragGesture(.init(phase: phase, dx: dx, dy: dy)))
        }
        return view
        #endif
    }()

    public init(id: UUID, size: CGSize, color: CGColor) {
        self.id = id
        self.size = size

        super.init(frame: .zero)
        
        self.autoresizesSubviews = true

        self.addSubview(self.backgroundDragView)

        #if os(macOS)
        self.shadow = .init()
        self.wantsLayer = true
        self.layer?.backgroundColor = color
        self.layer?.cornerRadius = 10
        self.layer?.shadowRadius = 10
        #endif
        
        #if os(iOS)
        self.backgroundColor = UIColor(cgColor: color)
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.25
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        #endif
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        nil
    }

    public override var intrinsicContentSize: CGSize {
        self.size
    }
}

