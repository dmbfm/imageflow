import Helpers
import XKit

public final class VScrollView: XView, WithRef {
    lazy var scrollView: XScrollView = {
        class ClipView: NSClipView { override var isFlipped: Bool { true } }
        let view = XScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentView = ClipView()
        view.documentView = self.stackView
        view.drawsBackground = false
        return view
    }()

    public let stackView: VStack

    public init(_ views: [XView], spacing: CGFloat? = nil) {
        self.stackView = VStack(alignment: .fill, spacing: spacing, views: views)
            .with(\.translatesAutoresizingMaskIntoConstraints, false)

        super.init(frame: .zero)

        self.addSubview(self.scrollView)
        self.scrollView.constraintToFillSuperview()
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func addView(_ view: XView) {
        self.stackView.addView(view)
    }

    public func setCustomSpacing(_ spacing: CGFloat, after view: XView) {
        self.stackView.setCustomSpacing(spacing, after: view)
    }

    public func insertView(_ view: XView, at index: Int) {
        self.stackView.insertView(view, at: index)
    }

    public func removeView(_ view: XView) {
        self.stackView.removeView(view)
    }

    public func removeAllViews() {
        self.stackView.removeAllViews()
    }
}
