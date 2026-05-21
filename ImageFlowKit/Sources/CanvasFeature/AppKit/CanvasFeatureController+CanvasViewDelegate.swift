import CanvasView
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
        logger.debug("drag operation at: \("\(point)")")

        let pb = NSPasteboard(name: .drag)

        if let data = pb.data(forType: .init(UTType.imageFlowNodeKindDragItem.identifier)),
            let item = try? JSONDecoder().decode(NodeKindDragItem.self, from: data)
        {
            self.coordinator.perform(userAction: .newNodeWithKind(kind: item.kind, at: .canvasView(point)))
            return true
        }

        let urls = pb.urls(forTypes: draggableTypes)
        if !urls.isEmpty {
            self.coordinator.perform(userAction: .dropImages(urls, .canvasView(point)))
            return true
        }

        return false
    }

    public func canvasViewCanPerformDragOperation() -> Bool {
        let pb = NSPasteboard(name: .drag)

        if pb.canReadItem(withDataConformingToTypes: [
            UTType.imageFlowNodeKindDragItem.identifier
        ]) {
            return true
        }

        if pb.uttypesOfURLs.contains(where: {
            draggableTypes.contains($0)
        }) {
            return true
        }

        return false
    }

    public func canvasView(didRemoveViewForNode id: UUID) {
        self.nodeViews.remove(id)
    }

    public func canvasView(viewForNode id: UUID) -> (any CanvasNodeView)? {
        self.viewForNode(id)
    }
}
