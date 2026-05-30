import XKit

class NodeInspectorContentView: XViewEx {

    lazy var scrollView: XScrollView = {
        class ClipView: NSClipView { override var isFlipped: Bool { true } }
        let view = XScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentView = ClipView()
        view.documentView = self.stackView
        view.drawsBackground = false
        return view
    }()

    lazy var stackView: XStackView = {
        let view = XStackView(views: [
            self.nodeTitleRowView
        ])
        view.orientation = .vertical
        view.alignment = .leading
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var nodeTitleRowView: NodeTitleRowView = {
        let view = NodeTitleRowView(icon: "plus", name: "Some Node", locked: false)
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
            self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
        ])
    }
}
