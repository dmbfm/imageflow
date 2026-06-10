import Combine
import Helpers
import XKit

public final class Box: XView, Rx, WithRef {

    public var backgroundColor: XColor {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var borderColor: XColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var view: XView {
        didSet {
            self.setupView()
        }
    }

    public var insets: XEdgeInsets {
        didSet {
            self.setupView()
        }
    }

    public var cornerRadius: CGFloat {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var cornerCurve: CALayerCornerCurve {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var cancellables: Set<AnyCancellable> = []

    public init(
        view: XView,
    ) {
        self.backgroundColor = .system.quaternaryFill
        self.borderColor = .system.fill
        self.insets = .init(12)
        self.cornerRadius = 6
        self.cornerCurve = .circular
        self.view = view

        super.init(frame: .zero)

        self.wantsLayer = true

        self.addSubview(self.view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraint(self.view, toFill: self, insets: insets)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.subviews.forEach({ $0.removeFromSuperview() })
        self.addSubview(self.view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraint(self.view, toFill: self, insets: insets)
    }

    public override func draw(_ dirtyRect: NSRect) {
        self.withLayer({
            $0.backgroundColor = self.backgroundColor.cgColor
            $0.cornerRadius = self.cornerRadius
            $0.cornerCurve = self.cornerCurve
            if let color = self.borderColor {
                $0.borderColor = color.cgColor
                $0.borderWidth = 1
            }
        })
    }
}

#Preview {
    {
        let p: CurrentValueSubject<XColor?, Never> = CurrentValueSubject(XColor.systemTeal)
        return Box(
            view: HStack(views: [
                Label("Do something"),
                Button("Do it!") {
                    p.send(
                        XColor(
                            deviceRed: .random(in: 0...1),
                            green: .random(in: 0...1),
                            blue: .random(in: 0...1),
                            alpha: 1
                        )
                    )
                },
            ])
        )
        .rx(p.map({ $0?.withAlphaComponent(0.25) }), kp: \.borderColor)
        .rx(p.map({ $0?.withAlphaComponent(0.25) })) { ($0.view.subviews[0].subviews[0] as! Label).textColor = $1 }
    }()
}
