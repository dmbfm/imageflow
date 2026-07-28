#if canImport(AppKit)

import AppKit

extension CanvasNSView {
    @MainActor
    final class DropController {
        weak var canvas: CanvasNSView?
        var canDrag: Bool = false

        func draggingEntered(_ sender: any NSDraggingInfo) -> NSDragOperation {
            self.canDrag = self.canvas?.delegate?.canvasViewCanPerformDragOperation() ?? false

            if self.canDrag {
                return [.copy]
            } else {
                return []
            }
        }

        func draggingUpdated(_ sender: any NSDraggingInfo) -> NSDragOperation {
            guard let canvas = self.canvas, self.canDrag else { return [] }

            if !canvas.safeAreaRect.contains(sender.location(inView: canvas)) {
                return []
            } else {
                return [.copy]
            }
        }

        func performDragOperation(_ sender: any NSDraggingInfo) -> Bool {
            guard let canvas = self.canvas, self.canDrag else { return false }

            return canvas.delegate?.canvasViewPerformDragOperation(
                at: sender.location(inView: canvas),
                pb: sender.draggingPasteboard
            ) ?? false
        }
    }
}

extension NSDraggingInfo {
    @MainActor
    func location(inView view: NSView) -> CGPoint {
        view.convert(self.draggingLocation, from: nil)
    }
}

#endif
