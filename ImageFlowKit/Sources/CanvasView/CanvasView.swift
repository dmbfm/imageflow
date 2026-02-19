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
public struct CanvasView: PlatformViewRepresentable {

    /// A binding to the `CanvasView.Viewport`. This view will freely modify the
    /// viewport according to user input.
    @Binding var viewport: Viewport

    /// The positions of the nodes to be displayed.
    let nodePositions: [UUID: CGPoint]

    /// This array of `EdgeLayer` tells the view which edges to draw in which colors.
    let edgeLayers: [EdgeLayer]

    /// Draw a plus icon at the given position
    let plusIconState: PlusIconState

    /// This is used to set a reference to the underlying `NSView` or `UIView` to be used upwards in the view chain.
    @Binding var canvasPlatformViewRef: CanvasPlatformView?

    /// A closure that provides node views for a give node UUID.
    let viewForNode: (UUID) -> (any CanvasNodeView)?

    /// A closure to listen to canvas view events (see `Event`).
    let onEvent: ((CanvasView.Event) -> ())?

    /// The current interaction mode of the canvas
    let interactionMode: CanvasInteractionMode

    weak var delegate: (any CanvasViewDelegate)?

    /// The public events handled by the `onEvent` closure.
    public enum Event {
        /// This event is emitted when the user drags the canvas' background grid to create a rectangular selection.
        case rectSelect(CanvasPlatformView.Event.RectSelect)
        /// This event is emitted when the user clicks the canvas' background grid.
        case clickBackground
        /// This event is emitted when the canvas' platform view responds to `viewDidMoveToSuperview`.
        case didMoveToSuperview
        ///
        case pointerMoved(positionInView: CGPoint?)
    }

    public init(
        viewport: Binding<Viewport>,
        nodePositions: [UUID: CGPoint],
        edges: [EdgeLayer],
        plusIconState: PlusIconState = .init(),
        canvasPlatformViewRef: Binding<CanvasPlatformView?>,
        viewForNode: @escaping (UUID) -> (any CanvasNodeView)? = { _ in nil },
        delegate: (any CanvasViewDelegate)? = nil,
        interactionMode: CanvasInteractionMode = .default,
        onEvent: ((CanvasView.Event) -> ())? = nil
    ) {
        self._viewport = viewport
        self.nodePositions = nodePositions
        self.edgeLayers = edges
        self.plusIconState = plusIconState
        self.viewForNode = viewForNode
        self._canvasPlatformViewRef = canvasPlatformViewRef
        self.onEvent = onEvent
        self.delegate = delegate
        self.interactionMode = interactionMode
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

        view.delegate = self.delegate
        view.interactionMode = self.interactionMode
        view.plusIconState = self.plusIconState

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

        if view.delegate !== self.delegate {
            view.delegate = self.delegate
        }

        if view.interactionMode != self.interactionMode {
            view.interactionMode = self.interactionMode
        }

        if view.plusIconState != self.plusIconState {
            view.plusIconState = self.plusIconState
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(viewport: self.$viewport)
    }

    public final class Coordinator {
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
            case .pointerMoved(positionInView: let pos):
                self.onEvent?(.pointerMoved(positionInView: pos))
            }
        }
    }
}

extension CanvasView {
    public struct PlusIconState: Equatable {
        public var visible: Bool = false
        public var position: CGPoint = .zero
        public var direction: Direction = .xplus

        public enum Direction {
            case xplus
            case xminus
        }

        public init(
            visible: Bool = false,
            position: CGPoint = .zero,
            direction: CanvasView.PlusIconState.Direction = .xplus
        ) {
            self.visible = visible
            self.position = position
            self.direction = direction
        }

    }
}
