#if os(macOS)

import AppKit
import SidebarFeature
import SwiftUI
import Helpers
import SharedModels

final class SidebarViewController: NSViewController {

    @Observable
    class Coordinator {
        var text: String = ""
        var globalCoordinator: GlobalCoordinator

        internal init(text: String = "", globalCoordinator: GlobalCoordinator) {
            self.text = text
            self.globalCoordinator = globalCoordinator
        }
    }

    var coordinator: Coordinator
    var globalCoordinator: GlobalCoordinator

    public init(globalCoordinator: GlobalCoordinator) {
        self.globalCoordinator = globalCoordinator
        self.coordinator = .init(globalCoordinator: globalCoordinator)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = NSHostingView(rootView: SidebarFeatureViewWrapped(coordinator: self.coordinator))
    }
}

extension SidebarViewController: SidebarSearchField.Delegate {
    func sidebarSearchTextDidChange(_ text: String) {
        logger.debug("sidebarSearchTextDidChange: \(text)")
        self.coordinator.text = text
    }
}

struct SidebarFeatureViewWrapped: View {
    let coordinator: SidebarViewController.Coordinator

    var body: some View {
        SidebarFeatureView(self.coordinator.text) { item in
            self.coordinator.globalCoordinator.perform(userAction: .newNodeWithKind(kind: item.nodeKind, at: nil))
        }
    }
}

final class SidebarSearchField: NSSplitViewItemAccessoryViewController, NSSearchFieldDelegate {

    lazy var searchField: NSSearchField = {
        let view = NSSearchField()
        view.delegate = self
        return view
    }()

    weak var delegate: (any Delegate)? = nil

    protocol Delegate: AnyObject {
        func sidebarSearchTextDidChange(_ text: String)
    }

    override func loadView() {
        self.view = self.searchField
    }

    func unfocus() {
        DispatchQueue.main.async {
            self.searchField.window?.makeFirstResponder(nil)
        }
    }

    func controlTextDidChange(_ obj: Notification) {
        logger.debug("controlTextDidChange: \(self.searchField.text). Is delegate nil? \(self.delegate == nil)")
        self.delegate?.sidebarSearchTextDidChange(self.searchField.stringValue)
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        self.unfocus()
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            self.unfocus()
            return true
        }

        return false
    }
}

#endif
