import Helpers
import SwiftUI
import XKit

@MainActor
public final class SettingsFeatureState: NSObject {
    private var window: NSWindow?

    public static let shared = SettingsFeatureState()

    public func openSettingsWindow() {
        if let window = self.window {
            window.makeKeyAndOrderFront(nil)
            return
        }

        let window = NSWindow(contentViewController: SettingsTabViewController())
        window.delegate = self
        window.styleMask = [.closable, .titled]
        window.title = "Preferences"

        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        window.toolbarStyle = .preference
        self.window = window
    }
}

extension SettingsFeatureState: NSWindowDelegate {
    public func windowWillClose(_ notification: Notification) {
        self.window = nil
    }
}

final class SettingsTabViewController: NSTabViewController {

    var generalVC: GeneralTabViewController!
    var infoVC: InfoTabViewController!

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
