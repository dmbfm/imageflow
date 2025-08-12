#if canImport(AppKit)

import ColorUtils
import CommonUtils
import CoreGraphics
import Design
import EventEmitter
import Logging
import PlatformUtils
import SwiftUI

public final class CanvasNSView: NSView {

    // MARK: - Public Properties

    public var viewport: CanvasViewport {
        didSet {
            if self.viewport != oldValue {
                self.viewportDidChange()
            }
        }
    }

    public var nodePositions: [UUID: CGPoint] {
        didSet {
            log("nodePositionsDidSet")
            if self.nodePositions != oldValue {
                self.nodePositionsDidChange(oldValue)
            }
        }
    }

    public let configuration: CanvasConfiguration

    public var onEvent: ((Event) -> ())?

    public var viewForNode: (UUID) -> (any CanvasNodeView)?

    public internal(set) var nodeViews: [UUID: any CanvasNodeView] = [:]

    // MARK: - Private Properties

    private var scaleAtStartOfMagnification: CGFloat = 1.0
    private var leftPanInitialPos: CGPoint?

    // MARK: - Subviews

    lazy var gridView: GridView = {
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
        view.setAutoresizingMask([.flexibleWidth, .flexibleHeight])
        return view
    }()

    lazy var contentView: ContentView = {
        let view = ContentView()
        view.setAutoresizingMask([.flexibleWidth, .flexibleHeight])
        return view
    }()

    // MARK: - Initializers

    public init(
        viewport: CanvasViewport,
        nodePositions: [UUID: CGPoint],
        configuration: CanvasConfiguration,
        viewForNode: @escaping (UUID) -> (any CanvasNodeView)?,
    ) {
        self.viewport = viewport
        self.nodePositions = nodePositions
        self.configuration = configuration
        self.viewForNode = viewForNode

        super.init(frame: .zero)

        self.autoresizesSubviews = true
        self.clipsToBounds = true

        self.setupGridView()
        self.setupContentView()

        self.nodePositionsDidChange([:])
        self.gridViewDraw()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        nil
    }

    // MARK: - GridView Methods

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

    func gridViewDraw() {
        self.gridView.draw(viewport: self.viewport)
    }

    // MARK: - ContentView Methods

    func setupContentView() {
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
    }

    func updateContentView() {
        self.contentView.bounds = CGRect(
            origin: self.viewport.origin,
            size: self.viewport.convert(
                self.bounds.size,
                from: .screen,
                to: .viewport
            )
        )
    }

    // MARK: - Node Management

}

#endif
