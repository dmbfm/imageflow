#if os(iOS)

import Helpers
import Logging
import UIKit

/// Manages all the gesture recognizers for `CanvasUIView`, thus handling most of the user interaction in the canvas.
@MainActor
class CanvasInteractionController: NSObject {
    weak var canvas: CanvasUIView!

    var view: CanvasGestureView {
        self.canvas.gestureView
    }

    lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(Self.tapGestureHandler(_:)))
        gesture.delegate = self
        return gesture
    }()

    lazy var oneFingerPanGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(Self.oneFingerPanHandler(_:)))
        gesture.maximumNumberOfTouches = 1
        gesture.minimumNumberOfTouches = 1
        gesture.delegate = self
        return gesture
    }()

    lazy var twoFingerPanGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(Self.twoFingerPanHandler(_:)))
        gesture.minimumNumberOfTouches = 2
        gesture.maximumNumberOfTouches = 2
        gesture.delegate = self
        return gesture
    }()

    lazy var pinchGesture: UIPinchGestureRecognizer = {
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(Self.pinchGestureHandler(_:)))
        gesture.delegate = self
        return gesture
    }()

    lazy var mousePanGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(Self.mousePanHandler(_:)))
        gesture.allowedScrollTypesMask = .discrete
        gesture.allowedTouchTypes = [
            NSNumber(value: UITouch.TouchType.indirectPointer.rawValue)
        ]
        gesture.delegate = self
        return gesture
    }()

    lazy var trackpadScrollPanGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(Self.trackpadScrollPanHandler(_:)))
        gesture.allowedScrollTypesMask = .continuous
        gesture.allowedTouchTypes = [
            NSNumber(value: UITouch.TouchType.indirectPointer.rawValue)
        ]
        gesture.delegate = self
        return gesture
    }()

    lazy var hoverGesture: UIHoverGestureRecognizer = {
        let gesture = UIHoverGestureRecognizer(target: self, action: #selector(Self.hoverHandler(_:)))
        return gesture
    }()

    private lazy var tapGestureHandler:
        EitherCanvasOrNodeGestureHandle<
            TapCanvasGestureHandler,
            TapNodeGestureHandler,
            EitherCanvasOrNodeHitTestCondition<UITapGestureRecognizer>
        > = {
            .init(.init(), .init())
        }()

    private lazy var mousePanGestureHandler:
        CanvasGestureHandlerEither3<
            MouseScrollWheelZoomHandler,
            MouseViewportPanHandler,
            EitherCanvasOrNodeGestureHandle<
                RectSelectGestureHandler,
                NodeDragHandler,
                EitherCanvasOrNodeHitTestCondition<UIPanGestureRecognizer>
            >,
            MousePanHandlerCondition,
        > = {
            .init(a: .init(), b: .init(), c: .init(.init(), .init()))
        }()

    private lazy var oneFingerPangestureHandler:
        EitherCanvasOrNodeGestureHandle<
            InertialPanHandler,
            NodeDragHandler,
            EitherCanvasOrNodeHitTestCondition<UIPanGestureRecognizer>
        > = {
            .init(.init(sensitivity: 1.0), .init())
        }()

    private lazy var twoFingerPanHandler: InertialPanHandler = {
        .init(sensitivity: 1.0)
    }()

    private lazy var twoFingerPinchHandler: PinchGestureHandler = {
        .init()
    }()

    private lazy var trackpadScrollPanHandler:
        ConditionalCanvasGestureHandler<InertialPanHandler, ScrollButtonMaskCondition> = {
            .init(handler: .init(sensitivity: 0.25))
        }()

    private lazy var hoverGestureHandler: HoverHandler = {
        .init()
    }()

    init(_ canvas: CanvasUIView) {
        self.canvas = canvas

        super.init()

        self.view.addGestureRecognizer(self.tapGesture)
        self.view.addGestureRecognizer(self.oneFingerPanGesture)
        self.view.addGestureRecognizer(self.twoFingerPanGesture)
        self.view.addGestureRecognizer(self.pinchGesture)
        self.view.addGestureRecognizer(self.mousePanGesture)
        self.view.addGestureRecognizer(self.trackpadScrollPanGesture)
        self.view.addGestureRecognizer(self.hoverGesture)
    }

    func emit(_ event: CanvasPlatformView.Event) {
        self.canvas?.onEvent?(event)
    }

    @objc
    func tapGestureHandler(_ gesture: UITapGestureRecognizer) {
        self.tapGestureHandler.handle(gesture, self.canvas)
    }

    @objc
    func oneFingerPanHandler(_ gesture: UIPanGestureRecognizer) {
        log("oneFingerPanHandler")
        self.oneFingerPangestureHandler.handle(gesture, self.canvas)
    }

    @objc
    func twoFingerPanHandler(_ gesture: UIPanGestureRecognizer) {
        log("twoFingerPanHandler")
        self.twoFingerPanHandler.handle(gesture, self.canvas)
    }

    @objc
    func pinchGestureHandler(_ gesture: UIPinchGestureRecognizer) {
        log("pinchGestureHandler")
        self.twoFingerPinchHandler.handle(gesture, self.canvas)
    }

    @objc
    func mousePanHandler(_ gesture: UIPanGestureRecognizer) {
        log("mousePanHandler(:\(gesture.translation(in: self.canvas))")
        self.mousePanGestureHandler.handle(gesture, self.canvas)
    }

    @objc
    func trackpadScrollPanHandler(_ gesture: UIPanGestureRecognizer) {
        self.trackpadScrollPanHandler.handle(gesture, self.canvas)
    }

    @objc
    func hoverHandler(_ gesture: UIHoverGestureRecognizer) {
        self.hoverGestureHandler.handle(gesture, self.canvas)
    }
}

