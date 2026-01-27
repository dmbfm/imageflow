import CoreGraphics
import Helpers
import Logging
import SwiftUI

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
    var configuration: CanvasView.Configuration { get }
    var viewForNode: (UUID) -> (any CanvasNodeView)? { get set }
    var onEvent: ((CanvasPlatformView.Event) -> ())? { get set }
    var contextMenuProvider: (any CanvasContextMenuProvider)? { get set }
    init(
        viewport: CanvasView.Viewport,
        nodePositions: [UUID: CGPoint],
        configuration: CanvasView.Configuration,
        viewForNode: @escaping (UUID) -> (any CanvasNodeView)?
    )
}

extension CanvasPlatformView {
    public enum Event {
        case viewportDidChange(CanvasView.Viewport)
        case rectSelect(RectSelect)
        case clickBackground
        case didMoveToSuperview

        public enum RectSelect {
            case started(shiftDown: Bool)
            case modified(shiftDown: Bool, rect: CGRect)
            case ended
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
        node.emitter.on { [weak node] event in
            switch event {
            case .dragGesture:
                break
            case .sizeChanged:
                if let node {
                    node.frame.size = node.intrinsicContentSize
                }
            case .click:
                break
            case .other(_):
                break

            }
        }.store(in: &self.cancellable)
        self.nodeViews[node.id] = node
        self.contentView.addSubview(node)
        self.contentView.sortSubviews()
    }

    func addNode(_ id: UUID, at position: CGPoint) {
        if let node = self.viewForNode(id) {
            self.addNode(node, at: position)
        } else {
            log("Missing view for node \(id)", level: .error)
        }
    }

    func removeNode(_ id: UUID) {
        guard let node = self.nodeViews[id] else {
            log("Node not found: \(id)", level: .warning)
            return
        }
        self.nodeViews.removeValue(forKey: id)
        node.removeFromSuperview()
    }

    func moveNode(_ id: UUID, to position: CGPoint) {
        self.nodeViews[id]?.frame.origin = position
    }

    // MARK: - Context Menu

    public weak var contextMenuProvider: (any CanvasContextMenuProvider)? {
        get {
            self.gridView.contextMenuProvider
        }

        set {
            self.gridView.contextMenuProvider = newValue
        }
    }
}
