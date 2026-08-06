import ComponentKit
import Helpers
import SwiftUI
import XKit

@MainActor
public final class SettingsFeatureState {
    private var window: NSWindow?
    private var vc: SettingsTabViewController!

    public static let shared = SettingsFeatureState()

    public func openSettingsWindow() {
        if let window = self.window {
            window.makeKeyAndOrderFront(nil)
            return
        }

        self.vc = SettingsTabViewController()
        let window = NSWindow(contentViewController: self.vc)
        window.styleMask = [.closable, .titled]
        window.title = "Preferences"
        // window.contentMinSize = .zero
        // window.contentMaxSize = .init(width: 250, height: .max)
        // print(
        //     "content size: \(window.contentMaxSize), \(window.contentMinSize), \(window.contentViewController?.preferredContentSize)"
        // )
        // window.contentMaxSize = window.frame.size
        // window.contentMinSize = window.frame.size
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        // window.toolbar?.la
        // window.toolbarStyle = .expanded
        window.toolbarStyle = .preference
        self.window = window
    }

    public init() {
    }
}

final class SettingsTabViewController: NSTabViewController {

    var generalVC: GeneralTabViewController!
    var infoVC: InfoTabViewController!

    // override func loadView() {
    //     class ContentView: NSTabView {
    //         override var intrinsicContentSize: NSSize { .init(width: 300, height: Self.noIntrinsicMetric) }
    //     }

    //     self.view = ContentView()
    // }

    override func viewDidLoad() {

        // self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.widthAnchor.constraint(equalToConstant: 480).isActive = true

        self.canPropagateSelectedChildViewControllerTitle = false

        self.generalVC = .init()
        self.generalVC.title = "General"
        let generalItem = NSTabViewItem(viewController: self.generalVC)
        generalItem.label = "General"
        generalItem.image =
            .init(systemSymbolName: "gearshape.fill", accessibilityDescription: "general settings") ?? .init()
        self.addTabViewItem(generalItem)

        self.infoVC = .init()
        self.infoVC.title = "About ImageFlow"
        let infoitem = NSTabViewItem(viewController: self.infoVC)
        infoitem.label = "About"
        infoitem.image =
            .init(systemSymbolName: "info.circle.fill", accessibilityDescription: "info") ?? .init()
        self.addTabViewItem(infoitem)

        self.tabStyle = .toolbar
    }
}

extension NSLayoutConstraint {
    func withPriority(_ priority: NSLayoutConstraint.Priority) -> Self {
        self.priority = priority
        return self
    }
}

final class InfoTabViewController: NSViewController {

}
