import ComponentKit
import SharedModels
import XKit

public class InspectorFeatureController: XViewController {

    @ViewLoading var tabView: TabView
    @ViewLoading var nodeTabView: NodeTabView
    @ViewLoading var canvasTabView: CanvasTabView
    @ViewLoading var undoHistoryTabView: UndoHistoryTabView

    let flow: Flow

    public init(_ flow: Flow, _ coordinator: GlobalCoordinator) {
        self.flow = flow
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        self.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.view.widthAnchor.constraint(greaterThanOrEqualToConstant: 240),
            self.view.widthAnchor.constraint(lessThanOrEqualToConstant: 600),
        ])

        self.nodeTabView = NodeTabView(.init(self.flow))
        self.canvasTabView = CanvasTabView()
        self.undoHistoryTabView = UndoHistoryTabView()

        self.tabView = TabView(
            [
                .init(
                    view: self.nodeTabView,
                    label: "",
                    icon: "list.bullet.rectangle.portrait.fill"
                ),
                .init(
                    view: self.canvasTabView,
                    label: "",
                    icon: "circle.grid.3x3.fill"
                ),
                .init(
                    view: self.undoHistoryTabView,
                    label: "",
                    icon: "clock.arrow.trianglehead.counterclockwise.rotate.90"
                ),
            ],
            selectedIndex: 0
        )
        self.tabView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tabView)
        self.tabView.constraintToFillSuperview(insets: .init(top: 0, left: 10, bottom: 0, right: 10))
    }
}
