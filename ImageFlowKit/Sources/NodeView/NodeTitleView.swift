import Helpers
import SharedModels
import SwiftUI
import Logging

public final class NodeTitleView: PlatformCommonView {

    public var vm: ViewModel {
        didSet {
            if self.vm != oldValue {
                print("NodeTitleView: update: \(self.vm.title)")
                self.update(oldValue)
            }
        }
    }

    weak var delegate: (any Delegate)?

    private var style: Style

    protocol Delegate: AnyObject {
        func nodeTitleViewSizeDidChange()
    }

    // MARK: - Subviews

    #if os(macOS)
    private lazy var iconView: NSImageView = {
        let iconView = NSImageView()
        iconView.loadImage(systemSymbolName: self.vm.icon, size: style.iconPointSize)
        iconView.contentTintColor = self.vm.color.platformColor
        return iconView
    }()

    private lazy var titleView: NSTextField = {
        let title = NSTextField(labelWithString: self.vm.title)
        title.font = self.style.titleFont.font
        title.textColor = self.style.titleColor
        return title
    }()

    private lazy var subtitleView: NSTextField = {
        let subtitleView = NSTextField(labelWithString: self.vm.subtitle)
        subtitleView.font = self.style.subtitleFont.font
        subtitleView.textColor = self.style.subtitleColor
        return subtitleView
    }()
    #endif

    #if os(iOS)
    lazy var iconView: UIImageView = {
        let image = UIImage(systemName: self.vm.icon)?
            .applyingSymbolConfiguration(.init(pointSize: self.style.iconPointSize, weight: .regular))
        let view = UIImageView()
        view.image = image
        view.contentMode = .center
        view.preferredSymbolConfiguration = .init(pointSize: self.style.iconPointSize)
        //        view.contentMode = .scaleAspectFit
        view.tintColor = self.vm.color.platformColor
        return view
    }()