extension CanvasInteractionController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        let gs = [gestureRecognizer, otherGestureRecognizer]

        if gs.contains(self.mousePanGesture) && gs.contains(self.trackpadScrollPanGesture) {
            return true
        }

        if gs.contains(self.twoFingerPanGesture) && gs.contains(self.pinchGesture) {
            return true
        }

        return false
    }
}

/// Abstracts a handler for any type of `UIGestureRecognizer`s on a `CanvasUIView`.
protocol CanvasGestureHandler {
    associatedtype Gesture: UIGestureRecognizer
    mutating func handle(_ gesture: Gesture, _ canvas: CanvasUIView)
}

/// Abstracts a handler for any type of `UIGestureRecognizer`s on a `CanvasUIView` that
/// specifically target a node view.
protocol CanvasNodeGestureHandler {
    associatedtype Gesture: UIGestureRecognizer
    mutating func handle(_ gesture: Gesture, _ canvas: CanvasUIView, _ nodeView: any CanvasNodeView)
}

/// A `CanvasGestureHandler` that combines a given `CanvasGestureHandler` with a `CanvasNodeGestureHandler`
/// depending on a `Condition`.
@MainActor
struct EitherCanvasOrNodeGestureHandle<CanvasHandler, NodeHandler, Condition>: CanvasGestureHandler
where
    CanvasHandler: CanvasGestureHandler,
    NodeHandler: CanvasNodeGestureHandler,
    Condition: EitherCanvasOrNodeCondition,
    CanvasHandler.Gesture == NodeHandler.Gesture,
    Condition.Gesture == CanvasHandler.Gesture
{

    typealias Gesture = CanvasHandler.Gesture

    var left: CanvasHandler
    var right: NodeHandler

    init(
        _ left: CanvasHandler,
        _ right: NodeHandler,
    ) {
        self.left = left
        self.right = right
    }

    mutating func handle(_ gesture: Gesture, _ canvas: CanvasUIView) {
        switch Condition.choose(gesture, canvas) {
        case .canvas: self.left.handle(gesture, canvas)
        case .node(let view): self.right.handle(gesture, canvas, view)
        }
    }
}

/// Evaluates the condition whice resolves wich of either handlers in
/// `EitherCanvasOrNodeGestureHandle` is used to handle a gesture.
protocol EitherCanvasOrNodeCondition<Gesture> {
    associatedtype Gesture
    static func choose(_ gesture: Gesture, _ canvas: CanvasUIView) -> EitherCanvasOrNodeTarget
}

enum EitherCanvasOrNodeTarget {
    case canvas
    case node(any CanvasNodeView)
}

/// A `EitherCanvasOrNodeCondition` that picks `canvas` or `node` depending on hit-testing.
@MainActor
struct EitherCanvasOrNodeHitTestCondition<G: UIGestureRecognizer>: EitherCanvasOrNodeCondition {
    static func choose(_ gesture: G, _ canvas: CanvasUIView) -> EitherCanvasOrNodeTarget {
        let pos = canvas.pointerPosition ?? gesture.location(in: canvas.gestureView)
        if let id = canvas.nodeHitTest(pos),
            let nodeView = canvas.nodeViews[id]
        {
            return .node(nodeView)
        } else {
            return .canvas
        }
    }
}

