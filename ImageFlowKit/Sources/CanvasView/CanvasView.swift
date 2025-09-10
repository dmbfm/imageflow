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
    @Binding var viewport: CanvasViewport
    @Binding var nodePositions: [UUID: CGPoint]
    let edgeLayers: [EdgeLayer]
    let canvasPlatformViewRef: PlatformViewRef

    let viewForNode: (UUID) -> (any CanvasNodeView)?
    let onEvent: ((CanvasView.Event) -> ())?

    public enum Event {
        case rectSelect(CanvasPlatformView.Event.RectSelect)
        case clickBackground
        case translatedNode(UUID, CGSize)
    }

    public init(
        _ viewport: Binding<CanvasViewport>,
        _ nodePositions: Binding<[UUID: CGPoint]>,
        _ edges: [EdgeLayer],
        _ canvasPlatformViewRef: PlatformViewRef,
        _ viewForNode: @escaping (UUID) -> (any CanvasNodeView)? = { _ in nil },
        _ onEvent: ((CanvasView.Event) -> ())? = nil
    ) {
        self._viewport = viewport
        self._nodePositions = nodePositions
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
                self.viewport = viewport
            case .nodePositionsDidChange(let nodePositions):
                self.nodePositions = nodePositions
            case .rectSelect(let event):
                self.onEvent?(.rectSelect(event))
            case .clickBackground:
                self.onEvent?(.clickBackground)
            case let .translatedNode(id, amount):
                self.onEvent?(.translatedNode(id, amount))
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
