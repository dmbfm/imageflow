#if canImport(AppKit)

import CoreGraphicsEx
import CoreImage
import Foundation
import XViewKit
import AppKit

//   ┌──────────────────────┐
//   │ Metal view drawing   │
// ██│  image with same size│
// ██│  as Scroll View      │
// ██│            ┌─────────┴─────────────────────────────────┐
// ██│            │                                           │
// ██│          ██│                                           │
// ██│          ██│                                           │
// ██│          ██│                                           │
// ██└──────────██┤      Tranparent documentview              │
// ███████████████│                                           │
// ███████████████│            with same size as image        │
//              ██│                                           │
//              ██│                                           │
//              ██│                                           │
//              ██│                                           │
//              ██│                                           │
//              ██│                                           │
//              ██│                              ┌────────────┴────────┬┐
//              ██│                              │                     ││
//              ██│                            ██│                     ││
//              ██│                            ██│                     ││
//              ██│                            ██│       ScrollView    ││
//              ██└────────────────────────────██┤                     ││
//              █████████████████████████████████│                     ││
//              █████████████████████████████████│                     ││
//                                             ██│                     ││
//                                             ██└─────────────────────┴┘
//                                             ████████████████████████
//                                             ████████████████████████

public class CIImageScrollNSView: XCommonView, CIImageScrollXViewProtocol {

    public var image: CIImage? {
        get {
            self.imageView.image
        }

        set {
            let isDifferentSize = self.image?.extent.size != newValue?.extent.size

            print("isDifferentSize: \(isDifferentSize)")

            self.imageView.image = newValue

            if isDifferentSize || self.needsRestore {
                self.scrollView.documentView?.frame.size = self.imageView.imageLogicalSize
                self.needsLayout = true
            }
        }
    }

    public var id: String {
        willSet {
            if newValue != self.id {
                self.cacheSave()
            }
        }
        didSet {
            if self.id != oldValue {
                self.needsRestore = true
            }
        }
    }

    public var zoom: CGFloat {
        self.scrollView.magnification
    }

    public var onEvent: ((Event) -> ())?
    public var cache: (any CIImageScrollViewCache)?
    public var isAnimating: Bool = false

    private var configuration: Configuration
    private var needsRestore: Bool = true
    private var lastZoom: CGFloat?

    public lazy var imageView: CIImageXView = {
        let view = CIImageXView(frame: self.bounds)
        view.placement = .manual(scale: .init(width: 1, height: 1), offset: .zero)
        return view
    }()

    required public init(
        frame: CGRect,
        id: String = "",
        configuration: Configuration = .init(),
        cache: (any CIImageScrollViewCache)? = nil
    ) {
        self.configuration = configuration
        self.cache = cache
        self.id = id

        super.init(frame: frame)

        self.addSubview(self.imageView)
        self.addSubview(self.scrollView)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    public lazy var scrollView: NSScrollView = {
        let view = NSScrollView(frame: self.bounds)
        view.hasHorizontalScroller = true
        view.hasVerticalScroller = true
        view.drawsBackground = false
        view.backgroundColor = .clear
        let clipView = ClipView(frame: self.bounds)
        clipView.allowedTouchTypes = [.indirect, .direct]
        view.contentView = clipView
        view.contentView.postsBoundsChangedNotifications = true
        view.contentView.drawsBackground = false
        view.contentView.backgroundColor = .clear
        view.documentView = self.documentView
        view.minMagnification = self.configuration.zoomRange.lowerBound
        view.maxMagnification = self.configuration.zoomRange.upperBound
        view.allowsMagnification = true

        if case let .enabled(button, modifiers: _) = self.configuration.mousePan {
            let panGR = NSPanGestureRecognizer(target: self, action: #selector(Self.clipViewPanGestureHandler(_:)))
            panGR.buttonMask = button.rawValue
            clipView.addGestureRecognizer(panGR)
            panGR.delegate = self
        }

        clipView.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .scrollWheel(pos: let pos, dy: let dy):
                if case let .enabled(sensitivity) = self.configuration.scrollWheelZoom {
                    self.scrollView.setMagnification(
                        self.scrollView.magnification * (1.0 + sensitivity * 0.1 * dy),
                        centeredAt: pos
                    )
                }
            case let .trackpadScroll(pos, dx, dy):
                let view = self.scrollView.contentView
                view.bounds.origin -= .init(x: dx / self.zoom, y: dy / self.zoom)
            }
        }

        NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: view.contentView,
            queue: .main,
            using: { notification in
                MainActor.assumeIsolated {
                    self.imageView.placement.updateManual { scale, offset in
                        return (
                            .init(width: self.scrollView.magnification, height: self.scrollView.magnification),
                            self.imageView.convertToPixel(-view.contentView.bounds.origin)
                                * self.scrollView.magnification
                        )
                    }

                    if !self.isAnimating {
                        if self.lastZoom != self.zoom {
                            self.onEvent?(.zoomDidChange(self.zoom))
                            self.lastZoom = self.zoom
                        }
                    }
                }
            }
        )

