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
    weak var nodeSnappingButton: NSButton? = nil

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

        self.canvasZoomControlVM.zoomToFitAll = { [unowned self] in
            self.mainVC.perform(userAction: .viewport(.zoomToFitContent))
        }

        self.canvasZoomControlVM.zoomToFitSelected = { [unowned self] in
            self.mainVC.perform(userAction: .viewport(.zoomToFitSelection))
        }

        self.mainVC.flow.selectionDidChangePublisher.sink { [unowned self] sel in
            self.updateCanZoomToFitContent()
        }.store(in: &self.combineCancellables)

        self.mainVC.flow.$nodeCount.sink { [unowned self] count in
            self.updateCanZoomToFitAll(count)
        }.store(in: &self.combineCancellables)

        self.updateCanZoomToFitContent()
        self.updateCanZoomToFitAll()

        self.mainVC.canvasViewportPublisher
            .sink(receiveValue: { [weak self] viewport in
                self?.canvasZoomControlVM.zoom = Double(Int(viewport.scale * 100.0)) / 100.0
            }).store(in: &self.combineCancellables)

        self.mainVC.canvasNodeSnappingEnabledPublisher.sink { [unowned self] value in
            if let btn = self.nodeSnappingButton {
                btn.state = value ? .on : .off
            }
        }.store(in: &self.combineCancellables)
    }

    func updateCanZoomToFitContent() {
        let newValue = !self.mainVC.flow.selection.isEmpty
        if self.canvasZoomControlVM.canZoomToFitContent != newValue {
            self.canvasZoomControlVM.canZoomToFitContent = newValue
        }
    }

    func updateCanZoomToFitAll(_ count: Int? = nil) {
        let newValue =
            if let count {
                count > 0
            } else {
                !self.mainVC.flow.nodes.isEmpty
            }
        if self.canvasZoomControlVM.canZoomToFitAll != newValue {
            self.canvasZoomControlVM.canZoomToFitAll = newValue
        }
    }

    @objc func showAssetBrowser() {
        self.mainVC.perform(userAction: .openAssetBrowser)
    }

    @objc func nodeSnappingToggle() {
        self.mainVC.perform(
            userAction: .setCanvasNodeSnapping(!self.mainVC.detailVC.canvasVC.state.nodeSnapping.enabled)
        )
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
                systemSymbolName: .systemIconNode,
                accessibilityDescription: "Node List"
            )
            item.label = "Node List"
            item.toolTip = "Node List"
            // item.title = "Node List"
            item.action = #selector(Self.showNodeList(_:))
            item.target = self
            return item
        case .nodeSnapping:
            let item = NSToolbarItem(itemIdentifier: .nodeSnapping)
            item.label = "Toggle Node Snapping"
            item.toolTip = "Toogle Node Snapping"
            let btn = NSButton()
            btn.image = NSImage(systemSymbolName: "lines.measurement.horizontal", accessibilityDescription: nil)!
            btn.setButtonType(.onOff)
            btn.state = self.mainVC.detailVC.canvasVC.state.nodeSnapping.enabled ? .on : .off
            btn.target = self
            btn.action = #selector(Self.nodeSnappingToggle)
            item.view = btn
            self.nodeSnappingButton = btn
            return item
        default:
            return .init(itemIdentifier: itemIdentifier)
        }
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleSidebar, .sidebarTrackingSeparator, .flexibleSpace, .inspectorTrackingSeparator, .toggleInspector,
            .space, .cloudSharing, .mainWindowZoom, .showAssetBrowser, .nodeList, .nodeSnapping,
        ]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleSidebar,
            .sidebarTrackingSeparator,
            .mainWindowZoom,
            .flexibleSpace,
            .nodeSnapping,
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
    public static let nodeSnapping: Self = .init("com.dmbfm.imageflow.toolbar.node-snapping")
}

#endif
