#if os(macOS)
import AppKit
import CanvasFeature
import SharedModels

final class MainViewController: NSSplitViewController {

    var flow: Flow
    var sidebarVC: SidebarViewController!
    var detailVC: DetailViewController!
    var inspectorVC: InspectorViewController!

    lazy var sidebarItem: NSSplitViewItem = {
        let item = NSSplitViewItem(sidebarWithViewController: self.sidebarVC)
        item.minimumThickness = 200

        let accessoryView = SidebarSearchField()
        item.addTopAlignedAccessoryViewController(accessoryView)
        // NOTE: For some reason, we need to set the delegate *after* adding the
        // view to the item, or else it will get unset.
        accessoryView.delegate = self.sidebarVC

        return item
    }()

    lazy var detailItem: NSSplitViewItem = {
        let item = NSSplitViewItem(viewController: self.detailVC)
        item.automaticallyAdjustsSafeAreaInsets = true
        return item
    }()

    lazy var inspectorItem: NSSplitViewItem = {
        let item = NSSplitViewItem(inspectorWithViewController: self.inspectorVC)
        return item
    }()

    init(_ flow: Flow) {
        self.flow = flow

        super.init(nibName: nil, bundle: nil)

        self.sidebarVC = .init()
        self.detailVC = .init(self.flow)
        self.inspectorVC = .init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        self.addSplitViewItem(self.sidebarItem)
        self.addSplitViewItem(self.detailItem)
        self.addSplitViewItem(self.inspectorItem)
    }
}
#endif
