import CommonUtils
import Logging
import Models
import PlatformUtils
import SwiftUI
import SwiftUIUtils

#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

@MainActor
public struct CanvasView: PlatformViewRepresentable {

    // MARK: - Bindings
    let viewport: CanvasViewport
    let nodePositions: [UUID: CGPoint]
    let edgeLayers: [EdgeLayer]
    let canvasPlatformViewRef: PlatformViewRef

    let viewForNode: (UUID) -> (any CanvasNodeView)?
    let onEvent: ((CanvasView.Event) -> ())?

    public enum Event {
        case rectSelect(CanvasPlatformView.Event.RectSelect)
        case clickBackground
        case translatedNode(UUID, CGSize)
        case viewportChange(CanvasViewport)
        case viewportDrag(phase: GesturePhase, translation: CGSize)
        case nodeDrag(node: UUID, phase: GesturePhase, translation: CGSize)
    }

    public init(
        _ viewport: CanvasViewport,
        _ nodePositions: [UUID: CGPoint],
        _ edges: [EdgeLayer],
        _ canvasPlatformViewRef: PlatformViewRef,
        _ viewForNode: @escaping (UUID) -> (any CanvasNodeView)? = { _ in nil },
        _ onEvent: ((CanvasView.Event) -> ())? = nil
    ) {
        self.viewport = viewport
        self.nodePositions = nodePositions
        self.edgeLayers = edges
        self.viewForNode = viewForNode
        self.canvasPlatformViewRef = canvasPlatformViewRef
        self.onEvent = onEvent
    }

    public func makeView(context: Context) -> CanvasPlatformView {
        let view = CanvasPlatformView(
            viewport: self.viewport,
            nodePositions: self.nodePositions,
            viewForNode: self.viewForNode
        )
        view.onEvent = { event in
            switch event {
            case .viewportDidChange(let viewport):
                self.onEvent?(.viewportChange(viewport))
            //            case .nodePositionsDidChange(let nodePositions):
            //                log("xxx")
            //                self.nodePositions = nodePositions
            case .rectSelect(let event):
                self.onEvent?(.rectSelect(event))
            case .clickBackground:
                self.onEvent?(.clickBackground)
            //            case let .translatedNode(id, amount):
            //                self.onEvent?(.translatedNode(id, amount))
            case .nodeDrag(node: let node, phase: let phase, translation: let translation):
                self.onEvent?(.nodeDrag(node: node, phase: phase, translation: translation))
            case .viewportDrag(phase: let phase, translation: let translation):
                self.onEvent?(.viewportDrag(phase: phase, translation: translation))
            }
        }
        self.canvasPlatformViewRef.view = view
        view.edgeLayers = self.edgeLayers
        log("makeView: edgeLayers: \(self.edgeLayers)", level: .debug)
        return view
    }

    public func updateView(_ view: ViewType, context: Context) {

        view.viewForNode = self.viewForNode

        if view.viewport != self.viewport {
            view.viewport = self.viewport
        }

        if view.nodePositions != self.nodePositions {
            view.nodePositions = self.nodePositions
        }

        log("updateView: \(self.edgeLayers), \(view.edgeLayers)", level: .debug)
        if view.edgeLayers != self.edgeLayers {
            view.edgeLayers = self.edgeLayers
        }
    }
}
