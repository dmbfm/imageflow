#if canImport(AppKit)

import AppKit
import SharedModels
import CanvasFeature
import CanvasView
import PreviewFeature

final class DetailViewController: NSViewController {

    var canvasVC: CanvasFeatureNSViewController
    var previewVC: PreviewFeature.Controller

    var canvasView: CanvasPlatformView {
        self.canvasVC.canvasView
    }

    init(_ flow: Flow, _ coordinator: GlobalCoordinator, _ assetStore: any AssetStoreService) {
        self.canvasVC = .init(flow: flow, coordinator: coordinator, assetStore: assetStore)
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
    }
}

#endif
