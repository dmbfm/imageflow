import SharedModels
import SwiftUI
import XKit

#if canImport(AppKit)
import AppKit
#endif

final class NodeListViewController: XViewController {

    let flow: Flow

    init(_ flow: Flow) {
        self.flow = flow
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = NSHostingView(rootView: NodeListView(flow: self.flow))
    }
}
