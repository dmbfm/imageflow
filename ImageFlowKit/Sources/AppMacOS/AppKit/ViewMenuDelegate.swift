#if os(macOS)
import AppKit
import Helpers
import SharedModels
import SwiftUI

class ViewMenuDelegate: NSObject, NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        guard let item = menu.item(withTitle: "Previews") else { return }

        if let mvc = NSApp.mainViewController,
            let previewsMenu = mvc.detailVC?.previewVC.makePreviewContextMenu(withHeader: false)
        {
            item.submenu = previewsMenu
            item.isEnabled = true
        } else {
            item.isEnabled = false
        }
    }
}

#endif
