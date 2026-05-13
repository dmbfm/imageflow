#if os(macOS)
import AppKit
import Helpers
import SharedModels
import SwiftUI

class ViewMenuDelegate: NSObject, NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        if let mvc = (NSApp.keyWindow?.contentViewController as? MainViewController),
            let item = menu.item(withTitle: "Previews"),
            let menu = mvc.detailVC?.previewVC.makePreviewContextMenu(withHeader: false)
        {
            item.submenu = menu
        } else if let item = menu.item(withTitle: "Previews") {
            item.isEnabled = false
        }
    }
}

#endif