        return view
    }()

    @objc func clipViewPanGestureHandler(_ gesture: NSPanGestureRecognizer) {
        let view = self.scrollView.contentView
        let t = gesture.translation(in: view)
        view.bounds.origin -= t
        gesture.setTranslation(.zero, in: nil)
    }

    public lazy var documentView: NSView = {
        let view = NSView()
        return view
    }()

    public override func doLayout() {
        self.scrollView.frame = self.bounds
        self.imageView.frame = self.bounds

        if needsRestore {
            if !self.cacheRestore() {
                switch self.configuration.initialViewport {
                case .fit: self.dispatch(.zoomToFit(animate: false))
                case .actualSize: self.dispatch(.actualSize(animate: false))
                case .centered(zoom: let zoom):
                    self.dispatch(.setZoom(value: 1, center: nil, animate: false))
                    self.dispatch(
                        .setZoom(value: zoom, center: self.image?.extent.center, animate: false)
                    )
                }
            }
            self.needsRestore = false
        }
    }

    public override func viewWillMove(toSuperview newSuperview: NSView?) {
        guard newSuperview == nil else { return }
        self.cacheSave()
    }

    func cacheSave() {
        self.cache?.set(
            id: self.id,
            value: .init(
                position: self.scrollView.contentView.bounds.origin,
                scale: self.scrollView.magnification
            )
        )
    }

    @discardableResult
    func cacheRestore() -> Bool {
        if let entry = self.cache?.get(id: self.id) {
            self.scrollView.magnification = entry.scale
            self.scrollView.contentView.setBoundsOrigin(entry.position)
            return true
        }

        return false
    }

    public func actualSize(_ animate: Bool = true) {
        self.setZoom(value: 1.0, centeredAt: nil, animate: animate)
    }

    public func zoomToFit(_ animate: Bool = true) {
        guard let content = self.scrollView.documentView?.frame.size, content.width > 0, content.height > 0 else {
            return
        }
        let bounds = self.bounds
        let scale = min(bounds.width / content.width, bounds.height / content.height)
        self.setZoom(value: scale, centeredAt: nil, animate: animate)
    }

    public func setZoom(value: CGFloat, centeredAt point: CGPoint?, animate: Bool = true) {

        if self.isAnimating { return }

        if abs(self.scrollView.magnification - value) < 0.01 { return }

        let point = point ?? self.scrollView.contentView.bounds.center
        if animate {
            self.isAnimating = true
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.timingFunction = .init(name: .easeInEaseOut)
                self.scrollView.animator().setMagnification(
                    value,
                    centeredAt: point
                )
            } completionHandler: {
                MainActor.assumeIsolated {
                    self.isAnimating = false
                    if self.lastZoom != self.zoom {
                        self.onEvent?(.zoomDidChange(self.zoom))
                        self.lastZoom = self.zoom
                    }
                }
            }
        } else {
            self.scrollView.setMagnification(
                value,
                centeredAt: point
            )
        }
    }
    public func zoomOut(_ animate: Bool = true) {
        let alpha = log2(self.zoom)
        let nextAlpha = ceil(alpha) - 1
        let zoom = pow(2.0, nextAlpha)
        if self.configuration.zoomRange.contains(zoom) {
            self.setZoom(value: zoom, centeredAt: nil, animate: animate)
        }
    }

    public func zoomIn(_ animate: Bool = true) {
        let alpha = log2(self.zoom)
        let nextAlpha = floor(alpha) + 1
        let zoom = pow(2.0, nextAlpha)
        if self.configuration.zoomRange.contains(zoom) {
            self.setZoom(value: zoom, centeredAt: nil, animate: animate)
        }
    }

    public func dispatch(_ action: Action) {
        switch action {
        case .zoomToFit(let animate):
            self.zoomToFit(animate)
        case .actualSize(let animate):
            self.actualSize(animate)
        case .zoomIn(let animate):
            self.zoomIn(animate)
        case .zoomOut(let animate):
            self.zoomOut(animate)
        case .setZoom(let value, let point, let animate):
            self.setZoom(value: value, centeredAt: point, animate: animate)
        }
    }
}

