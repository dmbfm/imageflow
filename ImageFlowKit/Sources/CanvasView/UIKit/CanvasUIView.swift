#if canImport(UIKit)

import Helpers
import CoreGraphics
import Logging
import SwiftUI

public final class CanvasUIView: UIView, CanvasPlatformViewProtocol {

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

    public weak var delegate: (any CanvasViewDelegate)?

    public var interactionMode: CanvasInteractionMode {
        get {
            self.interactionController.interactionMode
        }

        set {
            self.interactionController.interactionMode = newValue
        }
    }

    // MARK: - Internal / Private Properties

    var canvasInertiaAnimator: CanvasInertiaAnimator = .init()
    var pointerPosition: CGPoint?
    var canvasAnimator: CanvasAnimator?
    var interactionController: CanvasInteractionController!
    var cancellable: Set<AnyEventEmitterCancellable> = []
    var contextMenuInteraction: UIContextMenuInteraction!

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

    lazy var rectSelectionView: RectSelectionView = {
        let view = RectSelectionView()
        view.isUserInteractionEnabled = false
        view.setAutoresizingMask([.flexibleWidth, .flexibleHeight])
        return view
    }()

    lazy var gestureView: CanvasGestureView = {
        let view = CanvasGestureView()
        view.isUserInteractionEnabled = true
        view.canvas = self
        view.frame = self.bounds
        view.setAutoresizingMask([.flexibleWidth, .flexibleHeight])
        return view
    }()

    // MARK: - Initializers

    public init(
        viewport: CanvasView.Viewport,
        nodePositions: [UUID: CGPoint],
        configuration: CanvasView.Configuration = .default,
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
        self.interactionController = CanvasInteractionController(self)

        self.setupGridView()
        self.setupRectSelectionView()
        self.setupContentView()
        self.setupGestureView()

        self.nodePositionsDidChange([:])
        self.gridViewDraw()

        self.contextMenuInteraction = .init(delegate: self)
        self.gridView.addInteraction(self.contextMenuInteraction)
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

    func setupGestureView() {
        self.gestureView.frame = self.bounds
        self.addSubview(self.gestureView)
    }

    func setupGridView() {
        self.gridView.frame = self.bounds
        self.addSubview(self.gridView)

    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.canvasInertiaAnimator.velocity = .zero
        super.touchesBegan(touches, with: event)
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

    func nodeHitTest(_ point: CGPoint) -> UUID? {
        let world = self.convert(point, to: nil)
        for (id, nodeView) in self.nodeViews.reversed() {
            let local = nodeView.convert(world, from: nil)
            if nodeView.bounds.contains(local) {
                return id
            }
        }

        return nil
    }

    // MARK: - RectSelectionView Methods

    func setupRectSelectionView() {
        self.rectSelectionView.bounds = self.frame
        self.addSubview(self.rectSelectionView)
    }
}

final class RectSelectionView: UIView, DisplayLinkHelper.Delegate {
    var selectionRect: CGRect = .zero {
        didSet {
            if !self.playing {
                self._selectionRect = selectionRect
            } else {
                if self.selectionRect.width > 10 || self.selectionRect.height > 10 {
                    self.playing = false
                    self.helper.stop()
                    self._selectionRect = selectionRect
                }
            }
        }
    }

    var _selectionRect: CGRect = .zero {
        didSet {
            self.setNeedsDisplay()
        }
    }

    let helper: DisplayLinkHelper

    override init(frame: CGRect) {
        self.helper = .init()

        super.init(frame: frame)

        self.backgroundColor = .clear

        self.helper.delegate = self
    }

    var playing: Bool = false
    var point: CGPoint = .zero

    let squareSize = 120.0
    let duration = 0.7

    func step(ellapsed: Double) -> Bool {
        if ellapsed > duration {
            self.playing = false
            self._selectionRect = .init(origin: self.point, size: .zero)
            return false
        }

        if !self.playing {
            return false
        }

        let t = EasingCurve.cubic.easeOut(ellapsed / duration)

        if (0...0.5).contains(t) {
            let tt = t / 0.5
            let size = squareSize * tt
            let x = self.point.x * (1.0 - tt) + (self.point.x - squareSize * 0.5) * tt
            let y = self.point.y * (1.0 - tt) + (self.point.y - squareSize * 0.5) * tt
            self._selectionRect = .init(x: x, y: y, width: size, height: size)
        } else if (0.5...1.0).contains(t) {
            let tt = (t - 0.5) / 0.5
            let size = squareSize * (1 - tt)
            let x = (self.point.x - squareSize * 0.5) * (1 - tt) + self.point.x * tt
            let y = (self.point.y - squareSize * 0.5) * (1 - tt) + self.point.y * tt
            self._selectionRect = .init(x: x, y: y, width: size, height: size)
        }

        return true
    }

    func animate(_ point: CGPoint) {
        self.selectionRect = .init(x: point.x, y: point.y, width: 0, height: 0)
        self.point = point
        self.playing = true
        self.helper.start()
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func draw(_ rect: CGRect) {
        UIColor.systemOrange.withAlphaComponent(0.2).setFill()
        UIColor.systemOrange.setStroke()
        let path = UIBezierPath(rect: self._selectionRect)
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
                self.delegate?.canvasView(contextMenuAt: loc)
            }
        )
    }
}

#endif
