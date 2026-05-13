#if os(macOS)

import Foundation
import AppKit

extension MainViewController {
    @objc func exportImageCommand(_ sender: Any?) {
        self.previewVC.exportImage()
    }
}

extension MainViewController {
    override func validateUserInterfaceItem(_ item: any NSValidatedUserInterfaceItem) -> Bool {
        if item.action == #selector(Self.exportImageCommand(_:)) {
            return self.detailVC?.previewVC.canExportImage == true
        }

        return true
    }
}
#endif
