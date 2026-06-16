import XKit

public final class Pill: XView {
    public var text: String {
        didSet {
            self.labelView.text = self.text
        }
    }

    public var font: XFont = .systemFont(ofSize: XFont.systemFontSize - 4, weight: .semibold) {
        didSet {
            self.labelView.font = font
        }
    }

    public var textColor: XColor? {
        get { self.labelView.textColor }
        set { self.labelView.textColor = newValue }
    }

    public var backgroundColor: XColor = XColor.system.secondaryLabel {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var radius: CGFloat = 4 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var cornerCurve: CALayerCornerCurve = .continuous {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var insets: XEdgeInsets = .init(top: 2, left: 4, bottom: 2, right: 4) {
        didSet {
            self.removeConstraints(self.constraints)
            NSLayoutConstraint.activateConstraint(self.labelView, toFill: self, insets: self.insets)
        }
    }

    public lazy var labelView: XLabel = {
        let view = XLabel(labelWithString: self.text)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = self.font
        view.textColor = .system.secondaryBackground
        return view
    }()

    public init(_ text: String) {
        self.text = text
        super.init(frame: .zero)
        self.withLayer({ _ in })

        self.addSubview(self.labelView)
        NSLayoutConstraint.activateConstraint(self.labelView, toFill: self, insets: self.insets)
    }

    public override var firstBaselineAnchor: NSLayoutYAxisAnchor { self.labelView.firstBaselineAnchor }
    public override var lastBaselineAnchor: NSLayoutYAxisAnchor { self.labelView.lastBaselineAnchor }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func draw(_ dirtyRect: NSRect) {
        self.withLayer({
            $0.backgroundColor = self.backgroundColor.cgColor
            $0.cornerRadius = self.radius
            $0.cornerCurve = self.cornerCurve
        })
    }
}

#Preview {
    Pill("Hello!!!")
}
