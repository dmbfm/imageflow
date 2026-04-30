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

    init(_ flow: Flow, _ assetStore: any AssetsProvider) {
        self.canvasVC = .init(flow: flow, assetStore: assetStore)

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

    var redView: NSView!
    override func viewDidLoad() {
        logger.debug(
            "safeAreaIntets: \("\(self.view.safeAreaInsets)"), safeAreaRect: \("\(self.view.safeAreaRect)"), \("\(self.view.additionalSafeAreaInsets)")"
        )
        self.redView = .init(
            frame: .init(
                x: self.view.safeAreaRect.origin.x + 50,
                y: self.view.safeAreaRect.origin.y + 50,
                width: 250,
                height: 250
            )
        )
        self.redView.wantsLayer = true
        self.redView?.layer?.backgroundColor = NSColor.systemMint.cgColor
        self.redView?.layer?.cornerRadius = 10
        self.redView?.layer?.cornerCurve = .continuous
        self.redView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.redView)
        NSLayoutConstraint.activate([
            self.redView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            self.redView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            // self.redView.le..constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor)
        ])
    }
}

#endif
