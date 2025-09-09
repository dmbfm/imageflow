import ColorUtils
import CommonUtils
import CoreGraphics
import Design
import EventEmitter
import Logging
import PlatformUtils
import SwiftUI

#if canImport(AppKit)
import AppKit
public typealias CanvasPlatformView = CanvasNSView
#endif

#if canImport(UIKit)
import UIKit
public typealias CanvasPlatformView = CanvasUIView
#endif

extension CanvasPlatformView {
    public enum Event {
        case viewportDidChange(CanvasViewport)
        case nodePositionsDidChange([UUID: CGPoint])
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
        log("edgeLayersDidChange")
        self.gridViewDraw()
    }

    // MARK: - Node Management

    private func addNode(_ node: some CanvasNodeView, at position: CGPoint) {
        log("addNode at: \(position)")
        node.frame.origin = position
        node.frame.size = node.intrinsicContentSize
        let id = node.id
        node.emitter.on() { [weak self] event in
            guard let self else { return }
            switch event {
            case let .dragGesture(gesture):
                switch gesture.phase {
                case .changed:
                    let amount = self.viewport.convert(
                        .init(width: gesture.dx, height: gesture.dy),
                        from: .screen,
                        to: .canvas
                    )
                    self.translateNode(id, by: amount)
                default:
                    break
                }

            case .sizeChanged:
                node.frame.size = node.intrinsicContentSize

            case .click:
                // self.emitter.emit(.nodeClicked(id))
                break

            case .other(_):
                break

            }
        }
        self.nodeViews[node.id] = node
        self.contentView.addSubview(node)
        self.contentView.sortSubviews()
    }

    func addNode(_ id: UUID, at position: CGPoint) {
        if let node = self.viewForNode(id) {
            self.addNode(node, at: position)
        } else {
            log("Missing view for node \(id)")
        }
    }

    func removeNode(_ id: UUID) {
        guard let node = self.nodeViews[id] else {
            log("Node not found: \(id)")
            return
        }
        self.nodeViews.removeValue(forKey: id)
        node.removeFromSuperview()
    }

    func moveNode(_ id: UUID, to position: CGPoint) {
        guard let node = self.nodeViews[id] else {
            log("Node not found: \(id)")
            return
        }
        node.frame.origin = position
        self.setNeedsLayout()
    }

    func translateNode(_ id: UUID, by translation: CGSize) {
        if self.nodePositions[id] == nil {
            log("Node not found: \(id)")
            return
        }

        let newPos = self.nodePositions[id]! + translation.cgPoint
        self.nodePositions[id] = newPos
        self.onEvent?(.nodePositionsDidChange(self.nodePositions))
        // if let view = self.nodeViews[id] {
        //     view.setFrameOrigin(newPos)
        // }
        // self.emitter.emit(.nodeShouldMove(id, newPos))
    }

}
