import SwiftUI
import XKit

class BlockView: XViewEx {

    var content: XView {
        didSet {
            self.setupContentView()
        }
    }

    var cornerRadius: CGFloat = 8 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var contentInsets: XEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8) {
        didSet {
            self.setupConstraints()
        }
    }

    var widthSizingMode: SizingMode = .fill {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }

    var heightSizingMode: SizingMode = .contentIntrinsic {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }

    enum SizingMode {
        case contentIntrinsic
        case fill
        case fixed(CGFloat)
    }

    override var wantsUpdateLayer: Bool { true }

    override var isOpaque: Bool { false }

    init(_ content: XView) {
        self.content = content

        super.init(frame: .zero)

        self.setupContentView()
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupContentView() {
        if self.content.superview != nil {
            self.content.removeFromSuperview()
        }

        self.content.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.content)
        self.setupConstraints()
        self.invalidateIntrinsicContentSize()
    }

    func setupConstraints() {
        NSLayoutConstraint.activateConstraint(self.content, toFill: self, insets: self.contentInsets)
    }

    override func updateLayer() {
        self.withLayer({ layer in
            layer.isOpaque = false
            layer.backgroundColor = XColor.system.secondaryFill.cgColor
            layer.cornerRadius = self.cornerRadius
            layer.cornerCurve = .continuous
        })
    }

    override var intrinsicContentSize: CGSize {
        let contentSize = self.content.intrinsicContentSize
        return CGSize(
            width: { () -> CGFloat in
                switch self.widthSizingMode {
                case .contentIntrinsic:
                    contentSize.width + self.contentInsets.left + self.contentInsets.right
                case .fill:
                    XView.noIntrinsicMetric
                case .fixed(let value):
                    value
                }
            }(),
            height: { () -> CGFloat in
                switch self.heightSizingMode {
                case .contentIntrinsic:
                    contentSize.height + self.contentInsets.top + self.contentInsets.bottom
                case .fill:
                    XView.noIntrinsicMetric
                case .fixed(let value):
                    value
                }
            }()
        )
    }
}

fileprivate struct PreviewRepresentable: XViewRepresentable {
    func makeView(context: Context) -> some NSView {
        let label = NSTextField(labelWithString: "Hello!!!!!")
        label.font = .preferredFont(forTextStyle: .title1)
        return BlockView(label)
    }

    func updateView(_ view: ViewType, context: Context) {
    }

    func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
        return .init(width: proposal.replacingUnspecifiedDimensions().width, height: view.intrinsicContentSize.height)
        //        view.intrinsicCon
    }
}

#Preview {
    VStack {
        PreviewRepresentable()
            .padding(100)
    }
}
