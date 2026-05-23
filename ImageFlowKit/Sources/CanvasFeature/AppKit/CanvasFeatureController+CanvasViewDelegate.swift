import CanvasView
import SharedControllers
import SharedModels
import UniformTypeIdentifiers
import XKit

#if os(macOS)
import AppKit
#endif

private let draggableTypes: [UTType] = [
    UTType.png,
    UTType.tiff,
    UTType.jpeg,
    UTType.webP,
    UTType.gif,
    UTType.bmp,
]

extension CanvasFeatureViewController: CanvasViewDelegate {
    public func canvasViewEditMenuShouldAppear() -> Bool {
        self.flow.selection.isEmpty
    }

    public func canvasView(willShowContextMenuForNode id: UUID) {
    }

    public func canvasView(contextMenuForNode id: UUID, at point: CGPoint?) -> XMenu? {
        nil
    }

    public func canvasView(contextMenuAt point: CGPoint) -> XMenu? {
        if self.canvasContextMenuProvider == nil {
            self.canvasContextMenuProvider = .init(self.coordinator)
        }

        return self.canvasContextMenuProvider?.makeMenu(at: point)
    }

    public func canvasView(shouldShowNodeEditMenuAfterTap id: UUID) -> Bool {
        false
    }

    public func canvasViewPerformDragOperation(at point: CGPoint) -> Bool {
        self.pasteboardController.performDrop(onTarget: .canvas(point))
    }

    public func canvasViewCanPerformDragOperation() -> Bool {
        self.pasteboardController.canDrop(context: .canvas)
    }

    public func canvasView(didRemoveViewForNode id: UUID) {
        self.nodeViews.remove(id)
    }

    public func canvasView(viewForNode id: UUID) -> (any CanvasNodeView)? {
        self.viewForNode(id)
    }
}
