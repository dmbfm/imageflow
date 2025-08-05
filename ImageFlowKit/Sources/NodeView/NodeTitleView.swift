import ColorUtils
import PlatformUtils
import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

final class NodeTitleView: PlatformView {

    // MARK: - State

    public var vm: Model {
        didSet {
            self.update()
        }
    }

    struct Model: Sendable, Equatable {
        //        var title: String = "Node Title That is Really Large"
        var title: String = "Add"
        //        var subtitle: String = "Node Subtitle"
        var subtitle: String = "Add"
        var icon: String = "paintbrush"
        var color: PlatformColor = .systemBlue
    }

    // MARK: - Style

    struct Style {
        var iconTitleSpacing: CGFloat = 8
        var titleSubtitleSpacing: CGFloat = 2
        var iconSize: CGFloat = 16
        var iconPointSize: CGFloat = 12
        var minTitleWidth: CGFloat = 80
        var titleWidthSafetyMargin: CGFloat = 0
    }

    // MARK: - Subviews (macOS)

    #if os(macOS)

    private var style: Style = .init(iconSize: 24, minTitleWidth: 90, titleWidthSafetyMargin: 10)

    lazy var imageView: NSImageView = {
        let image = NSImage(systemSymbolName: self.vm.icon, accessibilityDescription: nil)!
        let iconView = NSImageView()
        iconView.image = image
        iconView.contentTintColor = self.vm.color.platformColor
        iconView.symbolConfiguration = .init(pointSize: self.style.iconPointSize, weight: .regular)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: self.style.iconSize).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: self.style.iconSize).isActive = true
        iconView.wantsLayer = true
        return iconView
    }()

    lazy var titleView: NSTextField = {
        let title = NSTextField(labelWithString: self.vm.title)
        title.font = .systemFont(ofSize: 13, weight: .medium)
        title.cell!.truncatesLastVisibleLine = true
        title.lineBreakMode = .byTruncatingTail
        title.usesSingleLineMode = true
        title.translatesAutoresizingMaskIntoConstraints = false
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return title
    }()

    private lazy var subtitleView: NSTextField = {
        let subtitleView = NSTextField(labelWithString: self.vm.subtitle)
        subtitleView.font = .systemFont(ofSize: 10, weight: .regular)
        subtitleView.textColor = .secondaryLabelColor
        subtitleView.translatesAutoresizingMaskIntoConstraints = false
        subtitleView.lineBreakMode = .byTruncatingTail
        return subtitleView
    }()

    lazy var textStack: NSStackView = {
        let stack = NSStackView(views: [self.titleView, self.subtitleView])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = self.style.titleSubtitleSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    lazy var containerStack: NSStackView = {
        let stack = NSStackView(views: [imageView, textStack])
        stack.orientation = .horizontal
        stack.alignment = .centerY
        stack.spacing = self.style.iconTitleSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    #endif

    // MARK: - Subviews (iOS)

    #if os(iOS)

    private var style: Style = .init()

    lazy var imageView: UIImageView = {
        let image = UIImage(systemName: self.vm.icon)!
        let view = UIImageView()
        view.image = image
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.tintColor = self.vm.color.platformColor
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        let size = 16.0
        view.widthAnchor.constraint(equalToConstant: size).isActive = true
        view.heightAnchor.constraint(equalToConstant: size).isActive = true
        return view
    }()
    private let titleView: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 13, weight: .medium)
        lbl.textColor = .label
        lbl.numberOfLines = 1
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()
    private let subtitleView: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 10, weight: .regular)
        lbl.textColor = .secondaryLabel
        lbl.numberOfLines = 1
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.titleView, self.subtitleView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = self.style.titleSubtitleSpacing
        return stack
    }()

    private lazy var containerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, textStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = self.style.iconTitleSpacing
        return stack
    }()
    #endif

    // MARK: - Initializers
    init(_ vm: Model) {
        self.vm = vm

        super.init(frame: .zero)

        self.platformInit()
        self.update()
    }

    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Methods (macOS)

    #if os(macOS)
    func platformInit() {

        self.wantsLayer = true
        self.layer?.backgroundColor = .clear

        self.addSubview(self.containerStack)
        NSLayoutConstraint.activate([
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStack.topAnchor.constraint(equalTo: topAnchor),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

    }

    func update() {
        self.titleView.stringValue = self.vm.title
        self.subtitleView.stringValue = self.vm.subtitle
        self.imageView.contentTintColor = self.vm.color.platformColor
    }

    #endif

    // - MARK: - Methods (iOS)

    #if os(iOS)

    func platformInit() {
        self.backgroundColor = .clear

        addSubview(containerStack)

        NSLayoutConstraint.activate([
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStack.topAnchor.constraint(equalTo: topAnchor),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    func update() {
        self.titleView.text = self.vm.title
        self.subtitleView.text = self.vm.subtitle
        self.imageView.tintColor = self.vm.color.platformColor
        self.invalidateIntrinsicContentSize()
    }

    #endif
    override var intrinsicContentSize: CGSize {
        #if os(iOS)
        let titleSize = self.titleView.textRect(forBounds: .infinite, limitedToNumberOfLines: 1)
        let subtitleSize = self.subtitleView.textRect(forBounds: .infinite, limitedToNumberOfLines: 1)
        #endif
        #if os(macOS)
        let titleSize = self.titleView.intrinsicContentSize
        let subtitleSize = self.subtitleView.intrinsicContentSize  //cell?.drawingRect(forBounds: .infinite) ?? .zero
        #endif

        let size = CGSize(
            width: 16 + self.style.iconTitleSpacing
                + min(titleSize.width + style.titleWidthSafetyMargin, max(subtitleSize.width, self.style.minTitleWidth)),
            height: titleSize.height + subtitleSize.height + self.style.titleSubtitleSpacing
        )

        return size
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

#Preview {
    VStack {
        NodeTitleView.Preview()
            .border(.orange)
    }
    .padding(50)
}
