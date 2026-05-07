import CIImageView
import CoreImage
import Design
import XKit

class CardContentView: XViewEx {

    var image: CIImage? {
        get { self.imageView.image }
        set { self.imageView.image = newValue }
    }

    lazy var imageView: CIImageXView = {
        let view = CIImageXView()
        view.placement = .fit
        return view
    }()

    init() {
        super.init(frame: .zero)

        self.addSubview(self.imageView)

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
    #endif

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()

        self.imageView.frame = self.bounds
    }

}
