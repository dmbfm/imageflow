#if canImport(UIKit)

import Helpers
import CoreGraphics
import Logging
import SwiftUI

public final class CanvasUIView: UIView {

    // MARK: - Public Properties

    public var viewport: CanvasView.Viewport {
        didSet {
            if self.viewport != oldValue {
                self.viewportDidChange()
            }
        }
    }

    public var nodePositions: [UUID: CGPoint] {
        didSet {
            if self.nodePositions != oldValue {
                self.nodePositionsDidChange(oldValue)
            }
        }
    }

    public var edgeLayers: [CanvasView.EdgeLayer] = [] {
        didSet {
            if self.edgeLayers != oldValue {
                self.edgeLayersDidChange()
            }
        }
    }

    public var configuration: CanvasView.Configuration = .default

    public var onEvent: ((Event) -> ())?

    public var viewForNode: (UUID) -> (any CanvasNodeView)?

    public internal(set) var nodeViews: [UUID: any CanvasNodeView] = [:]

    // MARK: - Private Properties

    private var scaleAtStartOfMagnification: CGFloat = 1.0
    private var startLoc: CGPoint = .zero
    private var oneFingerPanInitialPos: CGPoint = .zero
    private var canvasInertiaAnimator: CanvasInertiaAnimator = .init()
    private var panGesturePreviousTranslation: CGPoint = .zero
    private var pointerGestureDelegate: PointerPanGestureDelegate?
    private var pointerPosition: CGPoint?
    var canvasAnimator: CanvasAnimator?
    var cancellable: Set<AnyEventEmitterCancellable> = []

    // MARK: - Subviews

    lazy var gridView: CanvasGridView = {
        let view = CanvasGridView()
        view.setAutoresizingMask([.flexibleWidth, .flexibleHeight])
        return view
    }()

    lazy var contentView: CanvasContentView = {
        let view = CanvasContentView()
        return view
    }()

    private lazy var rectSelectionView: RectSelectionView = {
        let view = RectSelectionView()
        view.isUserInteractionEnabled = false
        view.setAutoresizingMask([.flexibleWidth, .flexibleHeight])
        return view
    }()

    // MARK: - Initializers

    public init(
        viewport: CanvasView.Viewport,
        nodePositions: [UUID: CGPoint],
        viewForNode: @escaping (UUID) -> (any CanvasNodeView)?,
    ) {
        self.viewport = viewport
        self.nodePositions = nodePositions
        self.viewForNode = viewForNode

        super.init(frame: .zero)

        self.canvasAnimator = .init(self)
        self.canvasInertiaAnimator.canvas = self
        self.autoresizesSubviews = true
        self.clipsToBounds = true

        self.setupGridView()
        self.setupRectSelectionView()
        self.setupContentView()

        self.nodePositionsDidChange([:])
        self.gridViewDraw()

        let gesture = UIHoverGestureRecognizer(target: self, action: #selector(Self.onHover(_:)))
        self.addGestureRecognizer(gesture)

        self.contextMenuInteraction = .init(delegate: self)
        self.addInteraction(self.contextMenuInteraction)
    }

    var contextMenuInteraction: UIContextMenuInteraction!

    public weak var contextMenuProvider: (any PositionedContextMenuProvider)?

    @objc
    func onHover(_ gesture: UIHoverGestureRecognizer) {
        let pos = gesture.location(in: self)
        if gesture.state == .changed || gesture.state == .began {
            self.pointerPosition = pos
            self.onEvent?(.pointerMoved(positionInView: pos))
        } else {
            self.pointerPosition = nil
            self.onEvent?(.pointerMoved(positionInView: nil))
        }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        nil
    }

    // MARK: - UIView

    public override func didMoveToSuperview() {
        self.onEvent?(.didMoveToSuperview)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.updateContentView()
    }

    // MARK: - GridView Methods

    func setupGridView() {
        self.gridView.frame = self.bounds
        self.addSubview(self.gridView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Self.tapGestureHandler))
        self.gridView.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(Self.gridViewPanGesture(_:)))
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        panGesture.delegate = self
        self.gridView.addGestureRecognizer(panGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(Self.gridViewPinchGesture(_:)))
        pinchGesture.delegate = self
        self.gridView.addGestureRecognizer(pinchGesture)

