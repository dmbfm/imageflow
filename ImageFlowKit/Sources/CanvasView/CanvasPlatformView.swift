import CoreGraphics
import Helpers
import SwiftUI
import XKit

#if canImport(AppKit)
import AppKit
public typealias CanvasPlatformView = CanvasNSView
#endif

#if canImport(UIKit)
import UIKit
public typealias CanvasPlatformView = CanvasUIView
#endif

protocol CanvasPlatformViewProtocol {
    var viewport: CanvasView.Viewport { get set }
    var nodePositions: [UUID: CGPoint] { get set }
    var edgeLayers: [CanvasView.EdgeLayer] { get set }
    var plusIconState: CanvasView.PlusIconState { get set }
    var configuration: CanvasView.Configuration { get }
    var onEvent: ((CanvasPlatformView.Event) -> ())? { get set }
    var delegate: (any CanvasViewDelegate)? { get set }
    var interactionMode: CanvasInteractionMode { get set }
    init(
        viewport: CanvasView.Viewport,
        nodePositions: [UUID: CGPoint],
        configuration: CanvasView.Configuration,
    )
    func perform(canvasAction: CanvasAction)
}

public enum CanvasInteractionMode {
    case `default`
    case interactiveSelection
}

public enum CanvasAction {
    case zoomIn
    case zoomOut
    case zoom(CGFloat)
    case zoomToFitContent
    case zoomToFitSelection(Set<UUID>)
    case sortSubviews
}

public protocol CanvasViewDelegate: AnyObject {
    func canvasViewEditMenuShouldAppear() -> Bool
    func canvasView(willShowContextMenuForNode id: UUID)
    func canvasView(contextMenuForNode id: UUID, at point: CGPoint?) -> XMenu?
    func canvasView(contextMenuAt point: CGPoint) -> XMenu?
    func canvasView(shouldShowNodeEditMenuAfterTap id: UUID) -> Bool
    func canvasView(didRemoveViewForNode id: UUID)
    func canvasView(viewForNode id: UUID) -> (any CanvasNodeView)?
    func canvasViewPerformDragOperation(at point: CGPoint) -> Bool
    func canvasViewCanPerformDragOperation() -> Bool
}

extension CanvasPlatformView {
    public enum Event {
        case viewportDidChange(CanvasView.Viewport)
        case rectSelect(RectSelect)
        case clickBackground
        case didMoveToSuperview
        case pointerMoved(positionInView: CGPoint?)

        public enum RectSelect {
            case started(shiftDown: Bool)
            case modified(shiftDown: Bool, rect: CGRect)
            case ended
        }
    }

    public var plusIconState: CanvasView.PlusIconState {
        get {
            self.gridView.plusIconState
        }
        set {
            self.gridView.plusIconState = newValue
        }
    }

    // MARK: - Updates

    func viewportDidChange() {
        self.onEvent?(.viewportDidChange(self.viewport))
        self.gridViewDraw()
        self.updateContentView()
    }

    func nodePositionsDidChange(_ oldValue: [UUID: CGPoint]) {
        for change in oldValue.difference(from: self.nodePositions) {
            switch change {
            case let .added(id, pos):
                self.addNode(id, at: pos)
            case let .removed(id):
                self.removeNode(id)
            case let .modified(id, pos):
                self.moveNode(id, to: pos)
            }
        }
    }

    func edgeLayersDidChange() {
        self.gridViewDraw()
    }

    // MARK: - Node Management

    private func addNode(_ node: some CanvasNodeView, at position: CGPoint) {
        node.frame.origin = position
        node.frame.size = node.intrinsicContentSize
        // NOTE: It seems removing [weak node] here does not cause a retain cycle, but I'm leaving it here just for good
        // measure (since I don't understand *why* a cycle does not happen here.)
        node.emitter.on { [weak node, weak self] event in
            switch event {
            case .dragGesture:
                break
            case .sizeChanged:
                if let node {
                    node.frame.size = node.intrinsicContentSize
                }
            case .click:
                break
            case .keyboardWillShow(windowVerticalOverlap: let value, let duration):
                self?.moveViewportDueToKeyboard(value, duration)
            case .other(_):
                break

            }
        }.store(in: &self.cancellable)
        self.nodeViews[node.id] = node
        self.contentView.addSubview(node)
        self.contentView.sortSubviews()
    }

    func addNode(_ id: UUID, at position: CGPoint) {
        if let node = self.delegate?.canvasView(viewForNode: id) {
            node.setNeedsLayout()
            node.layoutIfNeeded()
            self.addNode(node, at: position)
        } else {
            logger.critical("Missing view for node \(id)")
        }
    }

    func removeNode(_ id: UUID) {
        guard let node = self.nodeViews[id] else {
            logger.warning("Node not found: \(id)")
            return
        }
        node.removeFromSuperview()
        self.nodeViews.removeValue(forKey: id)
        self.delegate?.canvasView(didRemoveViewForNode: id)
    }

