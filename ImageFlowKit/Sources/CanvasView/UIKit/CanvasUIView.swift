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

    public var edgeLayers: [EdgeLayer] = [] {
        didSet {
            if self.edgeLayers != oldValue {
                self.edgeLayersDidChange()
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
    private var oneFingerPanInitialPos: CGPoint = .zero

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

    private lazy var rectSelectionView: RectSelectionView = {
        let view = RectSelectionView()
        view.isUserInteractionEnabled = false
        view.setAutoresizingMask([.flexibleWidth, .flexibleHeight])
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
        self.setupRectSelectionView()
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

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Self.tapGestureHandler))
        self.gridView.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(Self.gridViewPanGesture(_:)))
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        self.gridView.addGestureRecognizer(panGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(Self.gridViewPinchGesture(_:)))
        self.gridView.addGestureRecognizer(pinchGesture)

        let oneFingerPanGesture = UIPanGestureRecognizer(target: self, action: #selector(Self.oneFingerPanGesture(_:)))
        oneFingerPanGesture.minimumNumberOfTouches = 1
        oneFingerPanGesture.maximumNumberOfTouches = 1
        self.gridView.addGestureRecognizer(oneFingerPanGesture)
    }

    @objc
    func tapGestureHandler() {
        self.onEvent?(.clickBackground)
    }

    @objc
    func oneFingerPanGesture(_ gesture: UIPanGestureRecognizer) {
        log("\(gesture.state)")

        if gesture.state == .began {
            self.oneFingerPanInitialPos = gesture.location(in: self.gridView)
            self.onEvent?(.rectSelect(.started(shiftDown: false)))
            return
        }

        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            self.oneFingerPanInitialPos = .zero
            self.rectSelectionView.selectionRect = .zero
            self.onEvent?(.rectSelect(.ended))
            return
        }

        let gridRect = CGRect(
            origin: self.oneFingerPanInitialPos,
            size: gesture.translation(in: self.gridView).cgSize
        )

        let contentRect = self.contentView.convert(gridRect, from: self.gridView)

        self.rectSelectionView.selectionRect = gridRect
        self.onEvent?(.rectSelect(.modified(shiftDown: false, rect: contentRect)))
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
        self.gridView.draw(viewport: self.viewport, edges: self.edgeLayers)
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

#endif
