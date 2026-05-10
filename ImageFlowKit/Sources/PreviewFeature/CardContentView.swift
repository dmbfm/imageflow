import CIImageView
import CoreImage
import Design
import SwiftUI
import XKit

#if canImport(AppKit)
import AppKit
#endif

class CardContentView: XViewEx {

    // MARK: - Properties

    var image: CIImage? {
        get { self.imageView.image }
        set { self.imageView.image = newValue }
    }

    let controlsViewModel: CardControlsView.ViewModel

    weak var delegate: Delegate?

    // MARK: - Subviews

    lazy var controlsOverlayView: XView = {
        let view = NSHostingView(
            rootView: CardControlsView(
                vm: self.controlsViewModel,
            )
        )
        view.safeAreaRegions = []
        return view
    }()

    lazy var imageView: CIImageXView = {
        let view = CIImageXView()
        view.placement = .fit
        return view
    }()

    // MARK: - Init

    init(_ controlsViewModel: CardControlsView.ViewModel) {

        self.controlsViewModel = controlsViewModel

        super.init(frame: .zero)

        self.addSubview(self.imageView)
        self.addSubview(self.controlsOverlayView)

        #if os(iOS)
        self.backgroundColor = Colors.canvasBackground.platformColor
        #endif
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // func toolbarHandlerWrapper(_ name: CardToolbarItemName) {
    //     self.toolbarButtonHandler?(name)
    // }

    // MARK: - macOS

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
        self.delegate?.cardContentViewMouseEntered(self)
    }

    override func mouseExited(with event: NSEvent) {
        self.delegate?.cardContentViewMouseExited(self)
    }
    #endif

    // MARK: - Layout

    override func layout() {
        super.layout()

        // if self.bounds.width < self.toolbarHideSize {
        //     if self.cardControlsViewModel.isVisible {
        //         Task {
        //             self.cardControlsViewModel.isVisible = false
        //         }
        //     }
        // }

        self.imageView.frame = self.bounds
        self.controlsOverlayView.frame = self.bounds
    }
}

extension CardContentView {
    protocol Delegate: AnyObject {
        func cardContentViewMouseEntered(_ view: CardContentView)
        func cardContentViewMouseExited(_ view: CardContentView)
    }
}
