#if canImport(AppKit)
import AppKit
import SwiftUI
import ColorUtils
import Design

public final class CanvasAppKitView: NSView {

    // MARK: - Public Properties

    public var viewport: CanvasViewport {
        didSet {
            self.viewportDidChange()
        }
    }

    public let configuration: CanvasConfiguration

    public var onEvent: ((Event) -> ())?

    // MARK: - Private Properties

    private var scaleAtStartOfMagnification: CGFloat = 1.0
    private var leftPanInitialPos: CGPoint?

    // MARK: - Subviews

    private lazy var gridView: GridView = {
        let view = GridView()
        view.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .scroll(let event):
                self.gridView(didScrollWith: event)
            default:
                break
            }
        }
        view.autoresizingMask = [.width, .height]
        return view
    }()

    // MARK: - Initializers

    internal init(viewport: CanvasViewport, configuration: CanvasConfiguration = .init()) {
        self.viewport = viewport
        self.configuration = configuration

        super.init(frame: .zero)

        self.autoresizesSubviews = true

        self.setupGridView()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.gridViewDraw()
        }
    }

    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Grid View Methods

    func setupGridView() {
        self.gridView.frame = self.bounds
        self.addSubview(self.gridView)

        let panGesture = NSPanGestureRecognizer(
            target: self,
            action: #selector(self.gridView(panGesture:))
        )
        // Middle button mask = 00100
        panGesture.buttonMask = 4
        self.gridView.addGestureRecognizer(panGesture)

        let clickGesture = NSClickGestureRecognizer(
            target: self,
            action: #selector(self.gridView(clickGesture:))
        )
        self.gridView.addGestureRecognizer(clickGesture)

        let leftPanGesture = NSPanGestureRecognizer(
            target: self,
            action: #selector(self.gridView(leftPanGesture:))
        )
        self.gridView.addGestureRecognizer(leftPanGesture)

        let magnificationGesture = NSMagnificationGestureRecognizer(
            target: self,
            action: #selector(self.gridView(magnificationGesture:))
        )
        self.gridView.addGestureRecognizer(magnificationGesture)
    }

    func gridViewDraw() {
        self.gridView.draw(viewport: self.viewport)
    }

    @objc
    func gridView(magnificationGesture gesture: NSMagnificationGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.scaleAtStartOfMagnification = self.viewport.scale
        default:
            let scale = self.scaleAtStartOfMagnification * (1.0 + gesture.magnification)
            let location = gesture.location(in: self.gridView)
            self.viewport.zoom(
                self.configuration.clampZoom(scale),
                atScreenPoint: location
            )
        }
    }

    @objc
    func gridView(didScrollWith event: NSEvent) {
        if event.subtype == .mouseEvent {
            let location = self.gridView.convert(event.locationInWindow, from: nil)

            var scale = self.viewport.scale

            if event.hasPreciseScrollingDeltas {
                scale -= event.scrollingDeltaX
            } else {
                scale -= event.deltaY * self.configuration.scrollWheelSensitivity
            }

            self.viewport.zoom(
                self.configuration.clampZoom(scale),
                atScreenPoint: location
            )

        } else {
            let t = CGSize(width: -event.scrollingDeltaX, height: -event.scrollingDeltaY)
            self.viewport.translate(by: t, in: .screen)
        }
    }

    @objc func gridView(panGesture gesture: NSPanGestureRecognizer) {
        let t = gesture.translation(in: self.gridView)
        gesture.setTranslation(.zero, in: self.gridView)

        let amount = CGSize(
            width: -t.x,
            height: -t.y
        )
        self.viewport.translate(by: amount, in: .screen)
    }

    @objc func gridView(clickGesture gesture: NSClickGestureRecognizer) {
        // self.emitter.emit(.clickBackground)
    }

    @objc func gridView(leftPanGesture gesture: NSPanGestureRecognizer) {

        // let shiftDown = NSEvent.modifierFlags.contains(.shift)

        // if gesture.state == .began {
        //     self.leftPanInitialPos = gesture.location(in: self.gridView)
        //     self.emitter.emit(.rectSelectEvent(.started(shiftDown: shiftDown)))
        //     return
        // }

        // if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
        //     self.leftPanInitialPos = nil
        //     self.rectSelectionView.selectionRect = .zero
        //     self.emitter.emit(.rectSelectEvent(.ended))
        //     return
        // }

        // guard let initial = self.leftPanInitialPos else {
        //     log("initial location not set", level: .error)
        //     return
        // }

        // let gridRect = CGRect(
        //     origin: initial,
        //     size: gesture.translation(in: self.gridView).cgSize
        // )

        // let contentRect = self.contentView.convert(gridRect, from: self.gridView)

        // self.rectSelectionView.selectionRect = gridRect

        // self.emitter.emit(.rectSelectEvent(.modified(shiftDown: shiftDown, rect: contentRect)))
    }

    // MARK: - Updates

    func viewportDidChange() {
        self.onEvent?(.viewportDidChange(self.viewport))
        self.gridViewDraw()
        // self.updateContentView()
    }
}

// MARK: - GridView

extension CanvasAppKitView {
    final class GridView: NSView {

        var viewport: CanvasViewport?

        var onEvent: ((Event) -> ())?

        enum Event {
            case scroll(NSEvent)
            case mouseEntered
            case mouseLeft
        }

        init() {
            super.init(frame: .zero)

            self.wantsLayer = true
        }

        required init?(coder: NSCoder) {
            nil
        }

        // MARK: - Drawing

        override var isFlipped: Bool {
            true
        }

        /// Schedule this view for drawing with the give viewport state and list of edges.
        ///
        /// - Parameter viewport: The viewport state.
        /// - Parameter edges: The list of edges to be drawn.
        // func draw(viewport: CanvasViewport, edges: [EdgeLayer]) {
        func draw(viewport: CanvasViewport) {
            self.viewport = viewport
            // self.edgesLayersToDraw = edges
            self.needsDisplay = true
            self.clipsToBounds = true
        }

        override func draw(_ dirtyRect: NSRect) {
            guard let context = NSGraphicsContext.current?.cgContext else {
                return
            }

            if let viewport = self.viewport, let layer = self.layer {
                self.drawBackgroundTiles(context, layer, viewport)
            }
            // self.drawEdges(context)
        }

        override func scrollWheel(with event: NSEvent) {
            self.onEvent?(.scroll(event))
        }
    }
}

extension CanvasAppKitView {
    fileprivate struct Preview: NSViewRepresentable {
        func makeNSView(context: Context) -> some NSView {
            CanvasAppKitView(viewport: .init())
        }

        func updateNSView(_ nsView: NSViewType, context: Context) {

        }
    }
}

#Preview {
    VStack {
        CanvasAppKitView.Preview()
    }
    .padding(10)
}

#endif
