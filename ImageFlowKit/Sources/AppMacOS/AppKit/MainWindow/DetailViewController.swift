#if canImport(AppKit)

import AppKit
import SharedModels
import CanvasFeature
import CanvasView
import PreviewFeature
import SwiftUI
import AssetSystem

final class DetailViewController: NSViewController {

    var canvasVC: CanvasFeatureViewController
    var previewVC: PreviewFeatureController

    var canvasView: CanvasPlatformView {
        self.canvasVC.canvasView
    }

    init(
        _ flow: Flow,
        _ coordinator: GlobalCoordinator,
        _ canvasState: CanvasFeatureState,
        _ assetStore: AssetStore
    ) {
        self.canvasVC = .init(flow: flow, state: canvasState, coordinator: coordinator, assetStore: assetStore)
        self.previewVC = .init(flow: flow, coordinator: coordinator, assetStore: assetStore)

        super.init(nibName: nil, bundle: nil)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateSafeAreaInsets(_ s: NSEdgeInsets) {
        self.previewVC.view.needsLayout = true
    }

    override func loadView() {
        self.view = NSView()
        self.view.autoresizesSubviews = true

        self.view.addSubview(self.canvasVC.view)
        self.addChild(self.canvasVC)

        self.canvasVC.view.autoresizingMask = [.width, .height]
        self.canvasVC.view.frame.size = self.view.bounds.size

        self.view.addSubview(self.previewVC.view)
        self.addChild(self.previewVC)

        self.previewVC.view.autoresizingMask = [.width, .height]
        self.previewVC.view.frame = self.view.safeAreaRect

        if #available(macOS 27, *) {
            let coverView = NoClickHostingView(
                rootView:
                    ZStack(alignment: .top) {
                        Color.clear

                        Rectangle()
                            .fill(Color.white.opacity(0.0001))
                            .frame(height: 60)
                            .ignoresSafeArea(.all, edges: [.top])
                            .backgroundExtensionEffect()
                            .allowsHitTesting(false)
                    }
            )
            coverView.autoresizingMask = [.width, .height]
            coverView.frame = self.view.bounds
            self.view.addSubview(coverView)
        } else {
            let coverView = NoClickHostingView(
                rootView:
                    ZStack(alignment: .top) {
                        Color.clear

                        Rectangle()
                            .fill(Color.white.opacity(0.0001))
                            .frame(height: 60)
                            .ignoresSafeArea(.all, edges: [.top])
                            .backgroundExtensionEffect()
                    }
            )
            coverView.autoresizingMask = [.width, .height]
            coverView.frame = self.view.bounds
            self.view.addSubview(coverView)
        }
    }
}

class NoClickHostingView<Content: View>: NSHostingView<Content> {
    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }
}

#endif
