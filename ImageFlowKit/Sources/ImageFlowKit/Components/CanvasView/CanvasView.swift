import Helpers
import Logging
import SwiftUI

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
struct CanvasView: PlatformViewRepresentable {

    /// A binding to the `CanvasView.Viewport`. This view will freely modify the
    /// viewport according to user input.
    @Binding var viewport: Viewport

    /// The positions of the nodes to be displayed.
    let nodePositions: [UUID: CGPoint]

    /// This array of `EdgeLayer` tells the view which edges to draw in which colors.
    let edgeLayers: [EdgeLayer]

    /// This is used to set a reference to the underlying `NSView` or `UIView` to be used upwards in the view chain.
    @Binding var canvasPlatformViewRef: PlatformView?

    /// A closure that provides node views for a give node UUID.
    let viewForNode: (UUID) -> (any CanvasNodeView)?

    /// A closure to listen to canvas view events (see `Event`).
    let onEvent: ((CanvasView.Event) -> ())?

    /// The public events handled by the `onEvent` closure.
    enum Event {
        /// This event is emitted when the user drags the canvas' background grid to create a rectangular selection.
        case rectSelect(CanvasPlatformView.Event.RectSelect)
        /// This event is emitted when the user clicks the canvas' background grid.
        case clickBackground
        /// This event is emitted when the canvas' platform view responds to `viewDidMoveToSuperview`.
        case didMoveToSuperview
    }

    init(
        _ viewport: Binding<Viewport>,
        _ nodePositions: [UUID: CGPoint],
        _ edges: [EdgeLayer],
        _ canvasPlatformViewRef: Binding<PlatformView?>,
        _ viewForNode: @escaping (UUID) -> (any CanvasNodeView)? = { _ in nil },
        _ onEvent: ((CanvasView.Event) -> ())? = nil
    ) {
        self._viewport = viewport
        self.nodePositions = nodePositions
        self.edgeLayers = edges
        self.viewForNode = viewForNode
        self._canvasPlatformViewRef = canvasPlatformViewRef
        self.onEvent = onEvent
    }

    public func makeView(context: Context) -> CanvasPlatformView {
        let view = CanvasPlatformView(
            viewport: self.viewport,
            nodePositions: self.nodePositions,
            viewForNode: self.viewForNode
        )

        view.edgeLayers = self.edgeLayers

        context.coordinator.viewport = self._viewport
        context.coordinator.onEvent = self.onEvent
        view.onEvent = context.coordinator.onEventHandler

        self.canvasPlatformViewRef = .init(view)

        return view
    }

    public func updateView(_ view: ViewType, context: Context) {

        context.coordinator.viewport = self._viewport
        context.coordinator.onEvent = self.onEvent

        view.onEvent = context.coordinator.onEventHandler
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

    func makeCoordinator() -> Coordinator {
        Coordinator(viewport: self.$viewport)
    }

    class Coordinator {
        init(viewport: Binding<CanvasView.Viewport>, onEvent: ((CanvasView.Event) -> ())? = nil) {
            self.viewport = viewport
            self.onEvent = onEvent
        }

        var onEvent: ((CanvasView.Event) -> ())? = nil
        var viewport: Binding<CanvasView.Viewport>

        func onEventHandler(_ event: CanvasPlatformView.Event) {
            switch event {
            case .viewportDidChange(let viewport):
                self.viewport.wrappedValue = viewport
            case .rectSelect(let event):
                self.onEvent?(.rectSelect(event))
            case .clickBackground:
                self.onEvent?(.clickBackground)
            case .didMoveToSuperview:
                self.onEvent?(.didMoveToSuperview)
            }
        }
    }
}
