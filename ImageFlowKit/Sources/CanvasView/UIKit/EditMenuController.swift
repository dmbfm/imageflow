#if os(iOS)

import UIKit
import Logging

@MainActor
class EditMenuController: NSObject, UIEditMenuInteractionDelegate {

    weak var view: CanvasGestureView!

    init(_ view: CanvasGestureView) {
        self.view = view
    }

    lazy var editMenuInteraction: UIEditMenuInteraction = {
        let interaction = UIEditMenuInteraction(delegate: self)
        self.view.addInteraction(interaction)
        return interaction
    }()

    var dismissedTime: Date? = .distantPast

    func showEditMenu(_ point: CGPoint) {
        if let dismissedTime = self.dismissedTime {
            if Date.now.timeIntervalSince(dismissedTime) > 0.2 {
                self.show(point)
            }
        }
    }

    private func show(_ point: CGPoint) {
        self.editMenuInteraction.presentEditMenu(with: .init(identifier: "canvas-edit-menu", sourcePoint: point))
        self.dismissedTime = nil
    }

    func editMenuInteraction(
        _ interaction: UIEditMenuInteraction,
        willDismissMenuFor configuration: UIEditMenuConfiguration,
        animator: any UIEditMenuInteractionAnimating
    ) {
        self.dismissedTime = .now
    }

    func editMenuInteraction(
        _ interaction: UIEditMenuInteraction,
        menuFor configuration: UIEditMenuConfiguration,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu? {
        self.view.contextMenuProvider?.canvasContextMenu(at: configuration.sourcePoint)
    }
}
#endif