extension CIImageScrollXView: NSGestureRecognizerDelegate {
    public func gestureRecognizer(
        _ gestureRecognizer: NSGestureRecognizer,
        shouldAttemptToRecognizeWith event: NSEvent
    ) -> Bool {
        if let _ = gestureRecognizer as? NSPanGestureRecognizer {
            if case let .enabled(button: _, modifiers) = self.configuration.mousePan {
                if !event.modifierFlags.contains(modifiers.nsEventModifierFlags) {
                    return false
                }
            }
            return true
        } else {
            return true
        }
    }
}

private class ClipView: NSClipView {

    override var isFlipped: Bool { true }

    var onEvent: ((Event) -> ())?

    private var touchCount = 0

    enum Event {
        case scrollWheel(pos: CGPoint, dy: CGFloat)
        case trackpadScroll(pos: CGPoint, dx: CGFloat, dy: CGFloat)
    }

    override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
        var rect = super.constrainBoundsRect(proposedBounds)
        guard let doc = self.documentView?.frame else {
            return rect
        }

        if proposedBounds.size.width > doc.size.width {
            rect.origin.x = floor((doc.size.width - proposedBounds.size.width) / 2.0)
        }

        if proposedBounds.size.height > doc.size.height {
            rect.origin.y = floor((doc.size.height - proposedBounds.size.height) / 2.0)
        }

        return rect
    }

    override func touchesBegan(with event: NSEvent) {
        getTouchCount(with: event)
    }

    override func touchesEnded(with event: NSEvent) {
        getTouchCount(with: event)
    }

    override func touchesCancelled(with event: NSEvent) {
        getTouchCount(with: event)
    }

    private func getTouchCount(with event: NSEvent) {
        self.touchCount = 0
        for touch in event.allTouches() {
            if touch.phase != .cancelled && touch.phase != .ended {
                self.touchCount += 1
            }
        }
    }

    // TODO: Apply this fix to canvas
    override func scrollWheel(with event: NSEvent) {
        let pos = self.convert(event.locationInWindow, from: nil)

        if event.isTrackpadScrollEvent(touchCount: self.touchCount) {
            self.onEvent?(.trackpadScroll(pos: pos, dx: event.scrollingDeltaX, dy: event.scrollingDeltaY))
        } else {
            let dy =
                if event.hasPreciseScrollingDeltas {
                    event.scrollingDeltaY * 0.1
                } else {
                    event.scrollingDeltaY
                }
            self.onEvent?(.scrollWheel(pos: pos, dy: dy))
        }
    }
}

extension NSEvent {
    fileprivate func isMouseScrollEvent(touchCount: Int) -> Bool {
        !self.isTrackpadScrollEvent(touchCount: touchCount)
    }
    fileprivate func isTrackpadScrollEvent(touchCount: Int) -> Bool {
        (touchCount > 0 || self.momentumPhase != []) && self.subtype != .mouseEvent
    }
}

#endif
