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

    var interactionMode: CanvasInteractionMode = .default

    lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(Self.tapGestureHandler(_:)))
        gesture.allowedTouchTypes = [
            NSNumber(value: UITouch.TouchType.direct.rawValue)
        ]
        gesture.delegate = self
        return gesture
    }()

    lazy var clickGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(Self.clickGestureHandler(_:)))
        gesture.allowedTouchTypes = [
            NSNumber(value: UITouch.TouchType.indirect.rawValue),
            NSNumber(value: UITouch.TouchType.indirectPointer.rawValue),
        ]
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
        gesture.delegate = self
        return gesture
    }()

     lazy var longpressGesture: UILongPressGestureRecognizer = {
         let gesture = UILongPressGestureRecognizer(target: self, action: #selector(Self.longpressHandler(_:)))
         gesture.numberOfTouchesRequired = 1
         gesture.delegate = self
         return gesture
     }()

    private lazy var tapGestureHandler:
        EitherCanvasOrNodeGestureHandle<
            CanvasGestureHandlerEither<
                TapCanvasGestureHandler,
                EmptyHandler,
                CanvasInteractionModeCondition,
            >,
            TapNodeGestureHandler,
            EitherCanvasOrNodeHitTestCondition<UITapGestureRecognizer>
        > = {
            .init(.init(left: .init(), right: .init()), .init())
        }()

    private lazy var clickGestureHandler:
        EitherCanvasOrNodeGestureHandle<
            MouseLeftClickCanvasGestureHandler,
            ClickNodeGestureHandler,
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
            CanvasGestureHandlerEither<
                InertialPanHandler,
                RectSelectGestureHandler,
                CanvasInteractionModeCondition
            >,
            NodeDragHandler,
            EitherCanvasOrNodeHitTestCondition<UIPanGestureRecognizer>
        > = {
            .init(.init(left: .init(sensitivity: 1.0), right: .init()), .init())
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

     private lazy var longPressGestureHandler:
         EitherCanvasOrNodeGestureHandle<
             LongPressGestureHandler,
             LongPressNodeGestureHandler,
             EitherCanvasOrNodeHitTestCondition<UILongPressGestureRecognizer>,
         > = {
             .init(.init(), .init())
         }()

    init(_ canvas: CanvasUIView) {
        self.canvas = canvas

        super.init()

        self.view.addGestureRecognizer(self.tapGesture)
        self.view.addGestureRecognizer(self.clickGesture)
        self.view.addGestureRecognizer(self.oneFingerPanGesture)
        self.view.addGestureRecognizer(self.twoFingerPanGesture)
        self.view.addGestureRecognizer(self.pinchGesture)
        self.view.addGestureRecognizer(self.mousePanGesture)
        self.view.addGestureRecognizer(self.trackpadScrollPanGesture)
        self.view.addGestureRecognizer(self.hoverGesture)
         self.view.addGestureRecognizer(self.longpressGesture)
    }

    func emit(_ event: CanvasPlatformView.Event) {
        self.canvas?.onEvent?(event)
    }

    @objc
    func tapGestureHandler(_ gesture: UITapGestureRecognizer) {
        self.tapGestureHandler.handle(gesture, self.canvas)
    }

    @objc
    func clickGestureHandler(_ gesture: UITapGestureRecognizer) {
        self.clickGestureHandler.handle(gesture, self.canvas)
    }

    @objc
    func oneFingerPanHandler(_ gesture: UIPanGestureRecognizer) {
        self.oneFingerPangestureHandler.handle(gesture, self.canvas)
    }

    @objc
    func twoFingerPanHandler(_ gesture: UIPanGestureRecognizer) {
        self.twoFingerPanHandler.handle(gesture, self.canvas)
    }

    @objc
    func pinchGestureHandler(_ gesture: UIPinchGestureRecognizer) {
        self.twoFingerPinchHandler.handle(gesture, self.canvas)
    }

    @objc
    func mousePanHandler(_ gesture: UIPanGestureRecognizer) {
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

    @objc
    func longpressHandler(_ gesture: UILongPressGestureRecognizer) {
        self.longPressGestureHandler.handle(gesture, canvas)
    }

    func startInteractiveSelection() {
        self.interactionMode = .interactiveSelection
    }

    func stopInteractiveSelection() {
        self.interactionMode = .default
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

    var target: EitherCanvasOrNodeTarget = .canvas

    mutating func handle(_ gesture: Gesture, _ canvas: CanvasUIView) {
        if gesture.state == .began || (gesture.state == .ended && gesture is UITapGestureRecognizer) {
            self.target = Condition.choose(gesture, canvas)
        }

        switch self.target {
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

    var target: CanvasGestureHandlerEither3Pick = .none

    init(a: A, b: B, c: C) {
        self.a = a
        self.b = b
        self.c = c
    }

    mutating func handle(_ gesture: Gesture, _ canvas: CanvasUIView) {
        if gesture.state == .began || (gesture.state == .ended && gesture is UITapGestureRecognizer) {
            self.target = Condition.choose(gesture, canvas)
        }

        switch self.target {
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
        if canvas.delegate?.canvasView(shouldShowNodeEditMenuAfterTap: nodeView.id) == true {
            if !canvas.gestureView.editMenuController.isPresenting {
                canvas.gestureView.editMenuController.showEditMenu(
                    .node(nodeView.id),
                    at: gesture.location(in: canvas.gestureView)
                )
            }
        } else {
            nodeView.emitClick()
        }
    }
}

@MainActor
struct ClickNodeGestureHandler: CanvasNodeGestureHandler {
    func handle(_ gesture: UITapGestureRecognizer, _ canvas: CanvasUIView, _ nodeView: any CanvasNodeView) {
        nodeView.emitClick()
    }
}

/// Handler for canvas tap gestures.
@MainActor
struct TapCanvasGestureHandler: CanvasGestureHandler {
    func handle(_ gesture: UITapGestureRecognizer, _ canvas: CanvasUIView) {
        if canvas.delegate?.canvasViewEditMenuShouldAppear() == true {
            canvas.gestureView.showCanvasEditMenu(gesture.location(in: canvas.gestureView))
        }

        canvas.onEvent?(.clickBackground)
    }
}

/// Handler for canvas tap gestures.
@MainActor
struct MouseLeftClickCanvasGestureHandler: CanvasGestureHandler {
    func handle(_ gesture: UITapGestureRecognizer, _ canvas: CanvasUIView) {
        //        guard canvas.interactionMode != .interactiveSelection else {
        //            return
        //        }

        canvas.onEvent?(.clickBackground)
    }
}

@MainActor
struct EmptyHandler<G: UIGestureRecognizer>: CanvasGestureHandler {
    func handle(_ gesture: G, _ canvas: CanvasUIView) {}
}

@MainActor
struct RectSelectGestureHandler: CanvasGestureHandler {

    var initialPos: CGPoint = .zero

    mutating func handle(
        _ state: UIGestureRecognizer.State,
        _ isShiftDown: Bool,
        _ location: CGPoint,
        _ translation: CGSize,
        _ canvas: CanvasUIView
    ) {

        let isAdditive = isShiftDown || canvas.interactionMode == .interactiveSelection

        if state == .began {
            self.initialPos = location
            canvas.rectSelectionView.animate(location)
            canvas.onEvent?(.rectSelect(.started(shiftDown: isAdditive)))
            return
        }

        if state == .ended || state == .cancelled || state == .failed {
            self.initialPos = .zero
            canvas.rectSelectionView.selectionRect = .zero
            canvas.onEvent?(.rectSelect(.ended))
            return
        }

        let localRect = CGRect(
            origin: self.initialPos,
            size: translation
        )

        let contentRect = canvas.contentView.convert(localRect, from: canvas.gestureView)

        canvas.rectSelectionView.selectionRect = localRect
        canvas.onEvent?(.rectSelect(.modified(shiftDown: isAdditive, rect: contentRect)))
    }

    mutating func handle(_ gesture: UIPanGestureRecognizer, _ canvas: CanvasUIView) {
        let location = gesture.location(in: canvas.gestureView)
        let translation = gesture.translation(in: canvas.gestureView).cgSize
        self.handle(gesture.state, gesture.modifierFlags.contains(.shift), location, translation, canvas)
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

    var enabled: Bool = true

    mutating func handle(_ gesture: Gesture, _ canvas: CanvasUIView) {
        if gesture.state == .began || (gesture.state == .ended && gesture is UITapGestureRecognizer) {
            self.enabled = Condition.condition(gesture, canvas)
        }

        if self.enabled {
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
struct LocationNotInAnyNodeCondition<G: UIGestureRecognizer>: ConditionalCanvasGestureHandlerCondition {
    static func condition(_ gesture: G, _ canvas: CanvasUIView) -> Bool {
        canvas.nodeHitTest(gesture.location(in: canvas)) == nil
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

@MainActor
private struct LongPressGestureHandler: CanvasGestureHandler {

    var rectHandler: RectSelectGestureHandler = .init()
    var start: CGPoint = .zero

    mutating func handle(_ gesture: UILongPressGestureRecognizer, _ canvas: CanvasUIView) {
        let location = gesture.location(in: canvas.gestureView)
        if gesture.state == .began {
            self.start = location
        }
        let translation = location - self.start
        self.rectHandler.handle(
            gesture.state,
            gesture.modifierFlags.contains(.shift),
            location,
            translation.cgSize,
            canvas
        )
    }
}

@MainActor
private struct LongPressNodeGestureHandler: CanvasNodeGestureHandler {
    func handle(_ gesture: UILongPressGestureRecognizer, _ canvas: CanvasUIView, _ nodeView: any CanvasNodeView) {
        //        if gesture.state == .began {
        //            canvas.gestureView.showNodeEditMenu(nodeView.id, gesture.location(in: canvas.gestureView))
        //        }
    }
}

@MainActor
struct CanvasGestureHandlerEither<Left, Right, Condition>: CanvasGestureHandler
where
    Left: CanvasGestureHandler,
    Right: CanvasGestureHandler,
    Left.Gesture == Right.Gesture,
    Condition: CanvasGestureHandlerEitherCondition,
    Condition.Gesture == Left.Gesture
{
    typealias Gesture = Left.Gesture

    var left: Left
    var right: Right
    var target: CanvasGestureHandlerEitherTarget = .left

    mutating func handle(_ gesture: Left.Gesture, _ canvas: CanvasUIView) {
        if gesture.state == .began || (gesture.state == .ended && gesture is UITapGestureRecognizer) {
            self.target = Condition.choose(gesture, canvas)
        }

        switch target {
        case .left:
            self.left.handle(gesture, canvas)
        case .right:
            self.right.handle(gesture, canvas)
        }
    }
}

enum CanvasGestureHandlerEitherTarget {
    case left
    case right
}

protocol CanvasGestureHandlerEitherCondition {
    associatedtype Gesture
    static func choose(_ gesture: Gesture, _ canvas: CanvasUIView) -> CanvasGestureHandlerEitherTarget
}

@MainActor
struct CanvasInteractionModeCondition<G: UIGestureRecognizer>: CanvasGestureHandlerEitherCondition {
    static func choose(_ gesture: G, _ canvas: CanvasUIView) -> CanvasGestureHandlerEitherTarget {
        switch canvas.interactionController.interactionMode {
        case .default: .left
        case .interactiveSelection: .right
        }
    }
}

@MainActor
struct MouseLeftClickCondition<G: UIGestureRecognizer>: CanvasGestureHandlerEitherCondition {
    static func choose(_ gesture: G, _ canvas: CanvasUIView) -> CanvasGestureHandlerEitherTarget {
        if gesture.buttonMask.rawValue == 1 {
            .left
        } else {
            .right
        }
    }
}

#endif
