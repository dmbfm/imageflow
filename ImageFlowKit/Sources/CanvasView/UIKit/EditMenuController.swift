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

    func showEditMenu(_ type: EditMenuType, at point: CGPoint) {

        if self.view.canvas?.interactionMode == .interactiveSelection {
            return
        }

        if type != .canvas {
            if self.dismissedTime == nil {
                self.editMenuInteraction.dismissMenu()
            }
            self.show(type, at: point)
            return
        }

        if let dismissedTime = self.dismissedTime {
            if Date.now.timeIntervalSince(dismissedTime) > 0.2 {
                self.show(type, at: point)
            }
        }
    }

    private func show(_ type: EditMenuType, at point: CGPoint) {
        self.editMenuInteraction.presentEditMenu(with: .init(identifier: type, sourcePoint: point))
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

        guard let identifier = configuration.identifier as? EditMenuType else {
            log("Invalid identifier!", level: .error)
            return nil
        }

        if identifier == .canvas {
            return self.view.canvas?.delegate?.canvasView(contextMenuAt: configuration.sourcePoint)
        } else if case let .node(id) = identifier {
            self.view.canvas?.delegate?.canvasView(willShowContextMenuForNode: id)
            return self.view.canvas?.delegate?.canvasView(
                contextMenuForNode: id,
                at: interaction.location(in: self.view)
            )
        }

        return nil
    }
}

enum EditMenuType: Hashable {
    case canvas
    case node(UUID)
}

#endif
