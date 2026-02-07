#if os(iOS)

import UIKit
import Logging
import Helpers

class CanvasGestureView: UIView {

    weak var canvas: CanvasUIView?

    var contextMenuProvider: PositionedContextMenuProvider? {
        self.canvas?.contextMenuProvider
    }

    lazy var editMenuController: EditMenuController = {
        .init(self)
    }()

    func showEditMenu(_ point: CGPoint) {
        self.editMenuController.showEditMenu(point)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if event?.type == .scroll { return self }
        if event?.buttonMask.rawValue == 4 { return self }
        if event?.buttonMask.rawValue == 2 { return nil }
        guard let canvas else { return self }

        let windowPoint = self.convert(point, to: nil)

        for (_, view) in canvas.nodeViews.reversed() {
            let local = view.convert(windowPoint, from: nil)
            if let hit = view.hitTest(local, with: event) {
                return hit
            }
            // Needed for occlusion culling the nodes
            if view.bounds.contains(local) {
                return self
            }
        }

        return self
    }
}

#endif
