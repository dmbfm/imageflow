//
//  NodeTitleUIView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 11/08/25.
//

#if os(iOS)

import UIKit

public final class NodeTitleUIView: UIView {

    public var vm: ViewModel {
        didSet {
            if self.vm != oldValue {
                self.update(oldValue)
            }
        }
    }

    private var style = Style.iOS

    public init(_ vm: ViewModel) {
        self.vm = vm

        super.init(frame: .zero)

        self.addSubview(self.imageView)
        self.addSubview(self.titleView)
        self.addSubview(self.subtitleView)

        self.update(nil)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    lazy var imageView: UIImageView = {
        let image = UIImage(systemName: self.vm.icon)!
        let view = UIImageView()
        view.image = image
        view.contentMode = .scaleAspectFit
        view.tintColor = self.vm.color.platformColor
        return view
    }()

    private let titleView: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 20, weight: .semibold)
        lbl.textColor = .label
        lbl.numberOfLines = 1
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()

    private let subtitleView: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = .secondaryLabel
        lbl.numberOfLines = 1
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()

    public override var intrinsicContentSize: CGSize {
        let titleSize = self.titleView.textRect(forBounds: .infinite, limitedToNumberOfLines: 1)
        let subtitleSize = self.subtitleView.textRect(forBounds: .infinite, limitedToNumberOfLines: 1)
        let size = CGSize(
            width: style.iconSize + self.style.iconTitleSpacing
                + min(titleSize.width, max(subtitleSize.width, self.style.minTitleWidth)),
            height: max(titleSize.height + subtitleSize.height + self.style.titleSubtitleSpacing, self.style.iconSize)
        )
        return size
    }

    public override func layoutSubviews() {
        let titleSize = self.titleView.intrinsicContentSize
        let subtitleSize = self.subtitleView.intrinsicContentSize
        self.imageView.frame = .init(x: 0, y: 0, width: self.style.iconSize, height: self.style.iconSize)
        let textGuide: CGFloat = self.imageView.frame.maxX + self.style.iconTitleSpacing
        self.titleView.frame = .init(
            x: textGuide,
            y: 0,
            width: min(titleSize.width, self.bounds.width - textGuide),
            height: titleSize.height
        )
        self.subtitleView.frame = .init(
            x: textGuide,
            y: self.titleView.frame.maxY + style.titleSubtitleSpacing,
            width: subtitleSize.width,
            height: subtitleSize.height
        )

        Layout.align(
            views: [self.imageView],
            alignment: .verticalCenter,
            guide: .constant(self.subtitleView.frame.maxY * 0.5)
        )
    }

    func update(_ oldValue: ViewModel?) {
        self.titleView.text = self.vm.title
        self.subtitleView.text = self.vm.subtitle

        if self.vm.icon != oldValue?.icon {
            let image = UIImage(systemName: self.vm.icon)!
            self.imageView.image = image
        }

        if self.vm.color != oldValue?.color {
            self.imageView.tintColor = self.vm.color.platformColor
        }

        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
    }
}

#endif