    func moveNode(_ id: UUID, to position: CGPoint) {
        self.nodeViews[id]?.frame.origin = position
        self.nodeViews[id]?.setNeedsDisplay()
    }

    // MARK: - Mode View Due To Keyboard

    func moveViewportDueToKeyboard(_ windowAmount: CGFloat, _ duration: CGFloat) {
        #if os(iOS)
        let amount = self.convert(CGRect(x: 0, y: 0, width: 0, height: windowAmount), from: nil).height
        let dy = self.viewport.convert(amount, from: .screen, to: .canvas)
        self.canvasAnimator?.animate(toViewportOrigin: self.viewport.origin + .init(x: 0, y: dy), duration: duration)
        #endif
    }

    // MARK: - Actions

    public func perform(canvasAction: CanvasAction) {
        switch canvasAction {
        case .zoomIn:
            self.zoomIn()
        case .zoomOut:
            self.zoomOut()
        case .zoom(let value):
            self.setZoom(value)
        case .zoomToFitContent:
            self.zoomToFitNodes()
        case .zoomToFitSelection(let selection):
            self.zoomToFit(selection: selection)
        case .sortSubviews:
            self.contentView.sortSubviews()
        }
    }

    public func setZoom(_ value: CGFloat) {
        self.zoomAnim(value, self.safeAreaRect.center)
    }

    public func zoomIn(_ animate: Bool = true) {
        let alpha = log2(self.viewport.scale)
        let nextAlpha = floor(alpha) + 1
        let zoom = pow(2.0, nextAlpha)
        self.zoomAnim(zoom, self.safeAreaRect.center)
    }

    func zoomAnim(_ zoom: CGFloat, _ point: CGPoint) {
        guard self.zoomAnimLink == nil else { return }

        self.zoomAnimData = .init(
            startScale: self.viewport.scale,
            endScale: self.configuration.clampZoom(zoom),
            point: point,
            t: 0
        )
        #if os(macOS)
        self.zoomAnimLink = self.displayLink(target: self, selector: #selector(Self.zoomAnimStep(_:)))
        self.zoomAnimLink?.preferredFrameRateRange = .init(minimum: 60, maximum: 120)
        self.zoomAnimLink?.add(to: .current, forMode: .default)
        #else
        self.zoomAnimLink = CADisplayLink(target: self, selector: #selector(Self.zoomAnimStep(_:)))
        self.zoomAnimLink?.preferredFrameRateRange = .init(minimum: 60, maximum: 120)
        self.zoomAnimLink?.add(to: .current, forMode: .default)
        #endif
    }

    @objc
    func zoomAnimStep(_ link: CADisplayLink) {
        guard let anim = self.zoomAnimData else {
            self.zoomAnimLink?.invalidate()
            self.zoomAnimLink = nil
            return
        }

        var t = anim.t

        let s = EasingCurve.cubic.easeInOut(t)
        let scale = anim.startScale.lerp(to: anim.endScale, t: s)
        self.viewport.zoom(scale, atScreenPoint: anim.point)

        t += link.duration * 6

        if t > 1.0 {
            self.viewport.zoom(anim.endScale, atScreenPoint: anim.point)
            self.zoomAnimData = nil
        } else {
            self.zoomAnimData = .init(startScale: anim.startScale, endScale: anim.endScale, point: anim.point, t: t)
        }
    }

    public func zoomOut(_ animate: Bool = true) {
        let alpha = log2(self.viewport.scale)
        let nextAlpha = floor(alpha) - 1
        let zoom = pow(2.0, nextAlpha)
        self.zoomAnim(zoom, self.safeAreaRect.center)
    }

    public func zoomToFitNodes() {
        if let rect = self.contentRect(nil) {
            self.viewport.fit(
                contentRect: rect,
                centeredAtViewRect: self.safeAreaRect,
                zoomRange: self.configuration.zoomRange,
                padding: 20
            )
        }
    }

    public func zoomToFit(selection: Set<UUID>) {
        if let rect = self.contentRect(selection) {
            self.viewport.fit(
                contentRect: rect,
                centeredAtViewRect: self.safeAreaRect,
                zoomRange: self.configuration.zoomRange,
                padding: 20
            )
        }
    }

    func contentRect(_ nodes: Set<UUID>?) -> CGRect? {
        self.nodeViews.reduce(
            nil as CGRect?,
            { acc, e in
                if let nodes, !nodes.contains(e.key) { return acc }
                return acc?.union(e.value.frame) ?? e.value.frame
            }
        )
    }
}

struct ZoomAnimData {
    var startScale: CGFloat
    var endScale: CGFloat
    var point: CGPoint
    var t: CGFloat
}