    lazy var titleView: UILabel = {
        let lbl = UILabel()
        lbl.font = self.style.titleFont.font
        lbl.textColor = self.style.titleColor
        lbl.numberOfLines = 1
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()

    lazy var subtitleView: UILabel = {
        let lbl = UILabel()
        lbl.font = self.style.subtitleFont.font
        lbl.textColor = self.style.subtitleColor
        lbl.numberOfLines = 1
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()
    #endif

    init(_ vm: ViewModel, style: Style = .default) {
        self.vm = vm
        self.style = style

        super.init(frame: .zero)

        self.addSubview(self.iconView)
        self.addSubview(self.titleView)
        self.addSubview(self.subtitleView)

        self.update(nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func update(_ oldValue: ViewModel?) {
        self.titleView.text = self.vm.title
        self.subtitleView.text = self.vm.subtitle
        self.updateIcon(oldValue)

        // self.invalidateIntrinsicContentSize()
        // self.layoutIfNeeded()
        // Task {
        self.delegate?.nodeTitleViewSizeDidChange()
        // }
        // Task { @MainActor in
        //     self.setNeedsLayout()
        //     self.setNeedsDisplay()
        // }
    }

    #if os(macOS)
    private func updateIcon(_ oldValue: ViewModel?) {
        if oldValue?.icon != self.vm.icon {
            self.iconView.loadImage(systemSymbolName: self.vm.icon, size: style.iconPointSize)
        }
        self.iconView.contentTintColor = self.vm.color.platformColor
    }
    #endif

    #if os(iOS)
    private func updateIcon(_ oldValue: ViewModel?) {
        if self.vm.icon != oldValue?.icon {
            let image = UIImage(systemName: self.vm.icon)!.applyingSymbolConfiguration(
                .init(pointSize: self.style.iconPointSize)
            )
            self.iconView.image = image
        }
        if self.vm.color != oldValue?.color {
            self.iconView.tintColor = self.vm.color.platformColor
        }
    }
    #endif

    private var titleSize: CGSize {
        #if os(macOS)
        //        return self.titleView.attributedStringValue.boundingRect(with: .init(width: 10000.0, height: 10000.0), options: []).size + .init(width: 4, height: 0)
        self.titleView.intrinsicContentSize + .init(width: 2, height: 0)
        #else
        self.titleView.textRect(forBounds: .infinite, limitedToNumberOfLines: 1).size
        #endif
    }

    private var subtitleSize: CGSize {
        #if os(macOS)
        self.subtitleView.intrinsicContentSize + .init(width: 2, height: 0)
        #else
        self.subtitleView.textRect(forBounds: .infinite, limitedToNumberOfLines: 1).size
        #endif
    }

    public override var intrinsicContentSize: CGSize {
        let size = CGSize(
            width: style.iconSize + self.style.iconTitleSpacing
                + max(titleSize.width, max(subtitleSize.width, self.style.minTitleWidth)),
            height: max(titleSize.height + subtitleSize.height + self.style.titleSubtitleSpacing, self.style.iconSize)
        )
        return size
    }

    public override func doLayout() {
        super.doLayout()

        self.iconView.frame = .init(x: 0, y: 0, width: self.style.iconSize, height: self.style.iconSize)
        let textGuide: CGFloat = self.iconView.frame.maxX + self.style.iconTitleSpacing
        self.titleView.frame = .init(
            x: textGuide,
            y: 0,
            width: min(titleSize.width, self.bounds.width - textGuide),
            height: titleSize.height
        )
        print("NodeTitleView:layout:titleView.frame:\(self.titleView.frame)")
        self.subtitleView.frame = .init(
            x: textGuide,
            y: self.titleView.frame.maxY + style.titleSubtitleSpacing,
            width: subtitleSize.width,
            height: subtitleSize.height
        )

        Layout.align(
            views: [self.iconView],
            alignment: .verticalCenter,
            guide: .constant(self.subtitleView.frame.maxY * 0.5)
        )
    }

    #if os(iOS)
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        nil
    }
    #endif

    #if os(macOS)
    public override func hitTest(_ point: CGPoint) -> PlatformView? {
        nil
    }
    #endif

}

#if os(macOS)
extension NSImageView {
    func loadImage(systemSymbolName name: String, size: CGFloat, weight: NSFont.Weight = .regular) {
        let image = NSImage(systemSymbolName: name, accessibilityDescription: nil)!
            .withSymbolConfiguration(.init(pointSize: size, weight: weight))!
        self.image = image
    }
}
#endif

extension NodeTitleView {
    public struct ViewModel: Sendable, Equatable {
        var title: String = "Some node"
        var subtitle: String = "Node Type"
        var icon: String = "paintbrush"
        var color: DynamicColor = .blue

        public init() {}

        public init(title: String, subtitle: String, icon: String, color: DynamicColor) {
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
            self.color = color
        }

        public init(_ node: FlowNode) {
            self.title = node.name
            self.subtitle = node.kind.displayName
            self.icon = node.kind.icon
            self.color = node.kind.frontendNodeColor
        }
    }
}

extension NodeTitleView {
    public struct Style: Sendable, Hashable, With {
        public var iconTitleSpacing: CGFloat = 10
        public var titleSubtitleSpacing: CGFloat = 0
        public var iconSize: CGFloat = 24
        public var iconPointSize: CGFloat = 18
        public var minTitleWidth: CGFloat = 80
        public var titleFont: FontStyle = .systemFont(size: 14, weight: .medium)
        public var subtitleFont: FontStyle = .systemFont(size: 12, weight: .regular)

        #if os(macOS)
        public var titleColor: PlatformColor = .labelColor
        public var subtitleColor: PlatformColor = .secondaryLabelColor
        #endif

        #if os(iOS)
        public var titleColor: PlatformColor = .label
        public var subtitleColor: PlatformColor = .secondaryLabel
        #endif

        public static var `default`: Self {
            #if os(macOS)
            .init()
                .with(\.iconTitleSpacing, 8)
            #else
            .init()
            #endif
        }
    }
}

// MARK: - Previews

extension NodeTitleView {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> NodeTitleView {
            let view = NodeTitleView(.init())
            return view
        }

        func updateView(_ view: NodeTitleView, context: Context) {

        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: NodeTitleView, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        NodeTitleView.Preview()
            .border(.orange.opacity(0.1))
    }
    .padding()
    .background(.white)
}
