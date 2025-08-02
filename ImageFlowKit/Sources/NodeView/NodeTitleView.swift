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
        var title: String = "Node Title"
        var subtitle: String = "Node Subtitle"
        var icon: String = "exclamationmark.triangle"
        var color: PlatformColor = .systemBlue
    }

    // MARK: - Style

    private var style: Style = .init()

    struct Style {
        var iconTitleSpacing: CGFloat = 8
        var titleSubtitleSpacing: CGFloat = 2
    }

    // MARK: - Subviews (macOS)

    #if os(macOS)
    lazy var imageView: NSImageView = {
        let image = NSImage(systemSymbolName: self.vm.icon, accessibilityDescription: nil)!
        let iconView = NSImageView()
        iconView.image = image
        iconView.contentTintColor = self.vm.color.platformColor
        iconView.symbolConfiguration = .init(pointSize: 20, weight: .regular)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return iconView
    }()

    lazy var titleView: NSTextField = {
        let title = NSTextField(labelWithString: self.vm.title)
        title.font = .systemFont(ofSize: 13, weight: .medium)
        // title.cell!.lineBreakMode = .byCharWrapping
        // title.cell!.truncatesLastVisibleLine = true
        title.translatesAutoresizingMaskIntoConstraints = false
        title.lineBreakMode = .byTruncatingTail
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
    lazy var imageView: UIImageView = {
        let image = UIImage(systemName: self.vm.icon)!
        let view = UIImageView()
        view.image = image
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.tintColor = self.vm.color.platformColor
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
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
    }
    #endif
}

// MARK: - Previews

extension NodeTitleView {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> NodeTitleView {
            let view = NodeTitleView(.init())
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }

        func updateView(_ view: NodeTitleView, context: Context) {

        }

        func sizeThatFits(_ proposal: ProposedViewSize, nsView: NodeTitleView, context: Context) -> CGSize? {
            .init(width: 300, height: 200)
        }
    }
}

#Preview {
    VStack {
        NodeTitleView.Preview()
    }
    .border(.black)
    .padding(50)
}
