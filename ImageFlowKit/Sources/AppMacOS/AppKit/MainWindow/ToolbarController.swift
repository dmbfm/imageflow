#if os(macOS)
import AppKit
import SharedModels
import SwiftUI
import Combine

@MainActor
final class ToolbarController: NSObject, NSToolbarDelegate {

    var toolbar: NSToolbar
    var canvasZoomControlVM: CanvasZoomToolbarControlView.ViewModel
    var mainVC: MainViewController
    var combineCancellables: Set<AnyCancellable> = []

    init(mainVC: MainViewController) {
        self.mainVC = mainVC
        self.toolbar = .init(identifier: "com.dmbfm.imageflow.macos.toolbar")
        self.canvasZoomControlVM = .init()
        super.init()

        self.toolbar.displayMode = .iconOnly
        self.toolbar.centeredItemIdentifiers = [.mainWindowZoom]
        self.toolbar.delegate = self

        self.canvasZoomControlVM.inc = { [weak self] in
            self?.mainVC.perform(userAction: .viewport(.zoomIn))
        }

        self.canvasZoomControlVM.dec = { [weak self] in
            self?.mainVC.perform(userAction: .viewport(.zoomOut))
        }

        self.canvasZoomControlVM.setZoom = { [weak self] zoom in
            self?.mainVC.perform(userAction: .viewport(.setZoom(zoom, anim: true)))
        }

        self.mainVC.canvasViewportPublisher
            // .throttle(for: 0.04, scheduler: DispatchQueue.main, latest: true)
            .sink(receiveValue: { [weak self] viewport in
                self?.canvasZoomControlVM.zoom = Double(Int(viewport.scale * 100.0)) / 100.0
            }).store(in: &self.combineCancellables)
    }

    @objc func showAssetBrowser() {
        self.mainVC.perform(userAction: .openAssetBrowser)
    }

    @objc func showNodeList(_ sender: NSToolbarItem) {

        if let presented = self.mainVC.presentedViewControllers,
            let nodeListVC = presented.first(where: { $0 is NodeListViewController })
        {
            nodeListVC.dismiss(nil)
        } else {
            guard let view = sender.value(forKey: "_view") as? NSView else {
                logger.error("showNodeList: view is nil!")
                return
            }
            self.mainVC.present(
                NodeListViewController(self.mainVC.flow),
                asPopoverRelativeTo: view.bounds,
                of: view,
                preferredEdge: .maxY,
                behavior: .transient
            )
        }
    }

    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .mainWindowZoom:
            let item = NSToolbarItem(itemIdentifier: .mainWindowZoom)
            item.title = "Canvas Zoom"
            item.label = "Canvas Zoom"
            item.view = NSHostingView(rootView: CanvasZoomToolbarControlView(vm: self.canvasZoomControlVM))
            return item
        case .showAssetBrowser:
            let item = NSToolbarItem(itemIdentifier: .showAssetBrowser)
            item.image = .init(
                systemSymbolName: .systemIconAssetBrowser,
                accessibilityDescription: "Show Asset Browser"
            )
            item.label = "Show Asset Browser"
            item.toolTip = "Show Asset Browser"
            item.action = #selector(Self.showAssetBrowser)
            item.target = self
            return item
        case .nodeList:
            let item = NSToolbarItem(itemIdentifier: .nodeList)
            item.image = .init(
                systemSymbolName: .systemIconNodeList,
                accessibilityDescription: "Node List"
            )
            item.label = "Node List"
            item.toolTip = "Node List"
            // item.title = "Node List"
            item.action = #selector(Self.showNodeList(_:))
            item.target = self
            return item
        default:
            return .init(itemIdentifier: itemIdentifier)
        }
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleSidebar, .sidebarTrackingSeparator, .flexibleSpace, .inspectorTrackingSeparator, .toggleInspector,
            .space, .cloudSharing, .mainWindowZoom, .showAssetBrowser, .nodeList,
        ]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleSidebar,
            .sidebarTrackingSeparator,
            .mainWindowZoom,
            .flexibleSpace,
            .nodeList,
            .inspectorTrackingSeparator,
            .flexibleSpace,
            .showAssetBrowser,
            .space,
            .toggleInspector,
        ]
    }
}

extension NSToolbarItem.Identifier {
    public static let mainWindowZoom: Self = .init(rawValue: "com.dmbfm.imageflow.toolbar.main-window-zoom")
    public static let showAssetBrowser: Self = .init("com.dmbfm.imageflow.toolbar.show-asset-browser")
    public static let nodeList: Self = .init("com.dmbfm.imageflow.toolbar.node-list")
}

#endif
