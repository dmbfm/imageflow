#if canImport(AppKit)

import CoreGraphicsEx
import CoreImage
import Foundation
import XViewKit
import AppKit

// MARK: - CIImageScrollNSView

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

    // MARK: - Public Properties

    /// An optional listener for `Event`s.
    public var onEvent: ((Event) -> ())?
    /// An optional cache to store/restore the viewport state according to the given `id`.
    public var cache: (any CIImageScrollViewCache)?
    /// If true the view is currently in the middle of a zoom animation.
    public var isAnimating: Bool = false
    /// A `String` identifier used for caching the viewport state via the supplied `cache` store.
    public var id: String {
        willSet { self.willSetId(newValue) }
        didSet { self.didSetId(oldValue) }
    }

    /// The image currently being displayed.
    public var image: CIImage? {
        get { self.getImage() }
        set { self.setImage(newValue) }
    }

    /// The current zoom scale.
    public var zoom: CGFloat {
        self.scrollView.magnification
    }

    // MARK: - Private Properties

    /// The configuration prameters for this view.
    var configuration: Configuration
    /// The previous zoom value. Used to check if we need to send a `zoomChanged` event or not when
    /// the clip view bounds is modified.
    var lastZoom: CGFloat?
    // State-machine that handles viewport restoration logic.
    var viewportRestoreState: ViewportRestoreState

    // MARK: - Public Properties: Subviews

    /// The view that displayes the image. It should have the same size as the scrollView and placed behind it. Will
    /// draw only the part of the image that is visible.
    public lazy var imageView: CIImageXView = {
        let view = CIImageXView(frame: self.bounds)
        view.placement = .manual(scale: .init(width: 1, height: 1), offset: .zero)
        return view
    }()

    /// This is the view used as the `NSSCrollView`'s `documentView`. It is only a transparent view so we can see the actual
    /// `imageView` behind it `NSScrollView`.
    public lazy var documentView: NSView = {
        let view = NSView()
        return view
    }()

    /// The actual `NSScrollView` that is used for scrolling. It has a `clipView` that is made to be the same size as
    /// the image to be displayed, and a `documentView` which is transparent. The idea is that we synchronize the
    /// viewport of the `scrollView` (i.e., the magnification and clipView origin) to the `CIImageXView` positioning,
    /// so that the correct portion of the image is drawn on the screen.
    public lazy var scrollView: NSScrollView = {
        // Create a `NSScrollView` with no background, and with both horizontal and vertical scrollers.
        let view = NSScrollView(frame: self.bounds)
        view.hasHorizontalScroller = true
        view.hasVerticalScroller = true
        view.drawsBackground = false
        view.backgroundColor = .clear

        // Create an instance of `ClipView` and set it as the `clipView`
        let clipView = ClipView(frame: self.bounds)
        clipView.allowedTouchTypes = [.indirect, .direct]
        view.contentView = clipView
        view.contentView.postsBoundsChangedNotifications = true
        view.contentView.drawsBackground = false
        view.contentView.backgroundColor = .clear

        // Set the document view
        view.documentView = self.documentView

        // Configure the magnification
        view.minMagnification = self.configuration.zoomRange.lowerBound
        view.maxMagnification = self.configuration.zoomRange.upperBound
        view.allowsMagnification = true

        // If we enable panning the scroll view with the mouse, add a gesture
        // recognizer
        if case let .enabled(button, modifiers: _) = self.configuration.mousePan {
            let panGR = NSPanGestureRecognizer(target: self, action: #selector(Self.clipViewPanGestureHandler(_:)))
            panGR.buttonMask = button.rawValue
            clipView.addGestureRecognizer(panGR)
            panGR.delegate = self
        }

        // Listen for events from the clipView
        clipView.onEvent = { [weak self] event in self?.clipViewEvent(event) }

        // Listen for clipView bounds did change notifications
        NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: view.contentView,
            queue: .main,
            using: { notification in
                MainActor.assumeIsolated { self.clipViewBoundsDidChange() }
            }
        )

        return view
    }()

    // MARK: - Initialization

    required public init(
        frame: CGRect,
        id: String = "",
        configuration: Configuration = .init(),
        cache: (any CIImageScrollViewCache)? = nil
    ) {
        self.configuration = configuration
        self.cache = cache
        self.id = id
        self.viewportRestoreState = .init(configuration)

        super.init(frame: frame)

        self.addSubview(self.imageView)
        self.addSubview(self.scrollView)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    // MARK: - NSView

    public override var frame: NSRect {
        didSet { self.viewportStateInput(.frameDidSet) }
    }

    public override func setBoundsSize(_ newSize: NSSize) {
        super.setBoundsSize(newSize)
        self.dispatch(.zoomToFit(animate: false))
    }

    public override func doLayout() {
        self.scrollView.frame = self.bounds
        self.imageView.frame = self.bounds

        self.viewportStateInput(.layoutOrImageChange(id: self.id, self.cache))
    }

    public override func viewWillMove(toSuperview newSuperview: NSView?) {
        guard newSuperview == nil else { return }
        self.cacheSave()
    }

    // MARK: - Properties-related

    private func getImage() -> CIImage? {
        self.imageView.image
    }

    private func setImage(_ newValue: CIImage?) {
        let isDifferentSize = self.image?.extent.size != newValue?.extent.size

        self.imageView.image = newValue

        if isDifferentSize {
            self.scrollView.documentView?.frame.size = self.imageView.imageLogicalSize
            self.needsLayout = true
        }
    }

    // MARK: - ClipView

    private func clipViewEvent(_ event: ClipView.Event) {
        switch event {
        case .scrollWheel(pos: let pos, let dy):
            self.scrollMouse(pos, dy)
        case let .trackpadScroll(pos, dx, dy):
            self.scrollTrackpad(pos, dx, dy)
        }
    }

    /// This is always called when the clip view of the scroll view has its
    /// bounds modified, which happens whenever the scorll view scrolls or is zoomed
    /// in/out, i.e., always that the scroll view's viewport changes.
    private func clipViewBoundsDidChange() {
        // Keep the image placement in the `CIImageView` in sync with the current scrolling/magnification.
        self.imageView.placement.updateManual { scale, offset in
            let newScale = CGSize(width: self.scrollView.magnification, height: self.scrollView.magnification)
            let newOffset =
                self.imageView.convertToPixel(-self.scrollView.contentView.bounds.origin)
                * self.scrollView.magnification

            return (newScale, newOffset)
        }

        // Check if we need to emit a `zoomDidChange` event.
        if !self.isAnimating {
            if self.lastZoom != self.zoom {
                self.onEvent?(.zoomDidChange(self.zoom))
                self.lastZoom = self.zoom
            }
        }
    }

    // MARK: - Interaction

    @objc private func clipViewPanGestureHandler(_ gesture: NSPanGestureRecognizer) {
        let view = self.scrollView.contentView
        let t = gesture.translation(in: view)
        view.bounds.origin -= t
        gesture.setTranslation(.zero, in: nil)
    }

    private func scrollMouse(_ pos: CGPoint, _ dy: CGFloat) {
        if case let .enabled(sensitivity) = self.configuration.scrollWheelZoom {
            self.scrollView.setMagnification(
                self.scrollView.magnification * (1.0 + sensitivity * 0.1 * dy),
                centeredAt: pos
            )
        }
    }

    private func scrollTrackpad(_ pos: CGPoint, _ dx: CGFloat, _ dy: CGFloat) {
        let view = self.scrollView.contentView
        view.bounds.origin -= .init(x: dx / self.zoom, y: dy / self.zoom)
    }

    // MARK: - Cache
    // MARK: - Zoom

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

    // MARK: - Action Dispacth

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

    // MARK: - Other Private Methods

    func cacheRestore(_ entry: CIImageScrollView.CacheEntry) {
        self.scrollView.magnification = entry.scale
        self.scrollView.contentView.setBoundsOrigin(entry.position)
    }

    func cacheEntry() -> CIImageScrollView.CacheEntry {
        .init(
            position: self.scrollView.contentView.bounds.origin,
            scale: self.scrollView.magnification
        )
    }
}

// MARK: - CIImageScrollXView + NSGestureRecognizerDelegate

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

// MARK: - ClipView

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

// MARK:- Helpers

extension NSEvent {
    fileprivate func isMouseScrollEvent(touchCount: Int) -> Bool {
        !self.isTrackpadScrollEvent(touchCount: touchCount)
    }
    fileprivate func isTrackpadScrollEvent(touchCount: Int) -> Bool {
        (touchCount > 0 || self.momentumPhase != []) && self.subtype != .mouseEvent
    }
}

#endif
