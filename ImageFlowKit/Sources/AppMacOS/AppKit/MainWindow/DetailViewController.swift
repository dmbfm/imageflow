#if canImport(AppKit)

import AppKit
import SharedModels
import CanvasFeature
import CanvasView

final class DetailViewController: NSViewController {

    var canvasVC: CanvasFeatureNSViewController

    var canvasView: CanvasPlatformView {
        self.canvasVC.canvasView
    }

    init(_ flow: Flow) {
        self.canvasVC = .init(flow: flow)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = NSView()
        self.view.autoresizesSubviews = true

        self.view.addSubview(self.canvasVC.view)
        self.addChild(self.canvasVC)

        self.canvasVC.view.autoresizingMask = [.width, .height]
        self.canvasVC.view.frame.size = self.view.bounds.size
    }

    override func viewDidLoad() {
    }
}

#endif
