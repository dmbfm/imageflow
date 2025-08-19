#if canImport(UIKit)

import ColorUtils
import CommonUtils
import CoreGraphics
import Design
import EventEmitter
import Logging
import PlatformUtils
import SwiftUI

public final class CanvasUIView: UIView {

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

    public var configuration: CanvasConfiguration = .init(zoomRange: 0.1...1.0)

    public var onEvent: ((Event) -> ())?

    public var viewForNode: (UUID) -> (any CanvasNodeView)?

    public internal(set) var nodeViews: [UUID: any CanvasNodeView] = [:]

    // MARK: - Private Properties

    private var scaleAtStartOfMagnification: CGFloat = 1.0
    private var startLoc: CGPoint = .zero

    // MARK: - Subviews

    lazy var gridView: GridView = {
        let view = GridView()
        view.setAutoresizingMask([.flexibleWidth, .flexibleHeight])
        return view
    }()

    lazy var contentView: ContentView = {
        let view = ContentView()
        return view
    }()

    // MARK: - Initializers

    public init(
        viewport: CanvasViewport,
        nodePositions: [UUID: CGPoint],
        viewForNode: @escaping (UUID) -> (any CanvasNodeView)?,
    ) {
        self.viewport = viewport
        self.nodePositions = nodePositions
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

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(Self.gridViewPanGesture(_:)))
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        self.gridView.addGestureRecognizer(panGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(Self.gridViewPinchGesture(_:)))
        self.gridView.addGestureRecognizer(pinchGesture)
    }

    @objc
    func gridViewPanGesture(_ gesture: UIPanGestureRecognizer) {
        let t = gesture.translation(in: nil)
        self.viewport.translate(by: t.cgSize * -1.0, in: .screen)
        gesture.setTranslation(.zero, in: nil)
    }

    @objc
    func gridViewPinchGesture(_ gesture: UIPinchGestureRecognizer) {

        if gesture.state == .began {
            self.scaleAtStartOfMagnification = self.viewport.scale
            self.startLoc = gesture.location(in: self.gridView)
        }

        let scale = gesture.scale
        //        let location = gesture.location(in: self.gridView)
        let newZoom = self.scaleAtStartOfMagnification * scale
        self.viewport.zoom(self.configuration.clampZoom(newZoom), atScreenPoint: self.startLoc)
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
        self.contentView.transform = self.viewport.transform(from: .canvas, to: .screen)
        //        self.contentView.contentScaleFactor = self.viewport.scale * 2.0
        //        self.contentView.setNeedsDisplay()
        //        self.contentView.layer.rasterizationScale = self.viewport.scale * 2.0
        //        for view in self.nodeViews {
        //            view.value.contentScaleFactor = self.viewport.scale * 2.0
        //            view.value.layer.rasterizationScale = self.viewport.scale * 2.0
        //            view.value.setNeedsDisplay()
        //        }
    }
}

#endif