        let oneFingerPanGesture = UIPanGestureRecognizer(target: self, action: #selector(Self.gridViewPanGesture(_:)))
        oneFingerPanGesture.minimumNumberOfTouches = 1
        oneFingerPanGesture.maximumNumberOfTouches = 1
        oneFingerPanGesture.allowedTouchTypes = [
            NSNumber(value: UITouch.TouchType.direct.rawValue)
        ]
        self.gridView.addGestureRecognizer(oneFingerPanGesture)

        let mouseDragGesture = UIPanGestureRecognizer(target: self, action: #selector(Self.mouseDragGestureHandler(_:)))
        mouseDragGesture.allowedScrollTypesMask = .discrete
        mouseDragGesture.allowedTouchTypes = [
            NSNumber(value: UITouch.TouchType.indirectPointer.rawValue)
        ]
        self.addGestureRecognizer(mouseDragGesture)

        let trackpadScrollGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(Self.trackpadScollGestureHandler(_:))
        )
        trackpadScrollGesture.allowedScrollTypesMask = .continuous
        trackpadScrollGesture.allowedTouchTypes = [
            NSNumber(value: UITouch.TouchType.indirectPointer.rawValue)
        ]
        self.addGestureRecognizer(trackpadScrollGesture)

        let pointerGestureDelegate = PointerPanGestureDelegate(mouseDragGesture, trackpadScrollGesture)
        self.pointerGestureDelegate = pointerGestureDelegate
        mouseDragGesture.delegate = pointerGestureDelegate
        trackpadScrollGesture.delegate = pointerGestureDelegate

    }

    @objc
    func trackpadScollGestureHandler(_ gesture: UIPanGestureRecognizer) {
        if gesture.buttonMask.rawValue == 0 {
            self.panHandler(gesture, view: self, sensitivity: 0.28)
        }
    }

    func panHandler(_ gesture: UIPanGestureRecognizer, view: UIView, sensitivity: CGFloat = 1.0) {
        if gesture.state == .began {
            self.panGesturePreviousTranslation = .zero
            self.canvasInertiaAnimator.velocity = .zero
        }

        let t = gesture.translation(in: view) * sensitivity
        let delta = t - panGesturePreviousTranslation
        self.viewport.translate(by: delta.cgSize * -1.0, in: .screen)
        self.panGesturePreviousTranslation = t

        if gesture.state == .ended {
            self.canvasInertiaAnimator.velocity = -gesture.velocity(in: view) * sensitivity
        }
    }

    @objc
    func tapGestureHandler() {
        self.onEvent?(.clickBackground)
    }

