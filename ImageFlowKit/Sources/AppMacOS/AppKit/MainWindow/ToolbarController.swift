#if os(macOS)
import AppKit
import SharedModels
import SwiftUI
import Combine

@MainActor
final class ToolbarController: NSObject, NSToolbarDelegate {

    var toolbar: NSToolbar
    var canvasZoomControlVM: CanvasZoomToolbarControlView.VM
    var mainVC: MainViewController

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
            self?.mainVC.perform(userAction: .viewport(.setZoom(zoom)))
        }

        self.mainVC.canvasViewportPublisher
            // .throttle(for: 0.04, scheduler: DispatchQueue.main, latest: true)
            .sink(receiveValue: { [weak self] viewport in
                self?.canvasZoomControlVM.zoom = Double(Int(viewport.scale * 100.0)) / 100.0
            }).store(in: &self.combineCancellables)
    }

    var combineCancellables: Set<AnyCancellable> = []

    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .mainWindowZoom:
            let item = NSToolbarItem(itemIdentifier: .mainWindowZoom)
            item.title = "Canvas Zoom"
            item.view = NSHostingView(rootView: CanvasZoomToolbarControlView(vm: self.canvasZoomControlVM))
            return item
        default:
            return .init(itemIdentifier: itemIdentifier)
        }
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleSidebar, .sidebarTrackingSeparator, .flexibleSpace, .inspectorTrackingSeparator, .toggleInspector,
            .space, .cloudSharing, .mainWindowZoom,
        ]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleSidebar,
            .sidebarTrackingSeparator,
            .mainWindowZoom,
            .inspectorTrackingSeparator,
            .flexibleSpace,
            .toggleInspector,
        ]
    }
}

extension NSToolbarItem.Identifier {
    public static let mainWindowZoom: Self = .init(rawValue: "main-window-zoom")
}

#endif
