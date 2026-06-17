import XKit

class ContentView: XViewEx {

    let contentInsets: XEdgeInsets = XEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    lazy var tabView: InspectorTabView = {
        let view = InspectorTabView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
        self.addSubview(self.tabView)

        NSLayoutConstraint.activate([
            self.tabView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.contentInsets.left),
            self.tabView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.contentInsets.right),
            self.tabView.topAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.topAnchor,
                constant: self.contentInsets.top
            ),
            self.tabView.bottomAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.bottomAnchor,
                constant: -self.contentInsets.bottom
            ),
        ])
    }
}
