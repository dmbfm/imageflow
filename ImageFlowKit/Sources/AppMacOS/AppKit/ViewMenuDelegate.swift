#if os(macOS)
import AppKit
import Helpers
import SharedModels
import SwiftUI

class ViewMenuDelegate: NSObject, NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        if let coordinator = (NSApp.keyWindow?.contentViewController as? MainViewController) {
            coordinator.viewMenuWillOpen(menu)
        }
    }
}

#endif
