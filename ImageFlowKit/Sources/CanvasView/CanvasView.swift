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

/// The `CanvasView` is a view that displays an infinite canvas populated by
/// nodes. It can also draw edges that are meant to connect nodes. This is
/// a presentation view and stores miminal state insidet it, and has the bulk of
/// its state provided via two-way `@Binding`s or one-way `let` bindings. It also
/// communicates with its parent view via events (see `Event` and `onEvent`).
@MainActor
public struct CanvasView: PlatformViewRepresentable {

    /// A binding to the `CanvasViewport`. This view will freely modify the
    /// viewport according to user input.
    @Binding var viewport: CanvasViewport

    /// The positions of the nodes to be displayed.
    let nodePositions: [UUID: CGPoint]

    /// This array of `EdgeLayer` tells the view which edges to draw in which colors.
    let edgeLayers: [EdgeLayer]

    /// This is used to set a reference to the underlying `NSView` or `UIView` to be used upwards in the view chain.
    let canvasPlatformViewRef: PlatformViewRef

    /// A closure that provides node views for a give node UUID.
    let viewForNode: (UUID) -> (any CanvasNodeView)?

    /// A closure to listen to canvas view events (see `Event`).
    let onEvent: ((CanvasView.Event) -> ())?

    /// The public events handled by the `onEvent` closure.
    public enum Event {
        /// This event is emitted when the user drags the canvas' background grid to create a rectangular selection.
        case rectSelect(CanvasPlatformView.Event.RectSelect)
        /// This event is emitted when the user clicks the canvas' background grid.
        case clickBackground
        /// This event is emitted when the canvas' platform view responds to `viewDidMoveToSuperview`.
        case didMoveToSuperview
    }

    public init(
        _ viewport: Binding<CanvasViewport>,
        _ nodePositions: [UUID: CGPoint],
        _ edges: [EdgeLayer],
        _ canvasPlatformViewRef: PlatformViewRef,
        _ viewForNode: @escaping (UUID) -> (any CanvasNodeView)? = { _ in nil },
        _ onEvent: ((CanvasView.Event) -> ())? = nil
    ) {
        self._viewport = viewport
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
                self.viewport = viewport
            case .rectSelect(let event):
                self.onEvent?(.rectSelect(event))
            case .clickBackground:
                self.onEvent?(.clickBackground)
            case .didMoveToSuperview:
                self.onEvent?(.didMoveToSuperview)
            }
        }

        view.edgeLayers = self.edgeLayers

        self.canvasPlatformViewRef.view = view

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

        if view.edgeLayers != self.edgeLayers {
            view.edgeLayers = self.edgeLayers
        }
    }
}
