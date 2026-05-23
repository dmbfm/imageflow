#if os(macOS)

import Foundation
import AppKit
import SharedModels

extension MainViewController {
    @objc func exportImageCommand(_ sender: Any?) {
        self.perform(userAction: .exportPreviewedImage)
    }

    @objc func showAssetBrowserCommand(_ sender: Any?) {
        self.perform(userAction: .openAssetBrowser)
    }

    @objc func rename(_ sender: Any?) {
        guard let id = (sender as? NSMenuItemForNode)?.node else { return }
        self.perform(userAction: .rename(id))
    }

    @objc func cut(_ sender: Any?) {
        self.perform(userAction: .cut(.nodes(self.targetNodes(sender))))
    }

    @objc func copy(_ sender: Any?) {
        self.perform(userAction: .copy(.nodes(self.targetNodes(sender))))
    }

    @objc func paste(_ sender: Any?) {
        self.pasteboardController.performPaste(context: .canvas)
    }

    @objc func delete(_ sender: Any?) {
        self.perform(userAction: .delete(.nodes(self.targetNodes(sender))))
    }

    @objc func duplicate(_ sender: Any?) {
        self.perform(userAction: .duplicate(.nodes(self.targetNodes(sender))))
    }

    @objc
    override func selectAll(_ sender: Any?) {
        self.perform(userAction: .selectAllNodes)
    }

    @objc
    func deselectAll(_ sender: Any?) {
        self.perform(userAction: .selectNone)
    }

    private func targetNodes(_ item: Any?) -> Set<UUID> {
        if let id = (item as? NSMenuItemForNode)?.node {
            if self.flow.selection.contains(id) {
                self.flow.selection
            } else {
                [id]
            }
        } else {
            self.flow.selection
        }
    }
}

extension Set where Element == UUID {
    var nodeName: String {
        if self.count > 1 {
            "Nodes"
        } else {
            "Node"
        }
    }
}

extension MainViewController {
    override func validateUserInterfaceItem(_ item: any NSValidatedUserInterfaceItem) -> Bool {
        logger.debug("validateUserInterfaceItem: \("\(item)")")

        let actionsThatNeedSelection: [Selector?] = [
            #selector(Self.cut(_:)),
            #selector(Self.copy(_:)),
            #selector(Self.duplicate(_:)),
            #selector(Self.delete(_:)),
        ]

        if item is NSMenuItemForNode {
            return true
        } else if item.action == #selector(Self.selectAll(_:)) {
            return !self.flow.nodes.isEmpty
        } else if item.action == #selector(Self.exportImageCommand(_:)) {
            return self.detailVC?.previewVC.canExportImage == true
        } else if item.action == #selector(Self.paste(_:)) {
            return self.pasteboardController.canPaste(context: .canvas)
        } else if actionsThatNeedSelection.contains(item.action) {
            return !self.flow.selection.isEmpty
        } else if item.action == #selector(Self.cancelOperation(_:)) {
            return true
        } else if item.action == #selector(Self.deselectAll(_:)) {
            return !self.flow.selection.isEmpty
        }

        return super.validateUserInterfaceItem(item)
    }
}

#endif
