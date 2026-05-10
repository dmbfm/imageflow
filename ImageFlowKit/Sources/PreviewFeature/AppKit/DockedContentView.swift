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
        set { self.imageScrollView.image = newValue }
    }

    var dockLocation: CardDockLocation = .bottom {
        didSet {
            self.setNeedsLayout()
        }
    }

    var style: Style = .init()

    lazy var toolbarView: XView = {
        let view = XViewEx()
        view.withLayer({ $0.backgroundColor = .teal })
        // view.frame =
        return view
    }()

    lazy var imageScrollView: CIImageScrollXView = {
        let view = CIImageScrollXView(
            frame: .zero,
            id: "",
            configuration: .init(),
            cache: nil
        )
        return view
    }()

    override init(frame: NSRect) {
        super.init(frame: frame)

        self.addSubview(self.toolbarView)
        self.addSubview(self.imageScrollView)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        self.imageScrollView.withLayer({ layer in
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
    }

    func layoutTop() {
        self.imageScrollView.frame = self.bounds.with(\.size.height, self.bounds.height - self.style.toolbarHeight)
        self.toolbarView.frame = self.bounds.with(\.origin.y, self.imageScrollView.frame.maxY).with(
            \.size.height,
            self.style.toolbarHeight
        )
    }

}

extension DockedContentView {
    struct Style {
        var toolbarHeight: CGFloat = 26.0
    }
}
