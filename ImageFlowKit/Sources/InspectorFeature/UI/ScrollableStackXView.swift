import ComponentKit
import XKit

class ScrollableStackXView: XViewEx {
    lazy var scrollView: XScrollView = {
        class ClipView: NSClipView { override var isFlipped: Bool { true } }
        let view = XScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentView = ClipView()
        view.documentView = self.stackView
        view.drawsBackground = false
        return view
    }()

    lazy var stackView: VStack = {
        let view = VStack(alignment: .fill, views: [])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 16
        return view
    }()

    override init(frame: NSRect) {
        super.init(frame: frame)
        self.setupViews()
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        self.addSubview(self.scrollView)
        NSLayoutConstraint.activateConstraint(self.scrollView, toFill: self)
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
        ])
    }
}