/// Chooses between three different `CanvasGestureHandler`s depending on the given `Condition`.
@MainActor
struct CanvasGestureHandlerEither3<A, B, C, Condition>: CanvasGestureHandler
where
    A: CanvasGestureHandler,
    B: CanvasGestureHandler,
    C: CanvasGestureHandler,
    Condition: CanvasGestureHandlerEither3Condition,
    A.Gesture == B.Gesture,
    B.Gesture == C.Gesture,
    Condition.Gesture == A.Gesture
{
    typealias Gesture = A.Gesture

    var a: A
    var b: B
    var c: C

    init(a: A, b: B, c: C) {
        self.a = a
        self.b = b
        self.c = c
    }

    mutating func handle(_ gesture: Gesture, _ canvas: CanvasUIView) {
        switch Condition.choose(gesture, canvas) {
        case .a: self.a.handle(gesture, canvas)
        case .b: self.b.handle(gesture, canvas)
        case .c: self.c.handle(gesture, canvas)
        case .none: break
        }
    }
}

/// Used to choose which one of the three handlers is used in the `CanvasGestureHandlerEither3` handler.
protocol CanvasGestureHandlerEither3Condition {
    associatedtype Gesture
    static func choose(_ gesture: Gesture, _ canvas: CanvasUIView) -> CanvasGestureHandlerEither3Pick
}

enum CanvasGestureHandlerEither3Pick {
    case a
    case b
    case c
    case none
}

@MainActor
struct MousePanHandlerCondition: CanvasGestureHandlerEither3Condition {
    static func choose(_ gesture: UIPanGestureRecognizer, _ canvas: CanvasUIView) -> CanvasGestureHandlerEither3Pick {
        switch gesture.buttonMask.rawValue {
        // Mouse scroll wheel event
        case 0: .a
        // Left button w/ option key and Middle button
        case 1 where gesture.modifierFlags.contains(.alternate), 4: .b
        // Left button
        case 1: .c
        default: .none
        }
    }
}

/// A `CanvasGestureHandler` for mouse wheel zoom gestures.
@MainActor
struct MouseScrollWheelZoomHandler: CanvasGestureHandler {
    func handle(_ gesture: UIPanGestureRecognizer, _ canvas: CanvasUIView) {
        guard gesture.state != .ended else {
            return
        }

        let s = canvas.configuration.scrollWheelSensitivity
        let newScale =
            if gesture.translation(in: canvas.gestureView).y > 0 {
                canvas.configuration.clampZoom(canvas.viewport.scale + s)
            } else {
                canvas.configuration.clampZoom(canvas.viewport.scale - s)
            }

        let location = gesture.location(in: canvas.gestureView)
        if let pointerPosition = canvas.pointerPosition {
            canvas.viewport.zoom(newScale, atScreenPoint: pointerPosition)
        } else {
            canvas.viewport.zoom(newScale, atScreenPoint: location)
        }
    }
}

/// A `CanvasGestureHandler` for mouse pan gestures on the canvas viewport.
@MainActor
private struct MouseViewportPanHandler: CanvasGestureHandler {
    mutating func handle(_ gesture: UIPanGestureRecognizer, _ canvas: CanvasUIView) {
        let t = gesture.translation(in: nil)
        canvas.viewport.translate(by: t.cgSize * -1.0, in: .screen)
        gesture.setTranslation(.zero, in: nil)
    }
}

/// Handler for node tap gestures.
@MainActor
struct TapNodeGestureHandler: CanvasNodeGestureHandler {
    func handle(_ gesture: UITapGestureRecognizer, _ canvas: CanvasUIView, _ nodeView: any CanvasNodeView) {
        nodeView.emitClick()
    }
}

/// Handler for canvas tap gestures.
@MainActor
struct TapCanvasGestureHandler: CanvasGestureHandler {
    func handle(_ gesture: UITapGestureRecognizer, _ canvas: CanvasUIView) {
        canvas.onEvent?(.clickBackground)
    }
}

@MainActor
struct RectSelectGestureHandler: CanvasGestureHandler {

    var initialPos: CGPoint = .zero

