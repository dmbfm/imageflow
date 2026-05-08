import CIImageView
import CoreImage
import Design
import SwiftUI
import XKit

#if canImport(AppKit)
import AppKit
#endif

class CardContentView: XViewEx {

    var image: CIImage? {
        get { self.imageView.image }
        set { self.imageView.image = newValue }
    }

    var cardControlsViewModel: CardControlsView.ViewModel = .init(isVisible: false)

    var toolbarButtonHandler: ((ToolbarItemName) -> ())?

    lazy var overlay: XView = {
        let view = NSHostingView(
            rootView: CardControlsView(
                vm: self.cardControlsViewModel,
                toolbarHandler: { [weak self] name in
                    self?.toolbarHandlerWrapper(name)
                }
            )
        )
        view.safeAreaRegions = []
        return view
    }()

    func toolbarHandlerWrapper(_ name: ToolbarItemName) {
        self.toolbarButtonHandler?(name)
    }

    lazy var imageView: CIImageXView = {
        let view = CIImageXView()
        view.placement = .fit
        return view
    }()

    init() {
        super.init(frame: .zero)

        self.addSubview(self.imageView)
        self.addSubview(self.overlay)

        #if os(iOS)
        self.backgroundColor = Colors.canvasBackground.platformColor
        #endif
    }

    #if os(macOS)
    override func draw(_ dirtyRect: NSRect) {
        self.withLayer {
            $0.backgroundColor = Colors.canvasBackground.cgColor
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for t in self.trackingAreas {
            self.removeTrackingArea(t)
        }
        let trackingArea = NSTrackingArea(
            rect: self.bounds,
            options: [.cursorUpdate, .activeInKeyWindow, .mouseEnteredAndExited, .mouseMoved],
            owner: self,
            userInfo: nil
        )
        self.addTrackingArea(trackingArea)
    }

    override func mouseEntered(with event: NSEvent) {
        if !self.cardControlsViewModel.isVisible {
            if self.bounds.width >= 200 {
                self.cardControlsViewModel.isVisible = true
            }
        }
    }

    override func mouseExited(with event: NSEvent) {
        if self.cardControlsViewModel.isVisible {
            self.cardControlsViewModel.isVisible = false
        }
    }
    #endif

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()

        if self.bounds.width < 200 {
            if self.cardControlsViewModel.isVisible {
                Task {
                    self.cardControlsViewModel.isVisible = false
                }
            }
        }

        self.imageView.frame = self.bounds
        self.overlay.frame = self.bounds
    }
}
