import Backend
import SharedModels
import SwiftUI
import XKit

public typealias Flow = SharedModels::Flow

public final class InspectorFeatureController: XViewController {

    var contentView: ContentView!

    var tabView: InspectorTabView {
        self.contentView.tabView
    }

    public init(_ flow: Flow) {
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
        self.setupTabView()
    }

    func setupTabView() {
        let redVC = NSHostingController(rootView: Color.red)
        let redItem = NSTabViewItem(viewController: redVC)
        redItem.label = ""
        redItem.image = NSImage(systemSymbolName: "list.bullet.rectangle.portrait.fill", accessibilityDescription: nil)
        self.tabView.addTabViewItem(redItem)

        let blueVC = NSHostingController(rootView: Color.blue)
        let blueItem = NSTabViewItem(viewController: blueVC)
        blueItem.label = ""
        blueItem.image = NSImage(systemSymbolName: "circle.grid.3x3.fill", accessibilityDescription: nil)
        self.tabView.addTabViewItem(blueItem)
    }
}
