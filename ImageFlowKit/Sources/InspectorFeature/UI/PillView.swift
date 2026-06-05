import XKit

private class PillView: XViewEx {

    var label: String {
        didSet {
            self.labelView.text = self.label
        }
    }

    var font: XFont = .systemFont(ofSize: 9, weight: .semibold) {
        didSet {
            self.labelView.font = font
        }
    }

    var textColor: XColor? {
        get { self.labelView.textColor }
        set { self.labelView.textColor = newValue }
    }

    var insets: XEdgeInsets = .init(top: 2, left: 4, bottom: 2, right: 4) {
        didSet {
            self.removeConstraints(self.constraints)
            NSLayoutConstraint.activateConstraint(self.labelView, toFill: self, insets: self.insets)
        }
    }

    lazy var labelView: XLabel = {
        let view = XLabel(labelWithString: self.label)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = self.font
        view.textColor = .system.secondaryBackground
        return view
    }()

    init(_ label: String) {
        self.label = label
        super.init(frame: .zero)
        self.withLayer({ _ in })

        self.addSubview(self.labelView)
        NSLayoutConstraint.activateConstraint(self.labelView, toFill: self, insets: self.insets)
    }

    override func draw(_ dirtyRect: NSRect) {
        self.withLayer({
            $0.backgroundColor = XColor.system.secondaryLabel.cgColor
            $0.cornerRadius = 4
            $0.cornerCurve = .continuous
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
