#if os(macOS)
import AppKit

final class MainViewController: NSSplitViewController {

    var sidebarVC: SidebarViewController!
    var detailVC: DetailViewController!
    var inspectorVC: InspectorViewController!

    lazy var sidebarItem: NSSplitViewItem = {
        let item = NSSplitViewItem(sidebarWithViewController: self.sidebarVC)
        item.minimumThickness = 200

        let accessoryView = SidebarAccessoryView()
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

    init() {
        super.init(nibName: nil, bundle: nil)

        self.sidebarVC = .init()
        self.detailVC = .init()
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

final class DetailViewController: NSViewController {
    override func loadView() {
        let view = NSView()
        self.view = view
    }
}

final class InspectorViewController: NSViewController {
    override func loadView() {
        let view = NSView()
        self.view = view
    }
}
#endif
