#if os(iOS)

import UIKit
import Logging
import Helpers

class CanvasGestureView: UIView {

    weak var canvas: CanvasUIView?

    lazy var editMenuController: EditMenuController = {
        .init(self)
    }()

    func showNodeEditMenu(_ id: UUID, _ point: CGPoint) {
        self.editMenuController.showEditMenu(.node(id), at: point)
    }

    func showCanvasEditMenu(_ point: CGPoint) {
        self.editMenuController.showEditMenu(.canvas, at: point)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if event?.type == .scroll { return self }
        if event?.buttonMask.rawValue == 4 { return self }
        guard let canvas else { return self }

        let windowPoint = self.convert(point, to: nil)

        for (_, view) in canvas.nodeViews.reversed() {
            let local = view.convert(windowPoint, from: nil)
            if let hit = view.hitTest(local, with: event) {
                return hit
            }
            // Needed for occlusion culling the nodes
            if view.bounds.contains(local) {
                // Forward right-click events to the node view to show context menus
                if event?.buttonMask.rawValue == 2 {
                    return view
                } else {
                    return self
                }
            }
        }
        
        if event?.buttonMask.rawValue == 2 { return nil }
        
        return self
    }
}

#endif
