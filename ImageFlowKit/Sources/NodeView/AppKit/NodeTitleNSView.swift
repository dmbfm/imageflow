//
//  NodeTitleNSView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 11/08/25.
//

#if canImport(AppKit)

import AppKit
import CommonUtils

// MARK: - NodeTitleNSView

final class NodeTitleNSView: NSView {

    // MARK: - Init

    init(_ vm: ViewModel) {
        self.vm = vm

        super.init(frame: .zero)

        self.addSubview(self.iconView)
        self.addSubview(self.titleView)
        self.addSubview(self.subtitleView)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Public

    public var vm: ViewModel {
        didSet {
            if self.vm != oldValue {
                self.update()
            }
        }
    }

    // MARK: - Internal

    var style = Style.macOS

    private lazy var iconView: NSImageView = {
        let image = NSImage(systemSymbolName: self.vm.icon, accessibilityDescription: nil)!
            .withSymbolConfiguration(.init(pointSize: style.iconPointSize, weight: .regular))!
        let iconView = NSImageView()
        iconView.image = image
        iconView.contentTintColor = self.vm.color.platformColor
        // iconView.wantsLayer = true
        // iconView.layer?.borderWidth = 2
        return iconView
    }()

    private lazy var titleView: NSTextField = {
        let title = NSTextField(labelWithString: self.vm.title)
        title.font = .systemFont(ofSize: 13, weight: .medium)
        // title.lineBreakMode = .byTruncatingTail
        // title.maximumNumberOfLines = 1
        return title
    }()

    private lazy var subtitleView: NSTextField = {
        let subtitleView = NSTextField(labelWithString: self.vm.subtitle)
        subtitleView.font = .systemFont(ofSize: 10, weight: .regular)
        subtitleView.textColor = .secondaryLabelColor
        // subtitleView.border(.init(color: .red, width: 2))
        // subtitleView.cell!.lineBreakMode = .byCharWrapping
        // subtitleView.cell!.truncatesLastVisibleLine = true
        return subtitleView
    }()

    override var isFlipped: Bool {
        true
    }

    var titleSize: CGSize {
        self.titleView.intrinsicContentSize + .init(width: 4, height: 0)
    }

    var subtitleSize: CGSize {
        self.subtitleView.intrinsicContentSize + .init(width: 4, height: 0)
    }

    override var intrinsicContentSize: NSSize {
        let size = CGSize(
            width: style.iconSize + self.style.iconTitleSpacing
                + max(titleSize.width, subtitleSize.width),
            height: max(titleSize.height + subtitleSize.height + self.style.titleSubtitleSpacing, self.style.iconSize)
        )
        return size
    }

    func update() {

    }

    override func layout() {
        self.iconView.frame = .init(x: 0, y: 0, width: style.iconSize, height: style.iconSize)

        let textGuide: CGFloat = self.iconView.frame.maxX + self.style.iconTitleSpacing
        self.titleView.frame = .init(
            x: textGuide,
            y: 0,
            width: titleSize.width,// min(titleSize.width, self.bounds.width - textGuide),
            height: titleSize.height
        )
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
}

#endif
