import Backend
import SharedModels
import SwiftUI
import XKit

public final class InspectorFeatureController: XViewController {

    public init(_ flow: SharedModels::Flow) {
        self.nodeInspectorVC = .init(flow: flow)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let nodeInspectorVC: NodeInspectorController
    let canvasInspectorVC: CanvasInspectorController = .init()

    lazy var nodeInspectorTabItem: NSTabViewItem = {
        let item = NSTabViewItem(viewController: self.nodeInspectorVC)
        item.label = "Node"
        return item
    }()

    lazy var canvasInspectorTabItem: NSTabViewItem = {
        let item = NSTabViewItem(viewController: self.canvasInspectorVC)
        item.label = "Canvas"
        return item
    }()

    lazy var tabView: NSTabView = {
        let view = NSTabView()
        view.drawsBackground = false
        view.tabViewType = .noTabsNoBorder
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTabViewItem(self.nodeInspectorTabItem)
        view.addTabViewItem(self.canvasInspectorTabItem)
        return view
    }()

    lazy var segmentetControlView: NSSegmentedControl = {
        let view = NSSegmentedControl(
            images: [
                .init(systemSymbolName: "list.bullet.rectangle.portrait.fill", accessibilityDescription: nil)!,
                .init(systemSymbolName: "circle.grid.3x3.fill", accessibilityDescription: nil)!,
            ],
            trackingMode: .selectOne,
            target: nil,
            action: nil
        )
        view.borderShape = .capsule
        view.selectedSegment = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.controlSize = .large
        return view
    }()

    public override func loadView() {
        self.view = ContentView()
    }

    public override func viewDidLoad() {
        self.view.addSubview(self.tabView)
        self.view.addSubview(self.segmentetControlView)

        NSLayoutConstraint.activate([
            self.segmentetControlView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.segmentetControlView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 12),
            self.segmentetControlView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),

            self.tabView.topAnchor.constraint(equalTo: self.segmentetControlView.bottomAnchor, constant: 8),
            self.tabView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.tabView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tabView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])

    }
}

class ContentView: XViewEx {}

class CanvasInspectorController: XViewController {
}
