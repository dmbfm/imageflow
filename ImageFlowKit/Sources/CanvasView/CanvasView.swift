import CommonUtils
import Logging
import PlatformUtils
import SwiftUI
import SwiftUIUtils

public let canvasCoordinateSpaceName = "canvas"

#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

@MainActor
public struct CanvasView: PlatformViewRepresentable {
    @Binding var viewport: CanvasViewport
    @Binding var nodePositions: [UUID: CGPoint]

    let viewForNode: (UUID) -> (any CanvasNodeView)?

    public init(
        _ viewport: Binding<CanvasViewport>,
        _ nodePositions: Binding<[UUID: CGPoint]>,
        _ viewForNode: @escaping (UUID) -> (any CanvasNodeView)? = { _ in nil }
    ) {
        self._viewport = viewport
        self._nodePositions = nodePositions
        self.viewForNode = viewForNode
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
            }
        }
        return view
    }

    public func updateView(_ view: ViewType, context: Context) {

        view.viewForNode = self.viewForNode

        if view.viewport != self.viewport {
            view.viewport = self.viewport
        }

        if view.nodePositions != self.nodePositions {
            log("updating node position!")
            view.nodePositions = self.nodePositions
        }
    }
}