    func mousePrimaryDragGestureHandler(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            self.oneFingerPanInitialPos = gesture.location(in: self)
            self.onEvent?(.rectSelect(.started(shiftDown: false)))
            return
        }

        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            self.oneFingerPanInitialPos = .zero
            self.rectSelectionView.selectionRect = .zero
            self.onEvent?(.rectSelect(.ended))
            return
        }

        let localRect = CGRect(
            origin: self.oneFingerPanInitialPos,
            size: gesture.translation(in: self).cgSize
        )

        let contentRect = self.contentView.convert(localRect, from: self)

        self.rectSelectionView.selectionRect = localRect
        self.onEvent?(.rectSelect(.modified(shiftDown: false, rect: contentRect)))
    }

    func mouseMiddleDragGestureHandler(_ gesture: UIPanGestureRecognizer) {
        let t = gesture.translation(in: nil)
        self.viewport.translate(by: t.cgSize * -1.0, in: .screen)
        gesture.setTranslation(.zero, in: nil)
    }

    func mouseScrollGestureZoom(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state != .ended else {
            return
        }

        let s = self.configuration.scrollWheelSensitivity
        let newScale =
            if gesture.translation(in: self).y > 0 {
                self.configuration.clampZoom(self.viewport.scale + s)
            } else {
                self.configuration.clampZoom(self.viewport.scale - s)
            }

        let location = self.convert(gesture.location(in: nil), from: nil)
        if let pointerPosition = self.pointerPosition {
            self.viewport.zoom(newScale, atScreenPoint: pointerPosition)
        } else {
            self.viewport.zoom(newScale, atScreenPoint: location)
        }
    }

    @objc
    func mouseDragGestureHandler(_ gesture: UIPanGestureRecognizer) {
        switch gesture.buttonMask.rawValue {
        case 0:
            self.mouseScrollGestureZoom(gesture)
        case 1:
            if gesture.modifierFlags.contains(.alternate) {
                self.mouseMiddleDragGestureHandler(gesture)
            } else {
                self.mousePrimaryDragGestureHandler(gesture)
            }
        case 4:
            self.mouseMiddleDragGestureHandler(gesture)
        default:
            break
        }
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.canvasInertiaAnimator.velocity = .zero
        super.touchesBegan(touches, with: event)
    }

    @objc
    func gridViewPanGesture(_ gesture: UIPanGestureRecognizer) {
        self.panHandler(gesture, view: self.gridView, sensitivity: 1.0)
    }

    @objc
    func gridViewPinchGesture(_ gesture: UIPinchGestureRecognizer) {

        if gesture.state == .began {
            self.scaleAtStartOfMagnification = self.viewport.scale
            self.startLoc = gesture.location(in: self.gridView)
        }

        let scale = gesture.scale
        let newZoom = self.scaleAtStartOfMagnification * scale
        self.viewport.zoom(self.configuration.clampZoom(newZoom), atScreenPoint: self.startLoc)
    }

    func gridViewDraw() {
        self.gridView.draw(viewport: self.viewport, edges: self.edgeLayers)
    }

    // MARK: - ContentView Methods

    func setupContentView() {
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
    }

    func updateContentView() {
        self.contentView.transform = self.viewport.transform(from: .canvas, to: .screen)
    }

    // MARK: - RectSelectionView Methods

    func setupRectSelectionView() {
        self.rectSelectionView.bounds = self.frame
        self.addSubview(self.rectSelectionView)
    }
}

private final class RectSelectionView: UIView {
    var selectionRect: CGRect = .zero {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func draw(_ rect: CGRect) {
        UIColor.systemOrange.withAlphaComponent(0.2).setFill()
        UIColor.systemOrange.setStroke()
        let path = UIBezierPath(rect: self.selectionRect)
        path.fill()
        path.lineWidth = 1.0
        path.stroke()
    }

}

extension CanvasUIView: UIContextMenuInteractionDelegate {
    public func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        let loc = self.convert(interaction.location(in: nil), from: nil)
        return .init(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { _ in
                self.contextMenuProvider?.canvasContextMenu(at: loc)
            }
        )
    }
}

extension CanvasUIView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        let gestures = [gestureRecognizer, otherGestureRecognizer]
        if gestures.contains(where: { $0 is UIPanGestureRecognizer })
            && gestures.contains(where: { $0 is UIPinchGestureRecognizer })
        {
            return true
        }

        return false
    }
}

class PointerPanGestureDelegate: NSObject, UIGestureRecognizerDelegate {

    weak var a: UIGestureRecognizer?
    weak var b: UIGestureRecognizer?

    init(_ a: UIGestureRecognizer, _ b: UIGestureRecognizer) {
        self.a = a
        self.b = b
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if let a = self.a, let b = self.b {
            return (gestureRecognizer === a || gestureRecognizer === b)
                && (otherGestureRecognizer === a || otherGestureRecognizer === b)
        }

        return false
    }
}

#endif
