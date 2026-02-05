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

    // MARK: - Internal / Private Properties

    var canvasInertiaAnimator: CanvasInertiaAnimator = .init()
    var pointerPosition: CGPoint?
    var canvasAnimator: CanvasAnimator?
    var interactionController: CanvasInteractionController!
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
        self.addInteraction(self.contextMenuInteraction)
    }

    var contextMenuInteraction: UIContextMenuInteraction!

    public weak var contextMenuProvider: (any PositionedContextMenuProvider)?

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

final class RectSelectionView: UIView {
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

#endif
