import Backend
import SharedModels
import SwiftUI
import XKit

public typealias Flow = SharedModels::Flow

public final class InspectorFeatureController: XViewController {

    let flow: Flow
    let coordinator: GlobalCoordinator
    var contentView: ContentView!
    var nodeInspectorVC: NodeInspectorController!
    var canvasInspectorVC: CanvasInspectorController!
    var undoHistoryInspectorVC: UndoHistoryInspectorController!

    var tabView: InspectorTabView {
        self.contentView.tabView
    }

    public init(_ flow: Flow, _ coordinator: GlobalCoordinator) {
        self.flow = flow
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        self.contentView = ContentView()
        self.view = self.contentView
        self.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.view.widthAnchor.constraint(greaterThanOrEqualToConstant: 240),
            self.view.widthAnchor.constraint(lessThanOrEqualToConstant: 600),
        ])
    }

    public override func viewDidLoad() {
        self.setupTabs()
    }

    func setupTabs() {
        self.nodeInspectorVC = NodeInspectorController(self.flow, self.coordinator)
        let nodeInspectorItem = NSTabViewItem(viewController: self.nodeInspectorVC)
        nodeInspectorItem.label = ""
        nodeInspectorItem.image = NSImage(
            systemSymbolName: "list.bullet.rectangle.portrait.fill",
            accessibilityDescription: nil
        )
        self.tabView.addTabViewItem(nodeInspectorItem)

        self.canvasInspectorVC = CanvasInspectorController(self.flow)
        let canvasInspectorItem = NSTabViewItem(viewController: self.canvasInspectorVC)
        canvasInspectorItem.label = ""
        canvasInspectorItem.image = NSImage(systemSymbolName: "circle.grid.3x3.fill", accessibilityDescription: nil)
        self.tabView.addTabViewItem(canvasInspectorItem)

        self.undoHistoryInspectorVC = UndoHistoryInspectorController()
        let undoHistoryItem = NSTabViewItem(viewController: self.undoHistoryInspectorVC)
        undoHistoryItem.label = ""
        undoHistoryItem.image = NSImage(
            systemSymbolName: "clock.arrow.trianglehead.counterclockwise.rotate.90",
            accessibilityDescription: nil
        )
        self.tabView.addTabViewItem(undoHistoryItem)
    }
}

class UndoHistoryInspectorController: XViewController {}
