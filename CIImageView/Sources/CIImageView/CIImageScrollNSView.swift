import AppKit
import CoreImage

public class CIImageScrollNSView: NSView {
    public var image: CIImage? {
        get {
            self.imageView.image
        }

        set {
            self.imageView.image = newValue
            self.imageView.sizeToFit()
            self.imageView.updateDrawableSize()
            if self.scrollView.documentView != self.imageView {
                self.scrollView.documentView = self.imageView
            }
        }
    }

    public var zoomDidChange: ((CGFloat) -> ())? {
        didSet {
            self.zoomDidChange?(self.scrollView.magnification)
        }
    }

    public lazy var imageView: CIImageNSView = {
        let view = CIImageNSView(frame: self.bounds)
        return view
    }()

    public lazy var scrollView: NSScrollView = {
        let view = ScrollView()
        view.onScrollWheelEvent = { [weak self] event in self?.onScrollViewWheelEvent(event) }
        view.setFrameSize(self.bounds.size)
        view.autoresizingMask = [.width, .height]
        view.backgroundColor = .clear
        view.hasHorizontalScroller = true
        view.hasVerticalScroller = true
        view.contentView = self.clipView
        view.documentView = self.imageView
        view.allowsMagnification = true
        view.minMagnification = 0.001
        view.maxMagnification = 1000
        return view
    }()

    public lazy var clipView: NSClipView = {
        let view = ClipView()
        view.backgroundColor = NSColor(red: 0.588, green: 0.588, blue: 0.588, alpha: 1.0)
        return view
    }()

    private var isPanning: Bool = false {
        didSet {
            if self.isPanning != oldValue {
                self.window?.invalidateCursorRects(for: self)
            }
        }
    }

    public override init(frame: NSRect) {
        super.init(frame: frame)

        self.autoresizesSubviews = true

        self.addSubview(self.scrollView)

        NotificationCenter.default.addObserver(
            forName: NSScrollView.didEndLiveMagnifyNotification,
            object: self.scrollView,
            queue: .main
        ) { notification in
            Task { @MainActor in
                self.zoomDidChange?(self.scrollView.magnification)
            }
        }

        let panGesture = NSPanGestureRecognizer(target: self, action: #selector(self.panGestureHandler(_:)))
        panGesture.buttonMask = 1
        self.clipView.addGestureRecognizer(panGesture)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        nil
    }

    override public func resetCursorRects() {
        super.resetCursorRects()
        self.addCursorRect(self.bounds, cursor: self.isPanning ? .closedHand : .openHand)
    }

    public func zoom(_ value: CGFloat, animate: Bool = true) {
        self.zoomDidChange?(value)
        if animate {
            self.scrollView.animator().setMagnification(value, centeredAt: self.clipView.bounds.center)
        } else {
            self.scrollView.setMagnification(value, centeredAt: self.clipView.bounds.center)
        }
    }

    public func zoomToFit(_ animate: Bool = true) {
        if animate {
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.completionHandler = {
                    self.zoomDidChange?(self.scrollView.magnification)
                }
                self.scrollView.animator().magnify(toFit: self.imageView.bounds)
            }
        } else {
            self.scrollView.magnify(toFit: self.imageView.bounds)
            self.zoomDidChange?(self.scrollView.magnification)
        }
    }

    public func zoomActualSize(_ animate: Bool = true) {
        self.zoomDidChange?(1)

        if animate {
            self.scrollView.animator().setMagnification(1.0, centeredAt: self.clipView.bounds.center)
        } else {
            self.scrollView.setMagnification(1.0, centeredAt: self.clipView.bounds.center)
        }
    }

    private func onScrollViewWheelEvent(_ event: NSEvent) {
        let value = self.scrollView.magnification * (1 + event.deltaY / 100)
        self.scrollView.setMagnification(
            value,
            centeredAt: self.clipView.convert(event.locationInWindow, from: nil)
        )
        self.zoomDidChange?(self.scrollView.magnification)
    }

    @objc
    private func panGestureHandler(_ gesture: NSPanGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            self.isPanning = true
        default:
            self.isPanning = false
        }
        self.clipView.scroll(self.clipView.bounds.origin - gesture.translation(in: self.clipView))
        gesture.setTranslation(.zero, in: nil)
    }
}

extension CGRect {
    var center: CGPoint {
        .init(x: self.midX, y: self.midY)
    }
}

extension CGPoint {
    static func - (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

fileprivate class ScrollView: NSScrollView {
    var onScrollWheelEvent: ((NSEvent) -> ())?

    override func scrollWheel(with event: NSEvent) {
        if let onScrollWheelEvent = self.onScrollWheelEvent, event.subtype == .mouseEvent {
            onScrollWheelEvent(event)
        } else {
            super.scrollWheel(with: event)
        }
    }
}

fileprivate class ClipView: NSClipView {

    override var isFlipped: Bool {
        true
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
}