    mutating func handle(_ gesture: UIPanGestureRecognizer, _ canvas: CanvasUIView) {
        if gesture.state == .began {
            self.initialPos = gesture.location(in: canvas.gestureView)
            canvas.onEvent?(.rectSelect(.started(shiftDown: false)))
            return
        }

        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            self.initialPos = .zero
            canvas.rectSelectionView.selectionRect = .zero
            canvas.onEvent?(.rectSelect(.ended))
            return
        }

        let localRect = CGRect(
            origin: self.initialPos,
            size: gesture.translation(in: canvas.gestureView).cgSize
        )

        let contentRect = canvas.contentView.convert(localRect, from: canvas.gestureView)

        canvas.rectSelectionView.selectionRect = localRect
        canvas.onEvent?(.rectSelect(.modified(shiftDown: false, rect: contentRect)))
    }
}

@MainActor
struct NodeDragHandler: CanvasNodeGestureHandler {
    func handle(_ gesture: UIPanGestureRecognizer, _ canvas: CanvasUIView, _ nodeView: any CanvasNodeView) {
        let t = gesture.translation(in: canvas.gestureView)
        nodeView.emitDragGesture(.init(phase: .init(gestureRecognizerState: gesture.state), dx: t.x, dy: t.y))
        gesture.setTranslation(.zero, in: nil)
    }
}

@MainActor
private struct InertialPanHandler: CanvasGestureHandler {

    var previousTranslation: CGPoint = .zero

    var sensitivity: CGFloat = 1.0

    init(sensitivity: CGFloat) {
        self.sensitivity = sensitivity
    }

    mutating func handle(_ gesture: UIPanGestureRecognizer, _ canvas: CanvasUIView) {

        let animator = canvas.canvasInertiaAnimator

        if gesture.state == .began {
            self.previousTranslation = .zero
            animator.velocity = .zero
        }

        let t = gesture.translation(in: canvas.gestureView) * self.sensitivity
        let delta = t - self.previousTranslation
        canvas.viewport.translate(by: delta.cgSize * -1.0, in: .screen)
        self.previousTranslation = t

        if gesture.state == .ended {
            animator.velocity = -gesture.velocity(in: canvas.gestureView) * sensitivity
        }
    }
}

@MainActor
private struct PinchGestureHandler: CanvasGestureHandler {

    var scaleAtStart: CGFloat = 1.0

    mutating func handle(_ gesture: UIPinchGestureRecognizer, _ canvas: CanvasUIView) {
        if gesture.state == .began {
            self.scaleAtStart = canvas.viewport.scale
        }

        let scale = gesture.scale
        let newZoom = self.scaleAtStart * scale
        canvas.viewport.zoom(
            canvas.configuration.clampZoom(newZoom),
            atScreenPoint: gesture.location(in: canvas.gestureView)
        )
    }
}

@MainActor
private struct ConditionalCanvasGestureHandler<Handler, Condition>: CanvasGestureHandler
where
    Handler: CanvasGestureHandler, Condition: ConditionalCanvasGestureHandlerCondition,
    Handler.Gesture == Condition.Gesture
{
    typealias Gesture = Handler.Gesture
    var handler: Handler

    init(handler: Handler) {
        self.handler = handler
    }

    mutating func handle(_ gesture: Gesture, _ canvas: CanvasUIView) {
        if Condition.condition(gesture, canvas) {
            self.handler.handle(gesture, canvas)
        }
    }

}

protocol ConditionalCanvasGestureHandlerCondition<Gesture> {
    associatedtype Gesture
    static func condition(_ gesture: Gesture, _ canvas: CanvasUIView) -> Bool
}

@MainActor
struct ScrollButtonMaskCondition<G: UIGestureRecognizer>: ConditionalCanvasGestureHandlerCondition {
    static func condition(_ gesture: G, _ canvas: CanvasUIView) -> Bool {
        gesture.buttonMask.rawValue == 0
    }
}

@MainActor
struct HoverHandler: CanvasGestureHandler {
    func handle(_ gesture: UIHoverGestureRecognizer, _ canvas: CanvasUIView) {
        let pos = gesture.location(in: canvas.gestureView)
        if gesture.state == .changed || gesture.state == .began {
            canvas.pointerPosition = pos
            canvas.onEvent?(.pointerMoved(positionInView: pos))
        } else {
            canvas.pointerPosition = nil
            canvas.onEvent?(.pointerMoved(positionInView: nil))
        }

    }
}
#endif
