import CIImageView
import CardStage
import CoreImage
import Design
import SwiftUI
import XKit

#if canImport(AppKit)
import AppKit
#endif

class DockedContentView: XViewEx {

    var image: CIImage? {
        get { self.imageScrollView.image }
        set {
            self.imageScrollView.image = newValue
            self.update()
        }
    }

    var zoom: CGFloat {
        self.imageScrollView.zoom
    }

    var dockLocation: CardDockLocation = .bottom {
        didSet {
            self.setNeedsLayout()
        }
    }

    var style: Style = .init()

    let toolbarViewModel: DockedToolbarView.ViewModel

    weak var delegate: Delegate?

    lazy var toolbarView: XView = {
        let rootView = DockedToolbarView(
            vm: self.toolbarViewModel,
        )
        let view = NSHostingView(rootView: rootView)
        return view
    }()

    lazy var imageScrollView: CIImageScrollXView = {
        let view = CIImageScrollXView(
            frame: .zero,
            configuration: .init(),
        )
        return view
    }()

    lazy var contentUnavailableView: XView = {
        let view = NSHostingView(
            rootView: ZStack {
                Colors.canvasBackground.color
                ContentUnavailableView(
                    "No Image",
                    systemImage: "photo",
                    description: Text("Select a node with an output image to preview!")
                )
            }
        )
        return view
    }()

    init(_ toolbarViewModel: DockedToolbarView.ViewModel) {
        self.toolbarViewModel = toolbarViewModel

        super.init(frame: .zero)

        self.addSubview(self.toolbarView)
        self.addSubview(self.imageScrollView)
        self.addSubview(self.contentUnavailableView)

        self.update()
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update() {
        if self.image == nil {
            if !self.imageScrollView.isHidden {
                self.imageScrollView.animator().isHidden = true
            }
            if self.contentUnavailableView.isHidden {
                self.contentUnavailableView.animator().isHidden = false
            }
        } else {
            if self.imageScrollView.isHidden {
                self.imageScrollView.animator().isHidden = false
            }
            if !self.contentUnavailableView.isHidden {
                self.contentUnavailableView.animator().isHidden = true
            }
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        self.imageScrollView.withLayer({ layer in
            layer.backgroundColor = Colors.canvasBackground.cgColor
        })
        self.withLayer({ layer in
            layer.backgroundColor = Colors.canvasBackground.cgColor
        })
    }

    override func layout() {
        super.layout()

        switch self.dockLocation {
        case .bottom:
            self.layoutBottom()
        case .top:
            self.layoutTop()
        }
    }

    func layoutBottom() {
        self.toolbarView.frame = self.bounds.with(\.size.height, self.style.toolbarHeight)
        self.imageScrollView.frame = self.bounds
            .with(\.origin.y, self.toolbarView.frame.maxY)
            .with(\.size.height, self.bounds.height - self.style.toolbarHeight)
        self.contentUnavailableView.frame = self.imageScrollView.frame
    }

    func layoutTop() {
        self.imageScrollView.frame = self.bounds.with(\.size.height, self.bounds.height - self.style.toolbarHeight)
        self.toolbarView.frame = self.bounds.with(\.origin.y, self.imageScrollView.frame.maxY).with(
            \.size.height,
            self.style.toolbarHeight
        )
        self.contentUnavailableView.frame = self.imageScrollView.bounds
    }

}

extension DockedContentView {
    struct Style {
        var toolbarHeight: CGFloat = 28.0
    }
}

extension DockedContentView {
    protocol Delegate: AnyObject {
        func dockedContentViewZoomDidChange(_ view: DockedContentView, _ zoom: CGFloat)
    }
}
